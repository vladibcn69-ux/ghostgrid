#!/usr/bin/env bash
# Instalación de Suricata (paquete de Ubuntu 22.04, versión 6.0.x) y configuración básica.
# Uso: ./scripts/install-suricata.sh [interfaz] [HOME_NET]
#   ./scripts/install-suricata.sh enp0s3 "[192.168.20.0/24]"
set -euo pipefail

IFACE="${1:-enp0s3}"
HOME_NET="${2:-[192.168.20.0/24]}"
YAML=/etc/suricata/suricata.yaml

sudo apt-get update
sudo apt-get install -y suricata suricata-update

[ -f "$YAML.orig" ] || sudo cp -a "$YAML" "$YAML.orig"

# Interfaz de captura (primer bloque af-packet)
sudo sed -i "0,/^  - interface: .*/s//  - interface: $IFACE/" "$YAML"
# Red protegida
sudo sed -i "s|^\( *HOME_NET:\).*|\1 \"$HOME_NET\"|" "$YAML"
# Solo se usan las reglas locales: se quita suricata.rules (no existe sin suricata-update)
sudo sed -i '/^  - suricata\.rules$/d' "$YAML"

sudo systemctl enable suricata
"$(dirname "$0")/install-rules.sh"
