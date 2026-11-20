# FASE-1A — Eventos, catálogo de iglesias y registro de asistentes

> **Fuente:** `docs/mi-evento/PLAN.md` §3 (Event, Church, Attendee), §7, §10, §14
> **Épica:** [FASE-1](FASE-1.md)
> **Estimación:** 3–3,5 semanas
> **Depende de:** FASE-0
> **Bloquea a:** FASE-1B, 1C, 1D, 1E, 1F

## Objetivo

Poder crear un evento e inscribir y encontrar asistentes en ambas apps. Es la base sobre la que se apoyan el resto de bloques.

## Alcance

### Eventos

- Crear, editar y elegir evento: nombre, fechas de inicio y fin, lugar, organizador y si ofrece hospedaje.
- Pantallas de selección y lista de eventos, crear y editar evento, y panel de evento con datos (existe solo la versión vacía en el diseño).

### Catálogo de iglesias

- Catálogo global con autocompletado, provincia y municipio.
- Registrar una iglesia nueva desde el propio formulario de registro.
- Herramienta para fusionar iglesias duplicadas, conservando las referencias (`merged_into_id`).
- Provincia y municipio se rellenan con los de la iglesia y pueden cambiarse. Datos de referencia estáticos de Cuba.

### Asistentes

- Registro con nombre, primer y segundo apellido, sexo, edad, iglesia, teléfono opcional, provincia y municipio, necesita hospedaje y observaciones.
- «Necesita hospedaje» solo aparece si el evento ofrece hospedaje.
- Número de inscripción secuencial por evento, que no se reutiliza nunca y se muestra tras guardar.
- Aviso de posible duplicado mientras se registra (comparación aproximada sobre nombre normalizado y primer apellido), con «Ver ese registro» y «Es otra persona».
- Búsqueda rápida sin distinguir tildes; lista de asistentes con búsqueda y filtros; detalle y edición.
- En móvil, los campos básicos van arriba (nombre, apellidos, sexo, edad, iglesia) y el resto en una sección plegable «Más datos».
- Advertencia en observaciones: «No escribas datos de salud si no es imprescindible».
- Mensaje breve de consentimiento y marca de consentimiento (`consent_at`) y de consentimiento del tutor para menores de 18.
- Botones «Guardar asistente» y «Guardar y registrar otro», y pantalla «Registro guardado» con un espacio reservado para el equipo sugerido (se rellena en FASE-1F).

## Criterios de aceptación

- [ ] Se crea, edita y elige un evento; la lista de eventos muestra solo los no archivados por defecto.
- [ ] Se registra un asistente y se le asigna un número de inscripción secuencial por evento, único.
- [ ] Tras borrar un asistente, el siguiente registro no reutiliza su número.
- [ ] Buscar «jose perez» encuentra a «José Pérez» (sin distinguir tildes ni mayúsculas) por nombre y por número.
- [ ] Registrar a alguien con el mismo nombre y primer apellido que otro muestra el aviso de duplicado y permite continuar con «Es otra persona».
- [ ] Una iglesia nueva escrita en el formulario queda en el catálogo con provincia y municipio.
- [ ] Fusionar dos iglesias reasigna sus asistentes a la que se conserva y no pierde ninguno.
- [ ] La edad fuera de 0–120 se rechaza con un mensaje claro.
- [ ] Un menor de 18 años muestra la marca de consentimiento del tutor.
- [ ] La lista de 500 asistentes se desplaza y busca con fluidez en el móvil de pruebas de FASE-0.

## Fuera de alcance

- Matrimonios, grupos y acompañante responsable (FASE-1B).
- Sugerencia de equipo (FASE-1F).
- Importación de asistentes por CSV/Excel (FASE-2).

## Decisiones ya tomadas (no reabrir)

- Personas no reutilizadas entre eventos; catálogo de iglesias global.
- Sexo binario (H/M).
- Borrado lógico, con la lápida sin datos personales.
