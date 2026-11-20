# Mi Evento — Tickets por fase

Los tickets salen de [`../PLAN.md`](../PLAN.md). Cada fase es un ticket independiente con su propia carpeta. Los criterios de aceptación y el alcance se derivan del plan; no añaden requisitos nuevos.

| Ticket | Fase | Estimación | Depende de |
|---|---|---|---|
| [FASE-0](FASE-0/FASE-0.md) | Cimientos y spikes | 2–3 semanas | — |
| [FASE-1](FASE-1/FASE-1.md) | MVP (épica, dividida en 1A a 1F) | 12–15 semanas | FASE-0 |
| ↳ [FASE-1A](FASE-1/FASE-1A.md) | Eventos, catálogo de iglesias y registro de asistentes | 3–3,5 semanas | FASE-0 |
| ↳ [FASE-1D](FASE-1/FASE-1D.md) | Respaldo, restauración, PIN, modo ensayo y ayuda | 1,5–2 semanas | FASE-1A |
| ↳ [FASE-1B](FASE-1/FASE-1B.md) | Matrimonios, grupos y acompañante responsable | 1–1,5 semanas | FASE-1A |
| ↳ [FASE-1C](FASE-1/FASE-1C.md) | Control de comidas | 2 semanas | FASE-1A |
| ↳ [FASE-1E](FASE-1/FASE-1E.md) | Hospedajes con habitaciones, reglas y lista imprimible | 2,5–3 semanas | FASE-1A, 1B |
| ↳ [FASE-1F](FASE-1/FASE-1F.md) | Equipos, sugerencia al registrar, avisos y panel | 2–3 semanas | FASE-1A |
| [FASE-2](FASE-2/FASE-2.md) | Sugerencia de hospedaje, reportes básicos, importación CSV/Excel | 5–6 semanas | FASE-1 |
| [FASE-3](FASE-3/FASE-3.md) | QR, cifrado, reportes completos, modo global de hospedaje | 4–5 semanas | FASE-2 |
| [FASE-4](FASE-4/FASE-4.md) | Integración entre la APK y la web | 4–6 semanas | FASE-1 (formato), FASE-3 recomendado |

Total estimado: 27–35 semanas, con un margen de ±30 %.

## Estado de la cadena de revisión

Ningún ticket tiene todavía sello de revisión humana (`REVIEW-LOG.md`). Antes de planificar o generar tareas de cada ticket, hay que recorrer la cadena `/picking-up-task` → `/planning-from-spec` → `/generating-tasks` sobre su ticket.

## Nota sobre FASE-1

FASE-1 es una épica sin alcance propio; el alcance está en los seis tickets 1A a 1F. La letra identifica el bloque, no el orden. Orden recomendado: 1A, 1D, 1B, 1C, 1E, 1F (ver `FASE-1/FASE-1.md`).
