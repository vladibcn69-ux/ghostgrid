# GhostGrid

Comunidad OSINT y portal para entusiastas de la inteligencia de fuentes abiertas, con una sección privada para suscriptores.

## Infraestructura

- **OS:** Ubuntu Server 22.04 LTS
- **Kernel:** 5.15.0 (fijado, sin actualizaciones automáticas)

## Servicios

| Servicio | Imagen        | Puerto                     |
|----------|---------------|-----------------------------|
| web      | nginx (build) | 8080 (host) → 80 (contenedor) |
| db       | MariaDB       | interno (3306, red de Docker) |

## Roadmap

- [ ] Suricata / IDS
- [ ] Monitoreo de logs
- [ ] Emulación de vulnerabilidades
