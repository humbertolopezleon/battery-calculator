# FASE-1E — Hospedajes con habitaciones, reglas y lista imprimible

> **Fuente:** `docs/mi-evento/PLAN.md` §3 (Lodging, Room, LodgingAssignment), §4 (reglas, vistas y salidas), §14
> **Épica:** [FASE-1](FASE-1.md)
> **Estimación:** 2,5–3 semanas
> **Depende de:** FASE-1A, FASE-1B
> **Bloquea a:** FASE-2

## Objetivo

Registrar hospedajes con sus habitaciones, asignar asistentes a mano respetando las reglas, ver quién está dónde y entregar a cada anfitrión su lista. La sugerencia automática llega en FASE-2.

## Alcance

### Hospedajes y habitaciones

- Alta de hospedaje (albergue o casa particular): nombre, número de contacto opcional, dirección o cómo llegar, zona y distancia opcionales.
- Habitaciones por hospedaje con nombre y capacidad. Tipo fijo opcional (hombres, mujeres o matrimonio) e indicador «admite otros» para las de matrimonio. Habitaciones libres por defecto.
- «Añadir habitación» y «Duplicar habitación» para cargar rápido varias iguales. Activar o desactivar habitaciones.
- Un hospedaje sin habitaciones no puede recibir asignaciones y la app lo indica.

### Asignación manual

- Asignar una persona, un matrimonio o un grupo a una habitación, controlando la capacidad.
- Estado visible por habitación (libre, hombres, mujeres, matrimonio) y resumen por hospedaje, por ejemplo «2 habitaciones · 1 libre · 1 de hombres con 1 plaza libre».
- Al quedar vacía, una habitación sin tipo fijo vuelve a «Libre».
- Cada asignación registra su origen (manual) y los avisos aceptados (`warnings_json`).

### Reglas

- Una habitación de hombres o de mujeres solo aloja personas de ese sexo.
- Máximo un matrimonio por habitación; la pareja no se separa.
- Habitación de matrimonio sin «admite otros»: las plazas restantes quedan **bloqueadas por el matrimonio** y cuentan como ocupadas.
- Habitación de matrimonio con «admite otros»: **sin restricción ni aviso** sobre quién entra, solo la capacidad.
- Menor de 18 años con alguien de distinto sexo que no es su acompañante responsable: solo aviso.
- Romper una regla, superar la capacidad o incumplir un tipo fijo exige confirmación explícita y queda registrado.
- Alertas de sobreasignación si se reduce la capacidad de una habitación ocupada, sin mover a nadie solo.
- Fijar un tipo en una habitación con ocupantes incompatibles se rechaza o avisa con la lista de afectados.

### Vistas y salidas

- Vista de quién está hospedado dónde, por hospedaje y por habitación.
- Lista imprimible por hospedaje para el anfitrión. Por defecto solo nombres y cantidad de personas, sin edad, teléfono ni observaciones. PDF compartible en Android (`pdf-lib` con la fuente embebida) e impresión del sistema en PC.
- Pantallas por diseñar: lista de hospedajes, alta con habitaciones, vista del hospedaje con ocupantes, asignación manual y lista imprimible.

## Criterios de aceptación

- [ ] Se crea un hospedaje con varias habitaciones y se duplica una habitación en un paso.
- [ ] Asignar un hombre a una habitación de mujeres pide confirmación y queda marcado en `warnings_json`.
- [ ] Un segundo matrimonio en una habitación que ya tiene uno pide confirmación.
- [ ] Un matrimonio en una habitación de 4 plazas sin «admite otros» deja las otras 2 plazas bloqueadas, y no se pueden asignar sin confirmación.
- [ ] En una habitación de matrimonio con «admite otros» se puede asignar a cualquier persona sin ningún aviso sobre sexo.
- [ ] Un menor con un adulto de distinto sexo que no es su acompañante muestra un aviso y nunca bloquea.
- [ ] Superar la capacidad pide confirmación explícita.
- [ ] Una habitación sin tipo fijo vuelve a «Libre» al quedar vacía.
- [ ] Reducir la capacidad por debajo de los ocupantes muestra la alerta y no mueve a nadie.
- [ ] La lista del anfitrión no incluye edad, teléfono ni observaciones por defecto.
- [ ] Todas las asignaciones, habitaciones y avisos aceptados se incluyen en la exportación y la restauración.

## Fuera de alcance

- Sugerencia automática y modo global de hospedaje (FASE-2 y FASE-3).
- Reportes por hospedaje (FASE-2).

## Decisiones ya tomadas (no reabrir)

- Cualquier hospedaje puede recibir las tres categorías; la capacidad se define por habitaciones.
- Habitaciones libres por defecto, con tipo fijo opcional.
- Una pareja ocupa 2 plazas y nunca se separa.
- Una persona en un solo grupo.
