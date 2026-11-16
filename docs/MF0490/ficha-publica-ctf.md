# GhostGrid — Reto Boot2Root (MF0490_3)

## Nombre y temática
**GhostGrid** — portal/comunidad de investigación **OSINT** (ficticio). Máquina
vulnerable de tipo *Boot2Root*.

## Descripción
GhostGrid nació como una pequeña comunidad dedicada a la investigación en fuentes
abiertas (OSINT): foros, recopilación de datos públicos y herramientas caseras. El
proyecto creció deprisa y, como suele ocurrir, el equipo fue dejando por el camino
restos de la puesta en marcha y alguna configuración hecha con prisas. Te pones en
la piel de un analista encargado de auditar el portal de principio a fin: entrar,
afianzarte y comprobar hasta dónde se puede llegar.

## Objetivo
Conseguir dos pruebas de control (*flags*), en este orden:

1. **user.txt** — acceso como usuario sin privilegios del sistema.
2. **root.txt** — control total (*root*) de la máquina.

## Indicaciones generales de conexión
- La máquina obtiene su **IP por DHCP** dentro de una **red aislada de laboratorio**.
  Descúbrela con las herramientas habituales de tu equipo atacante.
- **Punto de entrada:** servicio **web** en **tcp/8080**.
- Hay servicio **SSH** en **tcp/22** (lo necesitarás en algún momento del recorrido).
- **Formato de las flags:** `GHOSTGRID{...}`.

## Notas
- Todo lo necesario para resolver el reto está en la propia máquina; no hace falta
  fuerza bruta de contraseñas ni atacar a terceros.
- Trabaja únicamente dentro de la red de laboratorio indicada.

¡Buena caza!
