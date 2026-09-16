# Baseline de actividad — ghostgrid

Línea base de eventos generados durante las pruebas de monitoreo (Suricata IDS, logs de SSH y de nginx) el 2026-09-15. Todas las horas están en UTC.

## Tabla de eventos

| Evento | Fuente (log) | Detectado (sí/no) | Hora (UTC) |
|---|---|---|---|
| Ping ICMP de prueba (regla local) | Suricata `fast.log` (alert, sid:1000001) | Sí | 21:18:27–21:18:30 |
| Login SSH exitoso (clave pública) | `journalctl -u ssh` (sshd) | Sí | 21:18:02 |
| Login SSH fallido (contraseña incorrecta) | `journalctl -u ssh` (sshd) | Sí | 21:18:53 |
| Petición HTTP normal `GET /` (200) | nginx access log (`docker logs web`) | Sí | 21:19:11 |
| Petición HTTP a ruta inexistente `GET /test404` (404) | nginx access log + error log | Sí | 21:19:11 |
| Escaneo de puertos Nmap (`-sT -sV`, puertos 22 y 8080) contra sshd | `journalctl -u ssh` (sshd, `kex_exchange_identification`) | Sí (en el log de aplicación) | 21:52:07 |
| Escaneo de puertos Nmap (NSE scripts) contra nginx | nginx access log (User-Agent "Nmap Scripting Engine") | Sí (en el log de aplicación) | 21:52:13 |
| Escaneo de puertos Nmap — visibilidad en Suricata | Suricata `eve.json` (event_type: flow/http, sin alert) | Parcial — visto pero sin alerta | 21:52:07–21:52:13 |

## Correlación

Se identificó un mismo evento de reconocimiento (escaneo Nmap desde 192.168.20.114) visible en dos fuentes de log independientes con marcas de tiempo muy próximas:

- **21:52:07 UTC** — `sshd` registra `kex_exchange_identification: Connection closed by remote host` desde `192.168.20.114:59502`: una conexión TCP al puerto 22 que no completa el protocolo SSH real — típico de un sondeo de versión de Nmap (`-sV`), no de un cliente SSH legítimo.
- **21:52:13 UTC** — el log de acceso de nginx registra múltiples peticiones (`/nmaplowercheck...`, `/HNAP1`, `/evox/about`, `/sdk`) desde el mismo host `192.168.20.114`, con `User-Agent: Mozilla/5.0 (compatible; Nmap Scripting Engine; https://nmap.org/book/nse.html)` — huella inequívoca de los scripts NSE de detección de servicio HTTP.

Ambos eventos, separados por solo 6 segundos y originados en la misma IP, corresponden a la misma sesión de escaneo Nmap contra dos servicios distintos (22 y 8080). Suricata registró el tráfico a nivel de flujo y de protocolo de aplicación (`event_type: http`, `event_type: flow`) en `eve.json`, pero **no generó ninguna alerta**, ya que solo existe la regla local de ICMP (`sid:1000001`) — no hay reglas de detección de escaneo de puertos ni de firmas HTTP sospechosas. Esto evidencia una brecha de detección a cubrir en las próximas fases del roadmap (reglas adicionales / Emerging Threats ruleset).

## Línea base — tabla obligatoria (2026-09-16)

Repetición formal de las 7 pruebas requeridas, con detección/registro confirmado en cada caso. IP del servidor en el momento de las pruebas: `192.168.20.118` (DHCP, ver docs de red — la IP puede cambiar en futuras sesiones).

| Acción | Fuente | Detectada/registrada | Información obtenida |
|---|---|---|---|
| SSH correcto | `/var/log/auth.log` | Sí | `Sep 16 09:21:05 ghostgrid-srv sshd[2246]: Accepted publickey for ghostadmin from 192.168.20.114 port 58228 ssh2: ED25519 SHA256:kGE6YQhtF+ayKGOOo8uchYH+Z+/igWi0eeZbV2XgonU` |
| SSH incorrecto | `/var/log/auth.log` | Sí | `Sep 16 09:20:42 ghostgrid-srv sshd[2244]: Invalid user nosuchuser from 192.168.20.114 port 58223` seguido de `Connection closed by invalid user nosuchuser 192.168.20.114 port 58223 [preauth]` |
| Web válida | `docker logs ghostgrid-web-1` (access log de nginx) | Sí | `172.18.0.1 - - [16/Sep/2026:09:20:25 +0000] "GET / HTTP/1.1" 200 167 "-" "curl/7.81.0"` |
| Web 404 | `docker logs ghostgrid-web-1` (access + error log de nginx) | Sí | `172.18.0.1 - - [16/Sep/2026:09:20:25 +0000] "GET /nonexistent HTTP/1.1" 404 153 "-" "curl/7.81.0"`; error log: `open() "/usr/share/nginx/html/nonexistent" failed (2: No such file or directory)` |
| Docker | `journalctl -u docker` + `docker inspect ghostgrid-web-1` | Sí | `docker restart ghostgrid-web-1` registrado en journal (`stopping restart-manager container=92fb47991e4a...`, `sbJoin... ep=ghostgrid-web-1`); `docker inspect` confirma `State=running StartedAt=2026-09-16T09:21:22.421615545Z` |
| Ping | `/var/log/suricata/fast.log` | Sí | `09/16/2026-09:21:31.979677 [**] [1:1000001:1] ICMP ping detected (local rule) [**] [Priority: 3] {ICMP} 192.168.20.114:8 -> 192.168.20.118:0` (4 alertas entre 09:21:31 y 09:21:34, una por cada ping enviado desde el host Windows) |
| Nmap | `/var/log/suricata/fast.log` | Sí | `09/16/2026-09:49:32.924605 [**] [1:1000002:1] NMAP SYN scan detected (threshold rule) [**] [Classification: Attempted Information Leak] [Priority: 2] {TCP} 192.168.20.114:23914 -> 192.168.20.118:4` — 10 alertas generadas en <1s por el escaneo `nmap -sT -Pn --disable-arp-ping -p 1-200 192.168.20.118`, confirmando que la nueva regla de umbral (sid:1000002, `threshold: type threshold, track by_src, count 10, seconds 5`) cierra la brecha de detección de escaneos de puertos señalada en la sección anterior |

### Regla Suricata añadida

```
alert tcp any any -> $HOME_NET any (msg:"NMAP SYN scan detected (threshold rule)"; flags:S; threshold: type threshold, track by_src, count 10, seconds 5; classtype:attempted-recon; sid:1000002; rev:1;)
```

Detecta 10 o más paquetes con flag SYN desde el mismo origen hacia cualquier puerto de `$HOME_NET` en una ventana de 5 segundos — patrón característico de un escaneo de puertos (Nmap `-sS`/`-sT`), a diferencia de una conexión legítima puntual.
