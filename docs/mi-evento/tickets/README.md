# Mi Evento — Tickets por fase

Los tickets salen de [`../PLAN.md`](../PLAN.md). Cada fase es un ticket independiente con su propia carpeta. Los criterios de aceptación y el alcance se derivan del plan; no añaden requisitos nuevos.

| Ticket | Fase | Estimación | Depende de |
|---|---|---|---|
| [FASE-0](FASE-0/FASE-0.md) | Cimientos y spikes | 2–3 semanas | — |
| [FASE-1](FASE-1/FASE-1.md) | MVP: registro, hospedaje con habitaciones, equipos, comidas y respaldo | 12–15 semanas | FASE-0 |
| [FASE-2](FASE-2/FASE-2.md) | Sugerencia de hospedaje, reportes básicos, importación CSV/Excel | 5–6 semanas | FASE-1 |
| [FASE-3](FASE-3/FASE-3.md) | QR, cifrado, reportes completos, modo global de hospedaje | 4–5 semanas | FASE-2 |
| [FASE-4](FASE-4/FASE-4.md) | Integración entre la APK y la web | 4–6 semanas | FASE-1 (formato), FASE-3 recomendado |

Total estimado: 27–35 semanas, con un margen de ±30 %.

## Estado de la cadena de revisión

Ningún ticket tiene todavía sello de revisión humana (`REVIEW-LOG.md`). Antes de planificar o generar tareas de cada fase, hay que recorrer la cadena `/picking-up-task` → `/planning-from-spec` → `/generating-tasks` sobre su ticket.

## Nota sobre el tamaño de FASE-1

FASE-1 abarca 12–15 semanas. Al llegar a `generating-tasks` conviene dividirla en bloques (ver la propuesta dentro del propio ticket) y no tratarla como una sola tarea.
