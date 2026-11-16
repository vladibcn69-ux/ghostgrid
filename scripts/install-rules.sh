#!/usr/bin/env bash
# Instala suricata/local.rules en /etc/suricata/rules/, valida la configuración y reinicia Suricata.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

sudo install -m 0644 "$ROOT/suricata/local.rules" /etc/suricata/rules/local.rules
sudo suricata -T -c /etc/suricata/suricata.yaml -v
sudo systemctl restart suricata
systemctl is-active suricata
