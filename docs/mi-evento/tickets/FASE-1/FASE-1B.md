# FASE-1B — Matrimonios, grupos y acompañante responsable

> **Fuente:** `docs/mi-evento/PLAN.md` §3 (Couple, Group, GroupMember, Attendee.guardian_id), §4 (reglas de menores), §14
> **Épica:** [FASE-1](FASE-1.md)
> **Estimación:** 1–1,5 semanas
> **Depende de:** FASE-1A
> **Bloquea a:** FASE-1E

## Objetivo

Registrar los vínculos entre asistentes que luego usa el hospedaje: parejas, grupos que quieren estar juntos y quién acompaña a un menor.

## Alcance

### Matrimonios

- Vincular a dos asistentes del mismo evento como matrimonio, desde el formulario de registro («Vincular matrimonio») y desde el detalle.
- Deshacer el vínculo.
- Una persona pertenece como máximo a un matrimonio, y la pareja nunca puede ser la misma persona.

### Grupos

- Crear grupos de asistentes que desean estar juntos, con nombre y tipo (iglesia, preferencia, familia) e iglesia opcional.
- Añadir y quitar miembros desde el formulario («Añadir a un grupo») y desde la pantalla de grupos.
- Una persona pertenece como máximo a un grupo.
- Pantalla para crear y gestionar grupos.

### Acompañante responsable

- Campo opcional «Acompañante responsable» en el registro: apunta a otro asistente del mismo evento.
- Se destaca para menores de 18 años, pero puede rellenarse para cualquiera.

## Criterios de aceptación

- [ ] No se puede vincular a una persona en más de un matrimonio, ni consigo misma.
- [ ] No se puede añadir a una persona a más de un grupo.
- [ ] Deshacer un matrimonio o quitar a alguien de un grupo no borra a la persona.
- [ ] Borrar a un asistente deshace su matrimonio y lo quita de su grupo, y el acompañante responsable de otros queda vacío.
- [ ] El acompañante responsable solo puede ser un asistente del mismo evento.
- [ ] Los vínculos aparecen en el detalle de cada asistente y se incluyen en la exportación y la restauración.

## Fuera de alcance

- Cualquier lógica de hospedaje o de equipos que use estos vínculos (FASE-1E, FASE-1F).
- Los grupos no intervienen en los equipos.

## Decisiones ya tomadas (no reabrir)

- Una persona en un solo grupo.
- Los matrimonios no ligan a las personas en los equipos.
- Menor de 18: solo aviso, nunca bloqueo.
