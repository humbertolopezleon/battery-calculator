# FASE-1 — MVP: registro, hospedaje con habitaciones, equipos, comidas y respaldo

> **Fuente:** `docs/mi-evento/PLAN.md` §3 a §7, §9, §10, §14
> **Estimación:** 12–15 semanas
> **Depende de:** FASE-0
> **Bloquea a:** FASE-2, FASE-3, FASE-4

## Objetivo

Que el primer evento real pueda gestionarse de principio a fin con un solo dispositivo, sin conexión y en español: inscribir asistentes, hospedarlos en habitaciones, asignarlos a equipos al registrarse, controlar comidas y no perder los datos. Se entrega en la APK y en la app de Windows.

## Alcance

### A. Eventos y catálogos

- Crear, editar y elegir evento (nombre, fechas, lugar, organizador, si ofrece hospedaje).
- Catálogo global de iglesias con autocompletado, provincia y municipio, y herramienta para fusionar duplicados.
- Registrar una iglesia nueva desde el propio formulario de registro.

### B. Asistentes

- Registro con nombre, primer y segundo apellido, sexo, edad, iglesia, teléfono opcional, provincia y municipio, necesita hospedaje, observaciones y acompañante responsable.
- Número de inscripción secuencial por evento, que nunca se reutiliza.
- Aviso de posible duplicado mientras se registra, con «Ver ese registro» y «Es otra persona».
- Búsqueda rápida sin distinguir tildes, edición y lista de asistentes.
- Vincular a dos asistentes como matrimonio.
- Crear grupos de asistentes que quieren estar juntos (iglesia, preferencia, familia). Un asistente pertenece como máximo a un grupo.
- En móvil, el formulario muestra arriba los campos básicos y el resto en una sección plegable «Más datos». «Necesita hospedaje» solo aparece si el evento ofrece hospedaje.
- Mensaje breve de consentimiento y marca de consentimiento del tutor para menores de 18.

### C. Hospedajes con habitaciones

- Alta de hospedaje (albergue o casa particular): nombre, contacto opcional, cómo llegar, zona y distancia opcionales.
- Habitaciones por hospedaje con nombre y capacidad, tipo fijo opcional (hombres, mujeres, matrimonio) e indicador «admite otros» para habitaciones de matrimonio. Incluye «Añadir habitación» y «Duplicar habitación».
- Asignación manual de una persona, un matrimonio o un grupo a una habitación, controlando la capacidad.
- Reglas:
  - Una habitación de hombres o de mujeres solo aloja personas de ese sexo.
  - Un matrimonio por habitación; la pareja no se separa.
  - Habitación de matrimonio sin «admite otros»: las plazas restantes quedan bloqueadas.
  - Habitación de matrimonio con «admite otros»: sin restricción ni aviso sobre quién entra, solo la capacidad.
  - Menor de 18 con alguien de distinto sexo que no es su acompañante: solo aviso.
  - Romper una regla, superar la capacidad o incumplir un tipo fijo exige confirmación explícita y queda registrado en la asignación.
- Estado visible por habitación (libre, hombres, mujeres, matrimonio) y resumen por hospedaje.
- Vista de quién está hospedado dónde y lista imprimible por hospedaje para el anfitrión. Por defecto solo nombres y cantidad de personas. PDF compartible en Android e impresión del sistema en PC.

### D. Equipos

- Crear N equipos con nombre, color opcional y capitán elegido entre los asistentes. Los rangos de edad se definen el día del evento, con la plantilla editable <13, 13–17, 18–29, 30–49 y 50+. Deben cubrir todas las edades sin huecos ni solapes.
- Sugerencia de equipo al registrar a cada persona, con motivo y botones Aceptar y Cambiar. Se puede dejar sin equipo. Orden de criterios: candidatos con tamaño mínimo o mínimo más 1; menos personas en el mismo rango de edad; menos personas del mismo sexo en ese rango; menor tamaño; orden de los equipos.
- Los capitanes forman parte del equipo pero no cuentan en el balance (edad, sexo ni tamaño).
- Asignación manual, traslado e intercambio entre equipos.
- Aviso, sin bloqueo, cuando tras una asignación, traslado o intercambio la diferencia entre el equipo con más y el de menos personas en un mismo rango supera 1, indicando rango y diferencia.
- Botón «Sugerir equipos para los ya registrados» como propuesta que el usuario revisa.
- Cambiar los rangos o añadir un equipo no mueve a nadie; el panel se recalcula y muestra un banner.
- Panel de composición por equipo: cantidad, distribución por rango y por sexo, y capitán.
- Los grupos no intervienen en los equipos.

### E. Control de comidas

- Tipos configurables (desayuno, merienda, almuerzo, cena y los que se creen) y sesiones concretas.
- Marcar que una persona pasó por búsqueda de nombre o número de inscripción con teclado numérico grande. Los resultados muestran nombre completo, iglesia y edad para distinguir homónimos.
- Aviso claro si la persona ya pasó en esa sesión. «Deshacer» marca el registro como borrado.
- Contadores en tiempo real (inscritos, pasaron, faltan) y lista de pendientes.
- Registrar desde esa misma pantalla a quien llega sin estar inscrito.
- Cierre de sesión con exportación a CSV y a imagen para WhatsApp (solo agregados, sin nombres).

### F. Respaldo, seguridad básica y ayuda

- Instantáneas automáticas rotativas (cada ~10 minutos de actividad y tras acciones importantes; se conservan las últimas 20).
- Botón «Hacer copia» siempre visible y aviso si pasaron más de 30 minutos o más de 20 cambios sin copia externa. Compartir en Android; carpeta automática en PC.
- Recordatorio al final de cada sesión de comida y de cada día.
- Exportar e importar JSON con vista previa y verificación de checksum para restaurar.
- PIN opcional al abrir o tras inactividad.
- Evento de ensayo precargado, tutorial de primer uso y aviso de WebView antiguo.
- Interfaz completa en español, siguiendo la identidad visual del diseño de referencia.

## Propuesta de división en bloques (no añade alcance)

Para `generating-tasks`, conviene dividir en estos bloques, cada uno entregando algo probable por sí solo:

1. **1a** Eventos, catálogo de iglesias y registro de asistentes (A y B sin matrimonios ni grupos).
2. **1b** Matrimonios, grupos y acompañante responsable.
3. **1c** Control de comidas (E).
4. **1d** Respaldo, restauración, PIN y modo ensayo (F).
5. **1e** Hospedajes con habitaciones, reglas y lista imprimible (C).
6. **1f** Equipos, sugerencia al registrar, avisos y panel (D).

## Criterios de aceptación

- [ ] Un asistente se registra, se edita y se encuentra por nombre (sin tildes) y por número en ambas apps.
- [ ] Al escribir nombre y apellido de alguien ya registrado aparece el aviso de duplicado.
- [ ] El número de inscripción no se reutiliza tras borrar un asistente.
- [ ] No se puede vincular a alguien en más de un matrimonio ni en más de un grupo.
- [ ] Con las reglas de §Hospedajes del plan, una asignación que las incumple pide confirmación y queda marcada; una de matrimonio abierta a otros no muestra ningún aviso sobre quién entra.
- [ ] Un matrimonio en una habitación sin «admite otros» deja bloqueadas sus plazas restantes.
- [ ] La sugerencia de equipo respeta el orden de criterios, excluye a los capitanes del balance y mantiene la diferencia de tamaño en 1 o menos.
- [ ] El aviso de equipos aparece solo cuando un rango difiere en más de 1, e indica rango y diferencia; nunca bloquea.
- [ ] Marcar a la misma persona dos veces en una sesión muestra «ya pasó» y no crea un segundo registro.
- [ ] Los contadores de comidas coinciden con el número real de registros vivos.
- [ ] El cierre de sesión exporta CSV e imagen sin nombres personales en la imagen.
- [ ] Restaurar un respaldo reproduce exactamente el evento original; un archivo alterado se rechaza.
- [ ] Con la app cerrada a la fuerza en medio del registro, no se pierde ningún registro ya guardado.
- [ ] Todo funciona sin conexión y sin cargar recursos de Internet.
- [ ] Android 7.0 o superior (con WebView actualizado) y Windows 10/11 superan una pasada completa del evento de ensayo.

## Fuera de alcance

- Sugerencia automática de hospedaje (FASE-2).
- Importación de asistentes por CSV/Excel y reportes (FASE-2).
- QR, cifrado de la base y de los respaldos, modo global de hospedaje (FASE-3).
- Integración entre APK y web, `change_log` y sincronización (FASE-4).

## Decisiones ya tomadas (no reabrir)

- Estrategia A de balanceo con rangos definidos el día del evento y sugerencia al registrar.
- Prioridad edad, luego sexo, luego tamaño; diferencia de tamaño limitada a 1.
- Capitanes fuera del balance; grupos fuera de los equipos.
- Habitaciones libres por defecto, con tipo fijo opcional.
- Sexo binario (H/M), una persona en un solo grupo, una pareja ocupa 2 plazas.

## Riesgos y preguntas abiertas

- FASE-1 concentra hospedaje y equipos. Si hay presión de fecha, cortar funciones secundarias antes que retrasar el evento.
- Reglas de habitaciones difíciles de usar en el momento: mitigadas con habitaciones libres por defecto, «Duplicar habitación» y confirmaciones en lugar de bloqueos.
- Pantallas por diseñar con el estilo del diseño de referencia (ver plan §14).
