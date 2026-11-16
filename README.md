# GhostGrid

Comunidad OSINT y portal para entusiastas de la inteligencia de fuentes abiertas, con una sección privada para suscriptores. En el módulo MF0490 el servidor se convierte en un reto *Boot2Root* (ver [ficha pública](docs/MF0490/ficha-publica-ctf.md)).

## Infraestructura

- **OS:** Ubuntu Server 22.04 LTS
- **Kernel:** 5.15.0 (fijado, sin actualizaciones automáticas)
- **Red:** DHCP (la IP puede cambiar entre sesiones)

## Servicios

| Servicio | Imagen        | Puerto                     |
|----------|---------------|-----------------------------|
| web      | nginx (build) | 8080 (host) → 80 (contenedor) |
| db       | MariaDB       | interno (3306, red de Docker) |

## Estructura del repositorio

```
README.md
docker-compose.yml
.env.example            # plantilla de variables; el .env real no se versiona
docker/
  nginx/default.conf
  web/                  # Dockerfile e index.html
  db/init/              # scripts SQL de inicialización
suricata/               # local.rules, suricata.yaml.example y README
scripts/                # instalación de Docker, Suricata y reglas
docs/
  MF0488/               # monitorización: informe y evidencias
  MF0490/               # ficha pública del CTF
```

## Puesta en marcha

```
cp .env.example .env     # y cambiar las contraseñas
docker compose up -d
```

## Roadmap

- [x] Suricata / IDS
- [x] Monitoreo de logs
- [ ] Emulación de vulnerabilidades
