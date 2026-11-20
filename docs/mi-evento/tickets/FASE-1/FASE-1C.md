# FASE-1C — Control de comidas

> **Fuente:** `docs/mi-evento/PLAN.md` §3 (ControlType, ControlSession, ControlRecord), §6, §14
> **Épica:** [FASE-1](FASE-1.md)
> **Estimación:** 2 semanas
> **Depende de:** FASE-1A
> **Bloquea a:** nada dentro de la épica

## Objetivo

Marcar de forma rápida quién pasó a cada comida u otro control, avisar claramente si ya pasó, ver los contadores en tiempo real y cerrar la sesión con estadísticas que se puedan compartir.

## Alcance

- Tipos de control configurables (desayuno, merienda, almuerzo, cena y los que se creen, por ejemplo entrega de materiales o taller).
- Crear sesiones concretas, por ejemplo «Almuerzo del sábado», con fecha y estado (abierta o cerrada).
- Marcar que una persona pasó por **búsqueda de nombre** o **número de inscripción**, con teclado numérico grande. Los resultados muestran nombre completo, iglesia y edad para distinguir homónimos.
- Aviso claro si la persona ya pasó en esa sesión, sin crear un segundo registro.
- «Deshacer» el último marcado.
- Contadores en tiempo real: inscritos, pasaron y faltan, con lista de pendientes.
- Registrar desde esta pantalla a quien llega sin estar inscrito.
- Cierre de sesión: instantánea de los totales (`summary_json`) y exportación a **CSV** y a **imagen para WhatsApp**.
- La imagen se dibuja con Canvas 2D (1080×1350) esperando a que carguen las fuentes, y contiene solo agregados, sin nombres. Se comparte con el menú del sistema en Android y se guarda en PC.
- Pantallas por diseñar: resultados con varios homónimos, lista de pendientes, tipos y sesiones, y cierre en versión móvil.

## Criterios de aceptación

- [ ] Marcar a una persona crea un registro y actualiza los contadores al instante.
- [ ] Marcar a la misma persona dos veces en una sesión muestra «ya pasó» y no crea un segundo registro, ni siquiera tras «Deshacer» y volver a marcar si el primero sigue vivo.
- [ ] «Deshacer» marca el registro como borrado y la persona vuelve a pendientes.
- [ ] Dos asistentes homónimos se distinguen en los resultados por iglesia y edad.
- [ ] Buscar por número de inscripción encuentra exactamente a esa persona.
- [ ] Registrar en la misma pantalla a alguien no inscrito lo añade al evento y lo marca como que pasó.
- [ ] Los contadores coinciden con el número real de registros vivos.
- [ ] El CSV del cierre se abre bien en Excel en español (UTF-8 con BOM y `;`).
- [ ] La imagen exportada no contiene nombres personales.
- [ ] Una sesión cerrada conserva su instantánea aunque cambien los datos después.

## Fuera de alcance

- Lectura y generación de QR (FASE-3).
- Exportación a Excel (XLSX) en el cierre. Esta fase exporta CSV e imagen.
- Reportes generales (FASE-2).

## Decisiones ya tomadas (no reabrir)

- Identificación en el MVP: nombre y número de inscripción. QR en FASE-3.
- La imagen de WhatsApp se dibuja con Canvas 2D, no capturando el DOM.
