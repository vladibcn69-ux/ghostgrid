# Notas de despliegue — GhostGrid (MF0490)

La máquina se distribuye como OVA y se despliega en TryHackMe. Para que arranque y funcione también en el tier gratuito (t3a.nano, 512 MB de RAM), la imagen se adaptó así. Ninguno de estos cambios afecta al recorrido del reto.

## Red
- `netplan` configurado para levantar DHCP en cualquier interfaz ethernet (`match: name "e*"`), ya que en la nube de TryHackMe la interfaz se llama `eth0` y no `enp0s3` como en VirtualBox.

## Recursos (adaptación a 512 MB)
- Suricata y el contenedor de base de datos (MariaDB) desactivados: no forman parte del recorrido Boot2Root y no caben en 512 MB.
- `initramfs` reducido (`MODULES=dep` + módulos de nube `virtio`, `ena`, `nvme`). El initramfs original (109 MB) no se descomprimía en 512 MB y provocaba un kernel panic en el arranque.

## Verificación
- La imagen arranca con 512 MB y es accesible en la red aislada de TryHackMe (web en tcp/8080, SSH en tcp/22).
