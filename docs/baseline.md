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
