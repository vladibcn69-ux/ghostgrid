# Ficha pública — MF0490 «Boot2Root» (GhostGrid)

> Documento público. No contiene flags, contraseñas del CTF, soluciones ni pistas sobre las debilidades.

## Descripción

GhostGrid es una máquina virtual de práctica estilo *Boot2Root*: el objetivo es obtener acceso a un usuario sin privilegios y, desde allí, escalar hasta administrador del sistema. Es un ejercicio educativo para uso exclusivo en una red aislada.

## Objetivos

1. Obtener acceso inicial a la máquina.
2. Leer la flag del usuario (`user.txt`).
3. Escalar privilegios.
4. Leer la flag de administrador (`/root/root.txt`).

## Entorno

| Elemento | Valor |
|---|---|
| Sistema operativo | Ubuntu Server 22.04 LTS (kernel 5.15.0) |
| Red | adaptador en red aislada (host-only / interna); dirección por DHCP |
| Servicios expuestos | 22/tcp (SSH) y 8080/tcp (web) |
| Monitorización | Suricata IDS con reglas locales (ver `suricata/`) |

## Reglas del ejercicio

- Usar la máquina solo en una red aislada y propia; no conectarla a Internet ni a redes de terceros.
- No se permiten ataques destructivos (borrado de datos, denegación de servicio).
- Las flags no se publican en este repositorio.

## Documentación relacionada

- Monitorización y línea base: [`docs/MF0488/informe-monitorizacion.md`](../MF0488/informe-monitorizacion.md)
- Reglas de detección: [`suricata/README.md`](../../suricata/README.md)
