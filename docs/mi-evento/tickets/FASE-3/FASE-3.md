# FASE-3 — QR, cifrado, reportes completos y modo global de hospedaje

> **Fuente:** `docs/mi-evento/PLAN.md` §4 (modo global), §6, §7, §10
> **Estimación:** 4–5 semanas
> **Depende de:** FASE-2
> **Bloquea a:** nada (FASE-4 la recomienda como base)

## Objetivo

Acelerar el control de comidas con códigos QR, proteger los datos personales con cifrado y completar los reportes y la asignación automática de hospedaje a nivel de evento.

## Alcance

### QR

- Generar un QR por asistente (con `qrcode`) y compartirlo por WhatsApp como imagen.
- Leer QR en el control de comidas con `qr-scanner` y la cámara del móvil o la webcam de la PC, sin conexión.
- La búsqueda por nombre y número sigue disponible como respaldo.
- Lector de QR con la identidad visual del diseño de referencia.

### Cifrado

- Cifrado de la base de datos con SQLCipher, con la clave guardada en Android Keystore en la APK y su equivalente en Windows.
- Respaldos con contraseña opcional (WebCrypto AES-GCM).
- La restauración de un respaldo cifrado pide la contraseña y rechaza una incorrecta sin dañar datos.

### Reportes completos

- Totales por sexo, rango de edad, iglesia, hospedaje y equipo, con los cruces que se necesiten.
- Listados exportables e imprimibles con selector de campos y valores por defecto que minimizan datos (por ejemplo, solo nombres y cantidad de personas para el anfitrión).

### Modo global de hospedaje

- «Sugerir para todos los pendientes»: ordena primero lo más restringido (grupos grandes, parejas y el sexo con menos plazas) y mejora el resultado con intercambios de búsqueda local.
- Se presenta como una única propuesta con aceptación por fila.
- Usa las mismas reglas duras que la sugerencia de FASE-2.

## Criterios de aceptación

- [ ] Un QR generado para un asistente, al leerse en una sesión de comida, identifica a esa persona y marca que pasó; si ya pasó, muestra «ya pasó».
- [ ] La lectura de QR funciona en la APK y en la app de Windows sin conexión.
- [ ] Con el cifrado activo, el archivo de base de datos no es legible sin la clave.
- [ ] Un respaldo cifrado se restaura solo con la contraseña correcta; con una incorrecta se rechaza sin cambiar ningún dato.
- [ ] Los reportes coinciden con los datos reales y respetan el selector de campos.
- [ ] El modo global no incumple las reglas duras y deja sin asignar lo que no cabe, indicando el motivo.
- [ ] El modo global no modifica asignaciones existentes ni crea ninguna sin aceptación del usuario.

## Fuera de alcance

- Sincronización y fusión entre dispositivos (FASE-4).
- Cualquier servicio en la nube.

## Decisiones ya tomadas (no reabrir)

- QR no entra en el MVP; se genera y se envía por WhatsApp, y se lee con la cámara del dispositivo.
- Todo local, sin nube ni telemetría.
- Las sugerencias solo proponen; la decisión es del usuario.

## Riesgos y preguntas abiertas

- Rendimiento de la lectura de QR en móviles de gama baja y con poca luz.
- Gestión de la contraseña de respaldos: no hay recuperación si se pierde; debe advertirse al activarla.
- SQLCipher en Tauri: confirmar la viabilidad (en caso contrario, cifrado a nivel de aplicación).
