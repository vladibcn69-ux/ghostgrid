# Suricata (IDS) en ghostgrid-srv

Suricata 6.0.4 (paquete de Ubuntu 22.04) en modo IDS, capturando tráfico con `af-packet`.

| Parámetro | Valor |
|---|---|
| Interfaz de captura | `enp0s3` (`af-packet` → `interface: enp0s3`) |
| `HOME_NET` | `[192.168.20.0/24]` (de `/etc/suricata/suricata.yaml`) |
| Ficheros de reglas cargados | solo `local.rules` (`/etc/suricata/rules/local.rules`) |
| Registros | `/var/log/suricata/fast.log` y `eve.json` |

El servidor usa DHCP: si la red cambia, hay que actualizar `HOME_NET` en `suricata.yaml`. Un extracto sin secretos de la configuración está en [`suricata.yaml.example`](suricata.yaml.example).

## Reglas (`local.rules`)

### sid 1000001 — ping ICMP

```
alert icmp any any -> $HOME_NET any (msg:"ICMP ping detected (local rule)"; itype:8; sid:1000001; rev:1;)
```

| Fragmento | Significado |
|---|---|
| `alert` | acción: genera una alerta (IDS, no bloquea) |
| `icmp any any -> $HOME_NET any` | cualquier origen hacia la red protegida; en ICMP los puertos no se usan |
| `msg:"..."` | texto que aparece en `fast.log` |
| `itype:8` | tipo ICMP 8 = *Echo Request* (el ping) |
| `sid:1000001` | identificador único; el rango 1000000+ está reservado a reglas locales |
| `rev:1` | revisión de la regla |

### sid 1000002 — escaneo de puertos SYN (Nmap)

```
alert tcp any any -> $HOME_NET any (msg:"NMAP SYN scan detected (threshold rule)"; flags:S; threshold: type threshold, track by_src, count 10, seconds 5; classtype:attempted-recon; sid:1000002; rev:1;)
```

| Fragmento | Significado |
|---|---|
| `alert tcp any any -> $HOME_NET any` | cualquier paquete TCP hacia cualquier puerto de la red protegida |
| `flags:S` | solo el flag SYN activo: primer paquete de una conexión TCP, el que envía un escáner a cada puerto |
| `threshold: type threshold` | emite una alerta cada vez que se acumulan `count` coincidencias |
| `track by_src` | el contador es independiente para cada IP de origen |
| `count 10, seconds 5` | 10 paquetes SYN del mismo origen en 5 segundos |
| `classtype:attempted-recon` | clasificación: intento de reconocimiento (aparece como *Attempted Information Leak*, prioridad 2) |
| `sid:1000002`, `rev:1` | identificador y revisión |

Una conexión normal envía pocos SYN; un escaneo (`nmap -sT`/`-sS`) envía decenas por segundo, por eso el umbral distingue ambos casos.

## Cómo comprobarlo

1. Validar la configuración (debe terminar con *Configuration provided was successfully loaded*, sin avisos):
   ```
   sudo suricata -T -c /etc/suricata/suricata.yaml -v
   ```
   Salida real en [`docs/MF0488/evidencias/suricata-T.txt`](../docs/MF0488/evidencias/suricata-T.txt).
2. Ping desde otro equipo de la red (sid 1000001):
   ```
   ping <IP_del_servidor>
   ```
3. Escaneo desde otro equipo (sid 1000002):
   ```
   nmap -sT -sV -Pn --disable-arp-ping -p 1-200 <IP_del_servidor>
   ```
4. Ver las alertas en el servidor:
   ```
   sudo tail -f /var/log/suricata/fast.log
   ```
   Extracto real en [`docs/MF0488/evidencias/fast-log-extracto.txt`](../docs/MF0488/evidencias/fast-log-extracto.txt).

## Instalación

```
./scripts/install-suricata.sh enp0s3 "[192.168.20.0/24]"   # instala y configura
./scripts/install-rules.sh                                  # copia local.rules, valida (-T) y reinicia
```
