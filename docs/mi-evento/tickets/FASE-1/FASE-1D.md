# FASE-1D — Respaldo, restauración, PIN, modo ensayo y ayuda

> **Fuente:** `docs/mi-evento/PLAN.md` §9 (Respaldo), §10 (Privacidad), §11 (Capacitación), §14
> **Épica:** [FASE-1](FASE-1.md)
> **Estimación:** 1,5–2 semanas
> **Depende de:** FASE-1A
> **Bloquea a:** nada dentro de la épica

## Objetivo

Que la información no se pierda si falla el dispositivo, que solo la vea quien debe y que los voluntarios puedan practicar antes del evento. La exportación debe incluir todas las entidades de la épica según se vayan añadiendo.

## Alcance

### Respaldo

- Instantáneas automáticas rotativas cada ~10 minutos de actividad y tras acciones importantes (cerrar una sesión de comida, terminar un lote de registros). Se conservan las últimas 20 dentro de la app.
- Botón «Hacer copia» siempre visible.
- Aviso si pasaron más de 30 minutos o más de 20 cambios sin copia externa.
- En Android, compartir el archivo (WhatsApp, Bluetooth, memoria). En PC, carpeta automática `Documentos/MiEvento/Respaldos` y, si el usuario lo elige, una segunda carpeta o USB.
- Recordatorio al final de cada sesión de comida y de cada día.
- Nombre de archivo con evento, fecha y hora, por ejemplo `MiEvento_RetiroJovenes2026_2026-12-13_1452.mievento.json`.
- Lo que defina el spike de FASE-0 sobre dónde puede escribirse en Android 10 o superior.

### Restauración

- Importar el JSON verificando el checksum y los conteos, con vista previa antes de aplicar.
- Un archivo alterado se rechaza.

### Seguridad y privacidad básicas

- PIN opcional al abrir y tras inactividad.
- Aviso al compartir copias: contienen todo y deben enviarse solo a organizadores de confianza.
- Función «Cerrar evento y borrar datos personales» que conserva solo estadísticas agregadas, con recordatorio pasado un plazo configurable.
- Selector de campos en las exportaciones, con valores por defecto que minimizan datos.

### Modo ensayo y ayuda

- Evento de ensayo precargado para practicar.
- Tutorial de primer uso.
- Aviso de WebView antiguo al iniciar.
- Lista de comprobación de «antes del evento» (cargar hospedajes, definir equipos y rangos, hacer copia, cargar la batería).
- Pantallas de respaldo, restaurar, ajustes (PIN, copias), bloqueo, onboarding y ayuda por diseñar.

## Criterios de aceptación

- [ ] Se crea una instantánea automática tras ~10 minutos de actividad y tras cerrar una sesión de comida, y solo se conservan las últimas 20.
- [ ] El aviso de copia externa aparece tras 30 minutos o 20 cambios sin copia.
- [ ] Restaurar una copia reproduce exactamente el evento original.
- [ ] Un archivo con el checksum alterado se rechaza sin cambiar ningún dato.
- [ ] La vista previa de restauración muestra los conteos por entidad antes de aplicar.
- [ ] El PIN se pide al abrir y tras inactividad, y un PIN incorrecto no da acceso.
- [ ] Borrar los datos personales de un evento elimina nombres, teléfonos y observaciones, y conserva las estadísticas agregadas.
- [ ] El evento de ensayo se puede usar sin afectar a un evento real.
- [ ] Con WebView anterior a Chrome 61, la app lo avisa al iniciar.

## Fuera de alcance

- Cifrado de la base de datos y de los respaldos (FASE-3).
- Traspaso y fusión entre dispositivos (FASE-4).
- Copia automática a la nube.

## Decisiones ya tomadas (no reabrir)

- Todo local: sin nube, sin telemetría, sin analíticas.
- Respaldo en capas: transacciones, instantáneas rotativas, copia externa y restauración verificada.
- El permiso INTERNET se intenta omitir en la APK final, según lo que concluya FASE-0.
