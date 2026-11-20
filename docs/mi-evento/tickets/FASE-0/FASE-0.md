# FASE-0 — Cimientos y spikes

> **Fuente:** `docs/mi-evento/PLAN.md` §2 (Stack), §3 (Modelo de datos), §9 (Respaldo), §10 (Privacidad), §11 (Distribución), §12 (Riesgos)
> **Estimación:** 2–3 semanas
> **Depende de:** nada
> **Bloquea a:** FASE-1

## Objetivo

Dejar lista la base técnica compartida por la APK y la app de Windows, y despejar los riesgos que podrían cambiar el stack antes de invertir en el MVP. Al terminar, existe un monorepo que compila las dos apps con un esquema de datos compartido, y hay evidencia real sobre WebView en móviles viejos, Tauri y SQLite.

## Alcance

### Monorepo y `core`

- Estructura `packages/core`, `packages/ui`, `apps/shell-android` (Capacitor), `apps/shell-desktop` (Tauri 2).
- `packages/core` en TypeScript puro, sin dependencias de UI ni de plataforma.
- Interfaz `Repository` con dos adaptadores: `@capacitor-community/sqlite` y el plugin SQL de Tauri.
- Esquema SQL del modelo de datos (§3 del plan) y sistema de migraciones con `schema_version`.
- Columnas base en todas las tablas sincronizables: `id` (UUID v7), `created_at`, `updated_at`, `deleted_at`, `rev`, `device_id`.
- Generación de IDs con la librería `uuid` v7, sin `crypto.randomUUID()`.
- Formato de exportación e importación JSON versionado con checksum SHA-256, con verificación y conteos.
- Datos de referencia estáticos: provincias y municipios de Cuba.

### UI base

- `packages/ui` con los tokens del diseño de referencia (colores, tipografía, tamaños de botón, esquinas de 12 px, sin sombras ni degradados).
- Fuentes Nunito y Atkinson Hyperlegible empaquetadas en local (WOFF2 con subconjunto latino) y caída a fuente del sistema.
- Componentes mínimos para validar el estilo: botón, campo con etiqueta, tarjeta y mensaje de estado.

### Compilación y distribución

- CI que genera la APK (universal, firmada) y el instalador de Windows (por usuario, sin administrador) más un `.exe` portable.
- Build con `build.target` bajo (ES2017 o menos) para WebViews viejos.

### Spikes (cada uno debe terminar con una conclusión escrita)

1. **WebView en móviles viejos:** probar la APK en 2 o 3 móviles reales con Android 7.0 o superior y poca RAM. Medir arranque, fluidez de la lista de 500 asistentes y la búsqueda. Verificar que se detecta un WebView anterior a Chrome 61 y se avisa al usuario.
2. **Tauri en Windows 10/11:** compilar, instalar sin permisos de administrador y abrir SQLite con el archivo de datos visible. Comprobar el comportamiento sin WebView2 (instalador slim frente al completo).
3. **SQLite en Capacitor:** transacciones, recuperación tras cerrar la app a la fuerza, y mismo esquema que en Tauri.
4. **Permiso INTERNET:** comprobar si la APK de release funciona sin declarar el permiso INTERNET.
5. **Respaldo en Android 10+:** determinar dónde puede escribir una copia automática y si hace falta depender solo del botón «Compartir».
6. **Imagen de WhatsApp:** prototipo con Canvas 2D (1080×1350) esperando `document.fonts.load()`, y compartir con el menú del sistema.

## Criterios de aceptación

- [ ] `core` compila sin dependencias de UI y sus pruebas (Vitest) pasan.
- [ ] Un evento con datos de prueba se exporta a JSON y se importa de nuevo sin pérdida, y el checksum detecta un archivo alterado.
- [ ] Las migraciones llevan una base vacía a la versión actual y están cubiertas por pruebas.
- [ ] La misma suite de pruebas del `Repository` pasa con ambos adaptadores (SQLite en Capacitor y en Tauri), o queda documentada la diferencia.
- [ ] El CI produce una APK firmada y un instalador de Windows descargables como artefactos.
- [ ] La app arranca sin conexión y sin cargar fuentes de Internet.
- [ ] Cada spike tiene un informe corto en `docs/mi-evento/spikes/` con la conclusión y, si cambia una decisión del plan, la propuesta de cambio.
- [ ] Existe una decisión escrita sobre si Capacitor es viable para la gama baja objetivo, o si se pasa a Kotlin nativo para la APK.

## Fuera de alcance

- Pantallas o flujos de negocio (registro, comidas, hospedaje, equipos).
- Algoritmos de hospedaje y de equipos.
- Cifrado, QR, sincronización o importación de CSV/Excel.
- Certificado de firma de código para Windows.

## Decisiones ya tomadas (no reabrir)

- Base web TypeScript/React con Capacitor y Tauri 2. PWA como plan B.
- SQLite nativo por plataforma tras una interfaz `Repository`.
- Android 7.0 (API 24) como mínimo recomendado, con WebView ≥ Chrome 61 (Chrome 60 trae los módulos ES desactivados).
- IDs UUID v7, marcas de tiempo en epoch ms UTC, borrado lógico.

## Riesgos y preguntas abiertas

- Si el spike de WebView falla en gama baja, la APK pasa a Kotlin nativo y `core` debe seguir siendo reutilizable. Esa decisión sale de este ticket.
- Curva de Rust y de compilación de Tauri. Plan B: Electron o PWA.
- Dónde guardar de forma segura la keystore de la APK. Hay que guardarla en al menos dos sitios.
