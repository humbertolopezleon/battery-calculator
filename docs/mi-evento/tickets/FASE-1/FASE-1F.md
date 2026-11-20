# FASE-1F — Equipos, sugerencia al registrar, avisos y panel

> **Fuente:** `docs/mi-evento/PLAN.md` §3 (Team, TeamMembership, TeamMove, Event.age_ranges), §5 (Equipos), §14
> **Épica:** [FASE-1](FASE-1.md)
> **Estimación:** 2–3 semanas
> **Depende de:** FASE-1A
> **Bloquea a:** nada dentro de la épica

## Objetivo

Que cada persona reciba una sugerencia de equipo en el momento de registrarse, y que el usuario pueda mover gente y ver el balance con avisos claros pero sin bloqueos.

## Alcance

### Configuración

- Crear N equipos con nombre, color opcional y capitán elegido entre los asistentes.
- Rangos de edad definidos el día del evento, con la plantilla editable <13, 13–17, 18–29, 30–49 y 50+. Deben cubrir todas las edades, sin huecos ni solapes.
- Pantalla de configuración de equipos y rangos.

### Sugerencia al registrar

Función pura en `core`: `suggestTeam(persona, equipos, rangos) → { team, reason }`.

- Candidatos: solo los equipos cuyo tamaño sea el mínimo o el mínimo más 1.
- Entre ellos, orden de criterios: menos personas en el mismo rango de edad; menos personas del mismo sexo en ese rango; menor tamaño; orden de los equipos.
- Motivo en español, por ejemplo «Rojo es el equipo con menos jóvenes de 13–17 años: tiene 3 y los otros 4».
- La pantalla «Registro guardado» muestra el equipo sugerido con Aceptar y Cambiar. Se puede dejar sin equipo.
- Botón «Sugerir equipos para los ya registrados»: procesa en orden de inscripción con la misma regla y se presenta como propuesta que el usuario revisa.

### Capitanes

- Forman parte del equipo pero no cuentan en el balance (edad, sexo ni tamaño).
- Designar capitán a alguien de otro equipo pide confirmar el traslado.
- Designar capitán a alguien que ya contaba lo saca de los contadores y recalcula el panel.

### Movimientos y avisos

- Asignación manual, traslado e intercambio entre equipos, con historial (`TeamMove`).
- Aviso sin bloqueo cuando, tras una asignación, traslado o intercambio, la diferencia entre el equipo con más y el de menos personas en un mismo rango supera 1, indicando rango y diferencia, por ejemplo «Rango 13–17: Rojo quedaría con 5 y Azul con 3 (diferencia 2)». El usuario puede continuar.
- El sexo y el tamaño se muestran en el panel sin generar aviso.

### Cambios posteriores

- Cambiar los rangos con gente ya registrada no mueve a nadie: el panel se recalcula y muestra un banner con los equipos desbalanceados.
- Añadir un equipo no mueve a nadie: pasa a ser el de menor tamaño y recibe las siguientes sugerencias.
- Editar la edad y cambiar de rango recalcula el panel y, si hay desbalance, muestra el aviso.

### Panel de composición

- Por equipo: cantidad de integrantes, distribución por rango y por sexo, y capitán.
- Panel de composición por rango, traslado en PC e intercambio por diseñar.

## Criterios de aceptación

- [ ] Dado un conjunto de equipos y asistentes, `suggestTeam` elige el equipo según el orden de criterios y el resultado es siempre el mismo para la misma entrada.
- [ ] Nunca sugiere un equipo con tamaño superior al mínimo más 1.
- [ ] Un capitán no cuenta en los contadores por rango, por sexo ni de tamaño.
- [ ] Un traslado o intercambio que deja un rango con diferencia mayor que 1 muestra el aviso con rango y diferencia, y permite continuar.
- [ ] Una acción que deja todos los rangos con diferencia de 1 o menos no muestra aviso.
- [ ] Cambiar los rangos o añadir un equipo no cambia la membresía de nadie.
- [ ] «Sugerir equipos para los ya registrados» no cambia nada hasta que el usuario confirma.
- [ ] Una edad sin rango (rangos con huecos) se rechaza al guardar la configuración.
- [ ] Los grupos y los matrimonios no condicionan la sugerencia de equipo.
- [ ] Equipos, membresías, movimientos y rangos se incluyen en la exportación y la restauración.

## Fuera de alcance

- Reparto automático por lotes con optimización estadística (descartado en el diseño).
- Umbrales de aviso configurables.
- Avisos por sexo o por tamaño.

## Decisiones ya tomadas (no reabrir)

- Estrategia A (rangos de edad por sexo) con rangos definidos el día del evento.
- Prioridad edad, luego sexo, luego tamaño; diferencia de tamaño limitada a 1.
- Capitanes fuera del balance. Grupos fuera de los equipos.
- Avisos solo por rangos de edad con diferencia mayor que 1.
