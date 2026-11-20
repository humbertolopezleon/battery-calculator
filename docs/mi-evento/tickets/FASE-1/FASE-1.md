# FASE-1 — MVP (épica)

> **Fuente:** `docs/mi-evento/PLAN.md` §3 a §7, §9, §10, §14
> **Estimación total:** 12–15 semanas
> **Depende de:** FASE-0
> **Bloquea a:** FASE-2, FASE-3, FASE-4

## Objetivo

Que el primer evento real pueda gestionarse de principio a fin con un solo dispositivo, sin conexión y en español: inscribir asistentes, hospedarlos en habitaciones, asignarlos a equipos al registrarse, controlar comidas y no perder los datos. Se entrega en la APK y en la app de Windows.

Esta épica no tiene alcance propio: se divide en seis tickets, cada uno entregable y comprobable por separado.

## Tickets

| Ticket | Contenido | Estimación | Depende de |
|---|---|---|---|
| [FASE-1A](FASE-1A.md) | Eventos, catálogo de iglesias y registro de asistentes | 3–3,5 semanas | FASE-0 |
| [FASE-1D](FASE-1D.md) | Respaldo, restauración, PIN, modo ensayo y ayuda | 1,5–2 semanas | FASE-1A |
| [FASE-1B](FASE-1B.md) | Matrimonios, grupos y acompañante responsable | 1–1,5 semanas | FASE-1A |
| [FASE-1C](FASE-1C.md) | Control de comidas | 2 semanas | FASE-1A |
| [FASE-1E](FASE-1E.md) | Hospedajes con habitaciones, reglas y lista imprimible | 2,5–3 semanas | FASE-1A, FASE-1B |
| [FASE-1F](FASE-1F.md) | Equipos, sugerencia al registrar, avisos y panel | 2–3 semanas | FASE-1A |

La letra identifica el bloque, no el orden de ejecución.

## Orden de ejecución recomendado

1. **1A**: base de todo lo demás.
2. **1D**: el respaldo y la restauración se construyen pronto, para proteger los datos de prueba desde el principio y para que cada bloque posterior los incluya en la exportación.
3. **1B**: matrimonios y grupos, que necesita 1E.
4. **1C**: control de comidas.
5. **1E**: hospedajes.
6. **1F**: equipos.

1C, 1E y 1F son independientes entre sí. El orden se puede cambiar según lo que el primer evento necesite antes.

## Criterios de aceptación transversales

Se comprueban al cerrar la épica, con el evento de ensayo de FASE-1D:

- [ ] Todo funciona sin conexión y sin cargar recursos de Internet.
- [ ] Android 7.0 o superior (con WebView actualizado) y Windows 10/11 superan una pasada completa del evento de ensayo.
- [ ] La interfaz está completa en español y sigue la identidad visual del diseño de referencia.
- [ ] Exportar y restaurar un evento reproduce exactamente todas las entidades de los seis bloques.
- [ ] Con la app cerrada a la fuerza en medio del registro, no se pierde ningún registro ya guardado.

## Fuera de alcance de toda la épica

- Sugerencia automática de hospedaje, reportes básicos e importación CSV/Excel (FASE-2).
- QR, cifrado de la base y de los respaldos, modo global de hospedaje (FASE-3).
- Integración entre APK y web, `change_log` y sincronización (FASE-4).

## Decisiones ya tomadas (no reabrir)

- Estrategia A de balanceo con rangos definidos el día del evento y sugerencia al registrar.
- Prioridad edad, luego sexo, luego tamaño; diferencia de tamaño limitada a 1.
- Capitanes fuera del balance; grupos fuera de los equipos.
- Habitaciones libres por defecto, con tipo fijo opcional.
- Sexo binario (H/M), una persona en un solo grupo, una pareja ocupa 2 plazas.

## Riesgos

- Esta épica concentra hospedaje y equipos. Si hay presión de fecha, cortar funciones secundarias antes que retrasar el evento.
- Pantallas por diseñar con el estilo del diseño de referencia (ver plan §14).
