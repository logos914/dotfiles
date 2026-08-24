# Diagrama de señal — Logos Streaming

Diagrama de conexiones de audio y video del operativo de streaming: qué entidad
se conecta con cuál, con qué cable y qué señal transporta.

- `data.yaml` — datos en crudo (entidades, puertos, conexiones, notas
  pendientes). Es la fuente de verdad; si algo cambia en el armado real, se
  actualiza primero acá.
- `index.html` — el diagrama en sí (recorrido de señal con Mermaid + layout
  físico del escritorio con SVG). Se genera a mano a partir de `data.yaml`;
  todavía no hay un script que lo regenere automáticamente.

Estado: primer borrador. Ver la sección "Pendiente de confirmar" dentro del
diagrama para lo que falta cerrar.
