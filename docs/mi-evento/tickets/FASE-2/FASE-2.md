# FASE-2 — Sugerencia de hospedaje, reportes básicos e importación

> **Fuente:** `docs/mi-evento/PLAN.md` §4 (algoritmo de hospedajes), §7, §11
> **Estimación:** 5–6 semanas
> **Depende de:** FASE-1
> **Bloquea a:** FASE-3

## Objetivo

Reducir el trabajo manual de asignar hospedaje con sugerencias automáticas que el usuario revisa, y facilitar la carga y el análisis de datos con reportes básicos e importación desde hojas de cálculo.

## Alcance

### Sugerencia automática de hospedaje

Función pura en `core`; solo propone y nunca escribe una asignación sin que el usuario acepte.

- **Entrada:** la unidad a ubicar (persona, matrimonio, grupo explícito o «todos los de la iglesia X que necesitan hospedaje»), las habitaciones activas con su estado, las asignaciones existentes y preferencias opcionales (permitir dividir, preferir cercanía, preferir llenar habitaciones ya abiertas).
- **Preproceso:** se excluyen los miembros con «necesita hospedaje» desactivado, los ya asignados se tratan como fijos y se forman átomos (pareja indivisible de tamaño 2, persona suelta de tamaño 1) con clase H, M o P.
- **Búsqueda:** pareja en habitación libre o de matrimonio sin otro matrimonio; hombres y mujeres sueltos en habitaciones de su sexo o libres, llenando primero las ya abiertas; preferencia por el mismo hospedaje y, si no cabe, hospedajes cercanos o del mismo tipo. *Beam search* de ancho 8, devolviendo los 3 mejores planes.
- **Reglas:** las sugerencias no llenan las plazas libres de una habitación de matrimonio abierta a otros. Se sugiere al menor junto a su acompañante responsable siempre que se pueda; si no cabe, aparece el aviso.
- **Puntuación** con los pesos del plan (§4), desempate determinista por distancia, nombre e id.
- **Salida:** hasta 3 planes con asignaciones por habitación, no ubicados con su motivo, métricas, avisos y explicación en español.
- **Casos límite:** capacidad insuficiente (plan parcial con aviso por clase), ninguna habitación admite matrimonios (se ofrece «separar el matrimonio» solo si el usuario lo activa), grupo mixto que no cabe en un hospedaje, 5 mujeres con habitaciones de 2, parte del grupo ya hospedada, habitación con capacidad reducida después de asignar, hospedaje sin habitaciones.
- **UI:** componente «Propuesta» del diseño (borde discontinuo y etiqueta) con Aceptar, Modificar (abre la asignación manual precargada) y Descartar. Adaptar la pantalla de sugerencia para mostrar habitación y tipo.
- Los borradores se guardan como `Proposal` para no perderse si el dispositivo se apaga.

### Reportes básicos

- Totales por sexo, rango de edad, iglesia, hospedaje y equipo.
- Listados exportables a CSV y XLSX, e imprimibles.

### Importación de asistentes por CSV/Excel

- Importar asistentes desde CSV (UTF-8, separador `;`) y XLSX con `read-excel-file`, cargado bajo demanda.
- Vista previa con errores por fila antes de confirmar, con las mismas validaciones del registro (zod) y detección de duplicados.
- Importación persona por persona para que la sugerencia de equipo funcione igual que en el registro.

### Opcional en esta fase

- Botón «Compartir esta app» para pasar la APK a otro móvil (requiere un pequeño plugin nativo).

## Criterios de aceptación

- [ ] Para cualquier entrada, la sugerencia no incumple las reglas duras (sexo por habitación, un matrimonio por habitación, capacidad, tipo fijo) salvo la alternativa «separar el matrimonio» activada por el usuario.
- [ ] Con la misma entrada, la sugerencia produce el mismo resultado (pruebas de instantánea).
- [ ] Un grupo mixto que no cabe en un hospedaje se divide por clase y prefiere hospedajes cercanos o del mismo tipo.
- [ ] Cuando falta capacidad, se muestra un plan parcial con los no ubicados y el motivo por clase.
- [ ] Aceptar una propuesta crea las asignaciones; descartarla no cambia ningún dato.
- [ ] Una sugerencia nunca usa plazas libres de una habitación de matrimonio abierta a otros.
- [ ] Los reportes coinciden con los datos reales de la base y se exportan a CSV y XLSX.
- [ ] Importar un CSV con filas inválidas muestra los errores sin aplicar nada hasta confirmar.
- [ ] Los asistentes importados reciben sugerencia de equipo como si se registraran uno a uno.

## Fuera de alcance

- Modo global «Sugerir para todos los pendientes» (FASE-3).
- QR, cifrado y reportes completos (FASE-3).
- Integración entre APK y web (FASE-4).

## Decisiones ya tomadas (no reabrir)

- Las sugerencias solo proponen; la decisión final es del usuario.
- Pesos de puntuación y ancho de *beam search* según el plan (§4).
- Una pareja ocupa 2 plazas y nunca se separa por defecto.

## Riesgos y preguntas abiertas

- Los pesos de la puntuación pueden requerir ajuste con datos reales; deben ser configurables.
- Excel en español abre bien CSV con `;` y BOM; hay que probar con ambos sistemas.
