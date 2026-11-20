# PLAN-FASE-0 — Cimientos y spikes

> **Ticket:** `docs/mi-evento/tickets/FASE-0/FASE-0.md`
> **Rama:** `feat/FASE-0/cimientos-y-spikes`
> **Fuente funcional:** `docs/mi-evento/PLAN.md` §2, §3, §9, §10, §11, §12

## Objetivo

Crear en `mi-evento/` un monorepo npm que compila la web compartida y las dos cáscaras (Capacitor para Android y Tauri para Windows), con un `core` en TypeScript puro que contiene el esquema SQL, las migraciones, el `Repository` y la exportación e importación JSON con checksum. Lo acompañan un `ui` con los tokens del diseño y las fuentes locales, un CI de GitHub Actions y un banco de pruebas para los seis spikes. Los informes de los spikes los completa el desarrollador midiendo en dispositivos reales.

## Hallazgos clave

| Hallazgo | Consecuencia |
|---|---|
| La raíz del repo es Battery Calculator, con su propio `package.json`, `build.js` y pruebas | El monorepo vive en `mi-evento/` y no toca nada de la raíz. |
| Capacitor 8.6.2: `minSdkVersion = 24`, WebView mínima por defecto 60 (`android.minWebViewVersion`), suelo 55, Node ≥ 22 | Confirma Android 7.0 y Chrome 60 del plan. Se fija `minWebViewVersion: 60` de forma explícita. |
| `tauri-plugin-sql` 2.6.0 está sobre un pool de conexiones y su código no menciona transacciones | Una transacción entre llamadas JS no queda garantizada en una sola conexión. Se usan comandos Rust propios con `rusqlite`. |
| Entorno de esta sesión: Node 22.23, Rust 1.97, gcc 13 y `node:sqlite`. No hay Android SDK ni `webkit2gtk` | `core`, `ui`, la web y el crate de SQLite se verifican aquí. La APK, el instalador de Windows y los spikes no. |
| Atkinson Hyperlegible 400 y 700 ya existen en `src/fonts`. Nunito solo está en `@fontsource/nunito` 5.3.0 | Las cuatro fuentes se copian de `@fontsource` (licencia OFL) para que `ui` sea independiente. |
| No hay ningún PR relacionado con FASE-0 | Plan de construcción, no de revisión. |
| Contraste del diseño verificado: todos los pares de texto ≥ 5,37 y el borde de campo `#8A93A3` sobre blanco da 3,10 | Los tokens del diseño cumplen. Un test lo mantiene. |

## Decisiones

| # | Decisión | Motivo |
|---|---|---|
| D1 | Workspace npm en `mi-evento/` con `packages/core`, `packages/ui`, `apps/web`, `apps/shell-android`, `apps/shell-desktop` | Elección del desarrollador. |
| D2 | Se añade `apps/web`: una app Vite con React que sirve de banco de pruebas | Ambas cáscaras necesitan un bundle web. Es mínima y sin pantallas de negocio. |
| D3 | `core` define un puerto `SqlDriver` mínimo (`execute`, `query`, `transaction`, `close`) y una clase `Repository` encima. Los adaptadores solo implementan el puerto | La lógica de columnas base se prueba una vez. Precisa el ticket, que decía «Repository con dos adaptadores». |
| D4 | Adaptadores de `SqlDriver`: `@capacitor-community/sqlite` 8.1.1, comandos Rust con `rusqlite` en Tauri y `node:sqlite` solo para pruebas | Elección del desarrollador para Tauri. `node:sqlite` evita dependencias nativas en las pruebas. |
| D5 | SHA-256 con WebCrypto (`crypto.subtle`) | Disponible en Chrome 60 en contextos seguros. El spike 1 lo comprueba. Si falla, se pasa a SHA-256 en JS puro. |
| D6 | Claves de provincias y municipios como texto legible (`matanzas`, `matanzas.cardenas`) | Estables, sin depender de códigos oficiales no verificados. |
| D7 | `tokens.css` es la única fuente de los tokens. Un test comprueba el contraste de los pares de color | El diseño exige contraste. |
| D8 | El CI firma la APK si existen los secretos de keystore. Si no, sube una APK de depuración etiquetada como tal | La keystore real la crea el desarrollador y nunca se sube al repo. |
| D9 | La exportación incluye `counts` por tabla además de `sha256` | El plan §9 pide verificar checksum y conteos. |
| D10 | Spikes: plantilla de informe y guía de medición por spike, con la conclusión pendiente de los datos del desarrollador | Elección del desarrollador. |
| D11 | Las restricciones UNIQUE del plan se implementan como índices únicos parciales `WHERE deleted_at IS NULL` | Con borrado lógico, un UNIQUE normal bloquearía la reasignación. `registration_number` es la excepción: único incluso entre borrados. |
| D12 | TypeScript `5.9.3`, no 7.0.2 | La compatibilidad de la versión 7 con Vitest y Vite no se pudo verificar. |
| D13 | Los adaptadores serializan sus llamadas con un `Mutex` | Una transacción no se mezcla con otra sobre una conexión única. |

## Cambios por archivo

### Raíz del monorepo

- `mi-evento/package.json`: `private`, `workspaces: ["packages/*", "apps/*"]`, scripts `typecheck`, `test`, `build`, `e2e`. Node `>=22`.
- `mi-evento/tsconfig.base.json`: `target: ES2017`, `strict: true`, `module: ESNext`.
- `mi-evento/README.md`: cómo instalar, probar y compilar.
- `.gitignore` de la raíz: añadir `mi-evento/**/dist`, `mi-evento/apps/shell-desktop/src-tauri/target` y `mi-evento/apps/shell-desktop/crates/db/target`.

### `packages/core`: TypeScript puro, sin DOM ni plataforma

Versiones: TypeScript `5.9.3`, Vitest `5.1.1`, `uuid` `14.0.3`. `tsconfig` con `lib: ["ES2017"]`. `src/env.d.ts` declara solo `crypto.subtle` y `TextEncoder`.

| Archivo | Contenido |
|---|---|
| `src/ids.ts` | `newId(): string` con UUID v7 de `uuid`. Nunca usa `crypto.randomUUID()`. |
| `src/clock.ts` | `interface Clock { now(): number }` y `systemClock`. Marcas de tiempo en epoch ms UTC. |
| `src/normalize.ts` | `normalizeName(s)`: minúsculas, `normalize('NFD')`, quita `[̀-ͯ]` y colapsa espacios. No usa `\p{…}`, que Chrome 60 no soporta. |
| `src/platform/webview.ts` | `parseChromeMajor(ua): number \| null` y `isWebViewSupported(ua, min = 60)`. Funciones puras. |
| `src/db/driver.ts` | Puerto `SqlDriver` y `Mutex`. |
| `src/db/schema.ts` | Metadatos de cada tabla: nombre, columnas, ámbito (`global`, `event`, `device`) y filtro por evento al exportar. Es la lista blanca de nombres. |
| `src/db/migrations.ts` | `MIGRATIONS` (cada sentencia por separado) y `SCHEMA_VERSION = 1`. |
| `src/db/migrate.ts` | `migrate(driver)`: abre con `foreign_keys=ON` y WAL, aplica las migraciones pendientes y fija `PRAGMA user_version`. |
| `src/db/repository.ts` | Clase `Repository`. |
| `src/db/contract.ts` | `runDriverContract(driver)`: la suite de contrato como función exportable. La ejecutan Vitest con `node:sqlite` y el banco de pruebas en los dispositivos. |
| `src/export/{envelope,checksum,exporter,importer}.ts` | Exportación e importación JSON versionada. |
| `src/reference/{provincias,municipios}.ts` | 16 provincias (15 más Isla de la Juventud) y 168 municipios con claves como `matanzas.cardenas`. |
| `src/index.ts` | Reexporta la API pública. |

Puerto de base de datos:

```ts
export type SqlValue = string | number | null;
export interface SqlDriver {
  execute(sql: string, params?: SqlValue[]): Promise<{ changes: number }>;
  query<T = Record<string, SqlValue>>(sql: string, params?: SqlValue[]): Promise<T[]>;
  transaction<T>(fn: (tx: SqlDriver) => Promise<T>): Promise<T>; // BEGIN IMMEDIATE · COMMIT · ROLLBACK si falla
  close(): Promise<void>;
}
```

Los booleanos se guardan como 0/1.

`Repository`:

```ts
class Repository {
  constructor(driver: SqlDriver, opts: { deviceId: string; clock?: Clock; newId?: () => string });
  insert(table: TableName, values: Record<string, SqlValue>): Promise<Row>;   // id, created_at, updated_at, rev=1, device_id, deleted_at=null
  update(table: TableName, id: string, patch: Record<string, SqlValue>): Promise<Row>; // updated_at, rev+1
  softDelete(table: TableName, id: string): Promise<void>;  // deleted_at, rev+1; en attendees vacía los datos personales
  getById(table: TableName, id: string): Promise<Row | null>; // excluye borrados
  list(table: TableName, where?: Record<string, SqlValue>): Promise<Row[]>;
}
```

`TableName` y las columnas se validan contra `schema.ts`. Los valores siempre van como parámetros.

**Migración 0001:**

- **Tablas:** `events`, `churches`, `attendees`, `couples`, `attendee_groups` (no `groups`, palabra reservada), `group_members`, `lodgings`, `rooms`, `lodging_assignments`, `teams`, `team_memberships`, `team_moves`, `control_types`, `control_sessions`, `control_records`, `proposals`, más `settings` (clave-valor) y `backup_log`, que son locales del dispositivo y no llevan columnas base. Campos y relaciones según `docs/mi-evento/PLAN.md` §3.
- **Columnas base** en las 17 tablas sincronizables: `id`, `created_at`, `updated_at`, `deleted_at`, `rev`, `device_id`.
- **Unicidad con borrado lógico:** índices únicos parciales `WHERE deleted_at IS NULL` en: asignación de hospedaje por (`event_id`, `attendee_id`), pareja por cada miembro, grupo por asistente, membresía de equipo por (`event_id`, `attendee_id`), registro de comida por (`session_id`, `attendee_id`) e iglesia por (`name_norm`, `municipality_code`) cuando no está fusionada. `registration_number` es único por (`event_id`, `registration_number`) incluso entre borrados.
- **Lápidas:** las columnas personales de `attendees` admiten NULL solo si `deleted_at IS NOT NULL`, con un CHECK explícito que exige también `IS NOT NULL` en filas vivas.
- **Otros CHECK:** `age` entre 0 y 120 y `sex` en `M` o `F` en filas vivas, enums como texto con CHECK y claves foráneas activas.

**Exportación:**

```ts
interface ExportEnvelope {
  format: 'mi-evento'; schema_version: number; exported_at: number; device_id: string;
  counts: Record<string, number>; sha256: string;
  event: Row; tables: Record<string, Row[]>;
}
exportEvent(driver: SqlDriver, eventId: string, opts: { deviceId: string; clock?: Clock }): Promise<ExportEnvelope>
importEnvelope(driver: SqlDriver, envelope: ExportEnvelope): Promise<{ imported: Record<string, number>; skipped: Record<string, number> }>
```

- Incluye las filas borradas (lápidas) y las iglesias y tipos de control que el evento referencia.
- `sha256` es el SHA-256 hexadecimal en minúsculas del JSON canónico (claves ordenadas, sin espacios, UTF-8) sin el campo `sha256`, calculado con `crypto.subtle`.
- La importación valida en este orden formato, versión (solo `SCHEMA_VERSION`), checksum y conteos. Después inserta todo en **una sola transacción**, en orden seguro para las claves foráneas, conservando `id`, marcas de tiempo, `rev` y `device_id` tal cual.
- Errores: `ExportError` con `code`: `INVALID_FORMAT`, `UNSUPPORTED_VERSION`, `CHECKSUM_MISMATCH`, `COUNT_MISMATCH`, `EVENT_EXISTS` y `EVENT_NOT_FOUND`. Si el evento ya existe, la importación lo rechaza.
- Si una iglesia o tipo de control ya existe con el mismo `id`, se cuenta como `skipped`.

### `packages/ui`

Versiones: React `19.3.1`, `@testing-library/react` `16.3.3`, `jsdom` `31.0.1`.

| Archivo | Contenido |
|---|---|
| `src/tokens.css` | **Única fuente** de variables CSS: colores del diseño (`#1D4E89`, `#E6EEF8`, `#E07A2E`, `#FDEBDD`, `#8F4512`, `#1B7A43`, `#E3F4EA`, `#14592F`, `#FFF3CC`, `#E8B53A`, `#6B4600`, `#B3261E`, `#FCE8E6`, tintas `#18202B` y `#4A5565`, fondos `#F5F3EE` y `#FFFFFF`, bordes `#D5D9E0` y `#8A93A3`), colores de equipo (`#C8453B`, `#2F6DB5`, `#2E8B57`, `#D9A400`, `#7A4FA3`), radios 12 y 16 px, alto de botón 56 px (compacto 48 px), texto base 18 px, mínimo 16 px y secundario 15 px. Sin sombras ni degradados. |
| `src/fonts.css` y `src/fonts/*.woff2` | `@font-face` de Nunito 700 y 800 y Atkinson Hyperlegible 400 y 700 (subconjunto latino, de `@fontsource`, licencia OFL), con `font-display: swap` y caída a `system-ui`. Incluye un archivo de licencia. |
| `src/components/Button.tsx` | `<button type="button">` con `variant`: `primary`, `secondary`, `accent`, `danger`, `warning`, `ghost`, y `size`: `md` o `compact`. |
| `src/components/Field.tsx` | Etiqueta siempre visible arriba, `<label for>`, ayuda y error enlazados con `aria-describedby` y texto «(opcional)». |
| `src/components/Card.tsx` | Contenedor con borde. |
| `src/components/StatusMessage.tsx` | `kind`: `success`, `warning` o `error`, cada uno con icono SVG propio (círculo con visto, triángulo, círculo con equis) además del color. |
| `src/index.ts` | Reexporta los componentes. |

### `apps/web`: banco de pruebas

App Vite con React, sin pantallas de negocio, `build.target: es2017`. `Harness.tsx` tiene cuatro secciones:

1. **Estilo:** muestra los componentes de `ui`.
2. **Diagnóstico:** plataforma, versión de WebView con aviso si es menor de 60, y disponibilidad de `crypto.subtle` y de SQLite.
3. **Datos:** botones «Ejecutar pruebas de contrato» (con `runDriverContract`), «Cargar 500 asistentes» y «Buscar», que miden el tiempo. Más «Exportar» e «Importar» JSON y «Probar escritura en Documentos» para el spike 5.
4. **Imagen:** prototipo de la imagen de WhatsApp de 1080×1350 con Canvas 2D, que espera `document.fonts.load()` y se comparte con `@capacitor/share` o se guarda en PC.

`src/platform/` contiene `detectPlatform()` (`capacitor`, `tauri` o `web`), `sqlite-capacitor.ts` (con `@capacitor-community/sqlite` 8.1.1) y `sqlite-tauri.ts`. En un navegador normal no hay SQLite: la sección 3 lo indica y se desactiva. Un botón «Copiar resultados» deja todas las mediciones en texto para pegar en los informes.

`e2e/offline.spec.ts` (Playwright 1.63.0) abre la web con la red bloqueada y comprueba que no falla ninguna petición, que las fuentes cargan localmente y que no hay errores de consola.

### `apps/shell-android`

Capacitor 8.6.2 con `@capacitor/share` 8.0.3 y `@capacitor/filesystem` 8.1.5. En `capacitor.config.ts`: `webDir` apunta al build de `apps/web` y `android.minWebViewVersion: 60`. `minSdkVersion` queda en 24, el valor del template de Capacitor 8.

El permiso INTERNET se declara en el manifiesto principal por la recarga en vivo en depuración. `android/app/src/release/AndroidManifest.xml` lo quita con `tools:node="remove"`, lo que también elimina el que aporten los plugins. El spike 4 comprueba que la app funciona sin él.

### `apps/shell-desktop`: Tauri 2

La lógica de SQLite va en un crate propio `crates/db`, sin dependencia de Tauri, con `rusqlite` (SQLite incluido). Expone: abrir (con WAL y claves foráneas), `execute`, `query` (filas como mapas JSON), `begin`, `commit` y `rollback`, sobre **una sola conexión protegida por un Mutex**.

`src-tauri` es una envoltura delgada que expone esos comandos a JS, con `@tauri-apps/cli` 2.12.6 y `@tauri-apps/api` 2.12.5. No se usa `tauri-plugin-sql`. Configuración de instalación:

- `tauri.conf.json`: NSIS por usuario (`installMode: currentUser`).
- `tauri.slim.conf.json`: instalador de WebView2 por descarga.
- `tauri.full.conf.json`: instalador de WebView2 incluido.

### CI: `.github/workflows/mi-evento.yml`

Tres trabajos:

1. **`test`** (Ubuntu, Node 22): `npm ci`, comprobación de tipos, Vitest, `cargo test` del crate `db`, compilación de la web y Playwright sin conexión.
2. **`apk`** (Ubuntu, JDK 21 y Android SDK): compila la web, sincroniza Capacitor y construye la APK. Firma con los secretos de keystore si existen. Si no, sube una APK de depuración con el nombre `…-debug` y un aviso. También imprime los permisos del APK de release, sin hacerlo fallar.
3. **`windows`** (`windows-latest`): `tauri build` con las configuraciones slim y full, más el `.exe` portable. Sube los tres como artefactos.

No se puede ejecutar el CI en la sesión de desarrollo; se valida al subir la rama. Sí se comprueba localmente que el YAML es válido.

### Spikes: `docs/mi-evento/spikes/`

`README.md` con el procedimiento general y los dispositivos necesarios, seis plantillas `SPIKE-1-webview.md`, `SPIKE-2-tauri-windows.md`, `SPIKE-3-sqlite-capacitor.md`, `SPIKE-4-permiso-internet.md`, `SPIKE-5-respaldo-android.md` y `SPIKE-6-imagen-whatsapp.md`, y `DECISION-capacitor-vs-kotlin.md`. Cada plantilla trae objetivo, pasos exactos con el banco de pruebas, una tabla de mediciones vacía y la línea `Conclusión: PENDIENTE`. Los resultados los completa el desarrollador.

## Tabla de referencia: municipios por provincia

| Provincia | Mun. | Provincia | Mun. | Provincia | Mun. |
|---|---|---|---|---|---|
| Pinar del Río | 11 | Villa Clara | 13 | Holguín | 14 |
| Artemisa | 11 | Cienfuegos | 8 | Granma | 13 |
| La Habana | 15 | Sancti Spíritus | 8 | Santiago de Cuba | 9 |
| Mayabeque | 11 | Ciego de Ávila | 10 | Guantánamo | 10 |
| Matanzas | 13 | Camagüey | 13 | Isla de la Juventud | 1 |
| | | Las Tunas | 8 | **Total** | **168** |

Los nombres se cargan de una fuente oficial. Si no es accesible, se escriben de memoria y se marcan para verificación del desarrollador antes de FASE-1A.

## Pruebas (sobre comportamiento observable)

**`packages/core`** (Vitest, base `node:sqlite` en memoria):

| Área | Casos |
|---|---|
| `ids` | `newId()` devuelve un UUID con versión 7 y variante correcta. Tres ids seguidos se ordenan de forma creciente. |
| `normalize` | `"José Pérez"` → `"jose perez"`. `"  María   LÓPEZ "` → `"maria lopez"`. `"Ñandú"` → `"nandu"`. |
| `webview` | Un UA con `Chrome/51` da 51. Con `Chrome/60` da 60. Sin Chrome da `null`. `isWebViewSupported` es falso con 59 y verdadero con 60. |
| `migrate` | Una base vacía queda en `user_version = 1` con todas las tablas. Migrar dos veces no cambia nada. Una base con versión mayor que `SCHEMA_VERSION` se rechaza. |
| Restricciones | Se aplican las claves foráneas. Un asistente vivo sin sexo se rechaza, y tras `softDelete` el NULL se acepta. Una edad de 121 se rechaza. `registration_number` no se repite ni entre borrados. Una segunda asignación viva del mismo asistente se rechaza, y tras borrar la primera se acepta. Lo mismo para parejas, miembros de grupo, membresías de equipo y registros de comida. |
| `Repository` | `insert` rellena las columnas base con `rev = 1`. `update` sube `rev` y `updated_at`. Actualizar un registro borrado falla. `softDelete` en `attendees` vacía los datos personales. `getById` excluye los borrados. Un nombre de tabla o columna inválido se rechaza, incluido un intento de inyección. |
| Transacciones | Un fallo dentro de la transacción deja cero filas. Dos transacciones lanzadas a la vez se ejecutan en serie. |
| Exportación e importación | Un evento con todos los tipos de entidad (incluido un asistente borrado) se exporta e importa en una base nueva y las filas quedan idénticas (ids, tiempos y `rev`). Alterar un carácter da `CHECKSUM_MISMATCH`. Un conteo incorrecto da `COUNT_MISMATCH`. Un formato desconocido da `INVALID_FORMAT`. `schema_version` 2 da `UNSUPPORTED_VERSION`. Un evento ya existente da `EVENT_EXISTS` sin cambiar nada. Un fallo a mitad de importación no deja nada importado. |
| Referencia | 16 provincias, 168 municipios, claves únicas, cada municipio con provincia existente y el conteo por provincia de la tabla de arriba. |
| Contrato | `runDriverContract` pasa completo sobre el adaptador `node:sqlite`. |

**`packages/ui`:** `Button` renderiza un `<button type="button">` con su variante. `Field` enlaza la etiqueta con el campo y, con error, marca `aria-invalid` y lo describe. `StatusMessage` incluye un icono con `aria-hidden` y el rol correcto. Un test lee `tokens.css` y exige contraste mínimo de 4,5 en los pares de texto y de 3 en el borde de campo. Otro comprueba que `fonts.css` solo usa `url()` relativas.

**`crates/db`** (`cargo test`): la apertura activa WAL y claves foráneas. Commit y rollback funcionan. Los parámetros enteros, de texto y NULL se enlazan bien. `query` devuelve filas como mapas. Varios hilos se serializan. Usar una base cerrada devuelve error.

**`apps/web`** (Playwright, sin conexión): la web carga con la red bloqueada, sin peticiones fallidas, sin errores de consola y con las fuentes locales activas.

## Verificación

```bash
cd mi-evento && npm ci                                   # termina con código 0
npm run typecheck                                        # código 0, sin errores
npm test -w @mi-evento/core                              # "0 failed"; el número de pruebas coincide con la lista de arriba
npm test -w @mi-evento/ui                                # "0 failed"
(cd apps/shell-desktop/crates/db && cargo test)          # "test result: ok. … 0 failed"
npm run build -w @mi-evento/web                          # genera apps/web/dist sin URLs http(s) externas
npm run e2e -w @mi-evento/web                            # "0 failed"
grep -rnE "from '(react|@capacitor|@tauri)" packages/core/src   # sin salida
node -e "require('js-yaml').load(require('fs').readFileSync('../.github/workflows/mi-evento.yml','utf8'))"  # código 0
ls ../docs/mi-evento/spikes                              # 8 archivos: README, 6 SPIKE y la DECISION
```

### Qué se verifica en la sesión de desarrollo y qué verifica el desarrollador

| Criterio del ticket | Cómo se comprueba | Quién |
|---|---|---|
| `core` sin dependencias de UI y con Vitest en verde | Comandos de arriba | Sesión de desarrollo |
| Exportar e importar sin pérdida, checksum detecta alteraciones | Pruebas de `core` | Sesión de desarrollo |
| Migraciones de base vacía a la versión actual | Pruebas de `core` | Sesión de desarrollo |
| Misma suite en ambos adaptadores | Contrato en `node:sqlite` y `cargo test` en la sesión. En Capacitor y en Tauri, con el botón del banco de pruebas | Desarrollador, en sus dispositivos |
| La app arranca sin conexión ni fuentes de Internet | Playwright | Sesión de desarrollo |
| El CI produce la APK firmada y el instalador | El flujo se valida al subir la rama. La firma real necesita los secretos de keystore | Desarrollador |
| Informe de cada spike | Las plantillas las entrega la sesión. Los resultados los mide el desarrollador | Desarrollador |
| Decisión Capacitor frente a Kotlin | Plantilla de decisión. La conclusión la saca el desarrollador con los datos | Desarrollador |

El ticket no se cierra hasta que los informes de los spikes estén completos.

## Orden de trabajo

Pruebas primero en cada paso:

1. Workspace y `tsconfig`.
2. `ids`, `clock`, `normalize` y `webview`.
3. Puerto `SqlDriver`, `Mutex` y adaptador `node:sqlite`.
4. Esquema y migraciones.
5. `Repository`.
6. Exportación e importación.
7. Datos de referencia.
8. Suite de contrato.
9. `ui`.
10. Crate `db` en Rust.
11. Banco de pruebas web.
12. Cáscaras Android y de escritorio.
13. CI.
14. Documentos de spikes.

## Fuera de alcance

- Pantallas o flujos de negocio, y los algoritmos de hospedaje y de equipos.
- Cifrado, QR, sincronización e importación de CSV/Excel.
- Certificado de firma de código de Windows, y crear o subir la keystore real.
- Asignar el número de inscripción de forma atómica (FASE-1A).
- Reemplazar o fusionar eventos al importar (FASE-1D y FASE-4).
- SQLite en el navegador normal, y la PWA como entrega.
- Cualquier cambio en los archivos de Battery Calculator.

## Riesgos

- **Nombres de municipios:** si no hay una fuente oficial accesible, se escriben de memoria. Los conteos se comprueban, los nombres no.
- **`crypto.subtle` en WebViews antiguos:** lo comprueba el spike 1. Plan B: SHA-256 en JS puro.
- **API de transacciones de `@capacitor-community/sqlite`:** no se pudo verificar en la sesión. El spike 3 lo comprueba y, si falla, el adaptador usa sentencias `BEGIN` y `COMMIT` explícitas.
- **El CI no se puede ejecutar en la sesión:** puede fallar la primera vez en GitHub y requerir ajustes.
- **`node:sqlite` es experimental en Node 22:** se fija Node 22 en el CI y se aísla en un único adaptador de pruebas.
- **Dependencia del hardware del desarrollador:** sin móviles viejos y una PC Windows el ticket no se puede cerrar.

---

# Tasks

**Límites comunes a todas las tareas**

- No modificar nada de Battery Calculator: `package.json`, `package-lock.json`, `build.js`, `playwright.config.js`, `src/`, `tests/` ni `dist/` de la raíz del repo.
- No añadir pantallas ni lógica de negocio, ni dependencias que el plan no nombre.
- Código TypeScript con `target ES2017` y sin `\p{…}` en expresiones regulares.
- Pruebas primero en cada tarea.
- Identificador de la app: `org.mievento.app`. Nombre visible: «Mi Evento».
- Todas las rutas son relativas a `mi-evento/` salvo que se indique otra cosa.

**Orden de ejecución:** T1 → T2, T3, T9, T11, T13 (independientes entre sí) → T4 → T5 → T6 → T7 → T8 → T10 → T12 → T14 → T15, T16 → T17 → T18.

## Task T1: Workspace npm y esqueleto de `core`

> **Status:** not started
> **Effort:** xs
> **Priority:** critical
> **Depends on:** None

### Description
Crea el workspace npm en `mi-evento/` y el paquete `@mi-evento/core` con Vitest funcionando. Todas las demás tareas se apoyan en una base que ya compila y ejecuta pruebas.

### Test Plan

#### Test File(s)
- `packages/core/tests/smoke.test.ts`

#### Test Scenarios

##### Esqueleto de `core`
- **importa sin DOM** — GIVEN un entorno Node WHEN se importa `src/index` THEN no lanza error y `typeof document` es `'undefined'`.
- **typecheck pasa** — GIVEN el workspace instalado WHEN se ejecuta `npm run typecheck` THEN termina con código 0.

### Implementation Notes
- **Layer(s):** raíz del monorepo y `packages/core`.
- **Pattern reference:** ninguno dentro de `mi-evento/`. El repo no tiene convenciones TypeScript previas.
- **Key decisions:** D1 (workspace en `mi-evento/`), D12 (TypeScript 5.9.3). `workspaces: ["packages/*", "apps/*"]`, Node `>=22`, scripts `typecheck`, `test`, `build` y `e2e`. `core` con `lib: ["ES2017"]` y `src/env.d.ts` que declara solo `crypto.subtle` y `TextEncoder`.
- **Libraries:** `typescript@5.9.3`, `vitest@5.1.1`.

### Scope Boundaries
- Do NOT crear todavía `ui`, `apps/*` ni el crate de Rust.
- Do NOT añadir más scripts ni dependencias que las nombradas.
- Only implementar el workspace, la configuración de TypeScript y Vitest, y el esqueleto de `core` con su prueba.

### Files Expected
**New files:** `package.json`, `tsconfig.base.json`, `README.md`, `packages/core/{package.json,tsconfig.json,vitest.config.ts}`, `packages/core/src/{index.ts,env.d.ts}`, `packages/core/tests/smoke.test.ts`
**Modified files:** `.gitignore` de la raíz del repo (añadir `mi-evento/**/dist` y las carpetas `target` de Rust de `mi-evento`)
**Must NOT modify:** `package.json`, `package-lock.json`, `build.js`, `playwright.config.js`, `src/`, `tests/` de la raíz (son de Battery Calculator).

## Task T2: `ids`, `clock`, `normalize` y `webview`

> **Status:** not started
> **Effort:** s
> **Priority:** high
> **Depends on:** T1

### Description
Cuatro utilidades puras que usan todas las demás tareas: identificadores UUID v7, reloj inyectable, normalización de nombres para la búsqueda y detección de WebView antiguo.

### Test Plan

#### Test File(s)
- `packages/core/tests/ids.test.ts`
- `packages/core/tests/clock.test.ts`
- `packages/core/tests/normalize.test.ts`
- `packages/core/tests/webview.test.ts`

#### Test Scenarios

##### `newId`
- **UUID v7 válido** — GIVEN nada WHEN `newId()` THEN el resultado coincide con `^[0-9a-f]{8}-[0-9a-f]{4}-7[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`.
- **orden creciente** — GIVEN tres ids generados seguidos WHEN se comparan como texto THEN quedan en orden creciente.
- **sin `randomUUID`** — GIVEN `crypto.randomUUID` lanza error WHEN `newId()` THEN devuelve un id válido.

##### `systemClock`
- **hora actual** — GIVEN nada WHEN `systemClock.now()` THEN difiere de `Date.now()` en menos de 1000 ms.

##### `normalizeName`
- **sin tildes** — GIVEN `"José Pérez"` WHEN `normalizeName` THEN `"jose perez"`.
- **eñe** — GIVEN `"Ñandú"` WHEN `normalizeName` THEN `"nandu"`.
- **espacios y mayúsculas** — GIVEN `"  María   LÓPEZ "` WHEN `normalizeName` THEN `"maria lopez"`.
- **vacío** — GIVEN `""` WHEN `normalizeName` THEN `""`.

##### `webview`
- **Chrome 51** — GIVEN un UA con `Chrome/51` WHEN `parseChromeMajor` THEN 51, y `isWebViewSupported(ua, 60)` es falso.
- **Chrome 60** — GIVEN un UA con `Chrome/60` WHEN `parseChromeMajor` THEN 60, y `isWebViewSupported(ua, 60)` es verdadero.
- **Chrome 59** — GIVEN un UA con `Chrome/59` WHEN `isWebViewSupported(ua, 60)` THEN falso.
- **sin Chrome** — GIVEN un UA sin `Chrome/` WHEN `parseChromeMajor` THEN `null`.

### Implementation Notes
- **Layer(s):** `packages/core`, utilidades puras sin DOM.
- **Pattern reference:** ninguno previo.
- **Key decisions:** el plan prohíbe `crypto.randomUUID()` (WebViews antiguos). `normalizeName` usa `normalize('NFD')` y quita `[̀-ͯ]`, sin `\p{…}` (Chrome 60 no lo soporta).
- **Libraries:** `uuid@14.0.3`, solo `v7`.

### Scope Boundaries
- Do NOT detectar la plataforma (Capacitor o Tauri) aquí.
- Do NOT usar `crypto.randomUUID()` ni propiedades Unicode en expresiones regulares.
- Only implementar estas cuatro utilidades y reexportarlas.

### Files Expected
**New files:** `packages/core/src/{ids,clock,normalize}.ts`, `packages/core/src/platform/webview.ts`, los cuatro archivos de prueba.
**Modified files:** `packages/core/src/index.ts` (reexporta), `packages/core/package.json` (añade `uuid`).
**Must NOT modify:** archivos de la raíz del repo.

## Task T3: Puerto `SqlDriver`, `Mutex` y adaptador `node:sqlite` de pruebas

> **Status:** not started
> **Effort:** s
> **Priority:** critical
> **Depends on:** T1

### Description
Define el puerto de base de datos que implementarán todos los adaptadores y un adaptador de pruebas sobre `node:sqlite`. Con él se prueba toda la lógica de datos sin dependencias nativas.

### Test Plan

#### Test File(s)
- `packages/core/tests/driver.test.ts`
- Auxiliar: `packages/core/tests/helpers/node-sqlite-driver.ts`

#### Test Scenarios

##### `Mutex`
- **en serie** — GIVEN dos tareas lanzadas a la vez con el mismo mutex WHEN se ejecutan THEN la segunda empieza al terminar la primera.
- **tras un error** — GIVEN una tarea que lanza error WHEN termina THEN la siguiente puede ejecutarse.

##### Adaptador `node:sqlite`
- **`execute` informa cambios** — GIVEN una tabla vacía WHEN se inserta una fila THEN `changes` es 1.
- **`query` devuelve objetos** — GIVEN una fila WHEN `query` THEN llega como objeto columna-valor.
- **parámetros** — GIVEN un entero, un texto y `null` WHEN se enlazan THEN se leen con el mismo tipo.
- **commit** — GIVEN una transacción que termina bien WHEN se consulta THEN los datos persisten.
- **rollback** — GIVEN una transacción cuya función lanza error WHEN se consulta THEN no queda ninguna fila.
- **transacciones simultáneas** — GIVEN dos transacciones lanzadas a la vez WHEN terminan THEN sus escrituras no se mezclan.

### Implementation Notes
- **Layer(s):** puerto en `src/`; el adaptador es solo de pruebas.
- **Key decisions:** D3 (puerto mínimo `execute`, `query`, `transaction`, `close`), D4 (`node:sqlite` solo para pruebas), D13 (los adaptadores serializan con `Mutex`). `transaction` usa `BEGIN IMMEDIATE`, `COMMIT` y `ROLLBACK`, y entrega una vista sin mutex para las llamadas internas de la función.
- **Libraries:** `node:sqlite` (Node 22.23). Emite un aviso de experimental; es esperado.

### Scope Boundaries
- Do NOT exportar el adaptador de `node:sqlite` desde `src/index.ts`.
- Do NOT añadir adaptadores de Capacitor ni de Tauri.
- Only implementar el puerto, el `Mutex` y el adaptador de pruebas.

### Files Expected
**New files:** `packages/core/src/db/driver.ts`, `packages/core/tests/helpers/node-sqlite-driver.ts`, `packages/core/tests/driver.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta el puerto y el `Mutex`).
**Must NOT modify:** archivos de la raíz del repo.

## Task T4: Migración 0001 y `migrate`

> **Status:** not started
> **Effort:** m
> **Priority:** critical
> **Depends on:** T3

### Description
Crea el esquema SQL completo del plan §3 con las columnas base y la función que lo aplica según `user_version`. Es la base de datos sobre la que trabaja todo lo demás.

### Test Plan

#### Test File(s)
- `packages/core/tests/migrate.test.ts`

#### Test Scenarios

##### `migrate`
- **base vacía** — GIVEN una base nueva WHEN `migrate` THEN `PRAGMA user_version` es 1.
- **tablas** — GIVEN la base migrada WHEN se listan las tablas THEN existen las 17 sincronizables más `settings` y `backup_log`.
- **columnas base** — GIVEN la base migrada WHEN se inspeccionan las columnas THEN cada tabla sincronizable tiene `id`, `created_at`, `updated_at`, `deleted_at`, `rev` y `device_id`, y `settings` y `backup_log` no.
- **idempotente** — GIVEN la base ya migrada WHEN se migra de nuevo THEN el esquema no cambia.
- **versión futura** — GIVEN `user_version = 2` WHEN `migrate` THEN lanza error.
- **pragmas** — GIVEN una base en archivo temporal WHEN se abre y migra THEN `foreign_keys` es 1 y `journal_mode` es `wal`.

### Implementation Notes
- **Layer(s):** `packages/core/src/db`.
- **Key decisions:** 17 tablas sincronizables según `docs/mi-evento/PLAN.md` §3: `events`, `churches`, `attendees`, `couples`, `attendee_groups` (no `groups`, palabra reservada), `group_members`, `lodgings`, `rooms`, `lodging_assignments`, `teams`, `team_memberships`, `team_moves`, `control_types`, `control_sessions`, `control_records`, `proposals`, más `settings` y `backup_log`. Cada sentencia por separado en `MIGRATIONS`. `SCHEMA_VERSION = 1`. `migrate` activa `foreign_keys` y WAL fuera de transacción. `schema.ts` es la lista blanca de nombres, ámbitos y filtros de exportación.
- **Libraries:** ninguna nueva.

### Scope Boundaries
- Do NOT escribir todavía las restricciones parciales ni las lápidas (T5).
- Do NOT añadir índices que el plan no pida.
- Only implementar el esquema base, `schema.ts` y `migrate`.

### Files Expected
**New files:** `packages/core/src/db/{schema,migrations,migrate}.ts`, `packages/core/tests/migrate.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta `migrate` y `SCHEMA_VERSION`).
**Must NOT modify:** archivos de la raíz del repo.

## Task T5: Restricciones de integridad y lápidas

> **Status:** not started
> **Effort:** s
> **Priority:** high
> **Depends on:** T4

### Description
Añade las reglas de integridad del plan: unicidad parcial con borrado lógico, CHECK y lápidas sin datos personales. Sin ellas, un registro borrado bloquearía reasignaciones y la base aceptaría datos inválidos.

### Test Plan

#### Test File(s)
- `packages/core/tests/constraints.test.ts`

#### Test Scenarios

##### Claves foráneas y validaciones
- **claves foráneas** — GIVEN un asistente con una iglesia inexistente WHEN se inserta THEN se rechaza.
- **sexo obligatorio vivo** — GIVEN un asistente vivo sin `sex` WHEN se inserta THEN se rechaza.
- **edad** — GIVEN una edad de 121 WHEN se inserta THEN se rechaza.

##### Lápidas
- **lápida válida** — GIVEN un asistente con `deleted_at` y datos personales en NULL WHEN se inserta THEN se acepta.
- **número de inscripción** — GIVEN un asistente borrado con `registration_number` 7 WHEN se inserta otro con 7 en el mismo evento THEN se rechaza.

##### Unicidad parcial (un caso por tabla)
- **asignación de hospedaje** — GIVEN un asistente con una asignación viva WHEN se inserta otra viva en el mismo evento THEN se rechaza; GIVEN la primera borrada THEN se acepta.
- **pareja** — GIVEN un asistente en una pareja viva WHEN entra en otra (como `a` o como `b`) THEN se rechaza; GIVEN la primera borrada THEN se acepta.
- **miembro de grupo** — GIVEN un asistente en un grupo vivo WHEN entra en otro THEN se rechaza; GIVEN el primero borrado THEN se acepta.
- **membresía de equipo** — GIVEN un asistente en un equipo vivo del mismo evento WHEN entra en otro THEN se rechaza; GIVEN el primero borrado THEN se acepta.
- **registro de comida** — GIVEN un registro vivo de un asistente en una sesión WHEN se inserta otro vivo THEN se rechaza; GIVEN el primero borrado THEN se acepta.

##### Iglesias
- **nombre repetido** — GIVEN una iglesia viva con un `name_norm` y municipio WHEN se inserta otra igual THEN se rechaza.
- **iglesia fusionada** — GIVEN una iglesia con `merged_into_id` WHEN se inserta otra con el mismo `name_norm` y municipio THEN se acepta.

### Implementation Notes
- **Layer(s):** `packages/core/src/db/migrations.ts`.
- **Key decisions:** D11. Los UNIQUE del plan pasan a ser índices únicos parciales `WHERE deleted_at IS NULL`. La excepción es `registration_number`, único por (`event_id`, `registration_number`) incluso entre borrados. Las columnas personales de `attendees` admiten NULL solo si `deleted_at IS NOT NULL`, y en filas vivas exigen `IS NOT NULL` de forma explícita (en SQLite un CHECK con resultado NULL pasa).
- **Libraries:** ninguna nueva.

### Scope Boundaries
- Do NOT crear una migración 0002: el esquema aún no se ha desplegado.
- Do NOT añadir restricciones fuera de las del plan §3 y D11.
- Only implementar las restricciones y sus pruebas.

### Files Expected
**New files:** `packages/core/tests/constraints.test.ts`
**Modified files:** `packages/core/src/db/migrations.ts` (restricciones dentro de la migración 0001).
**Must NOT modify:** archivos de la raíz del repo.

## Task T6: `Repository`

> **Status:** not started
> **Effort:** m
> **Priority:** critical
> **Depends on:** T2, T5

### Description
La capa que rellena las columnas base y hace borrado lógico sobre cualquier tabla sincronizable. Toda la lógica de datos del resto del proyecto pasa por ella.

### Test Plan

#### Test File(s)
- `packages/core/tests/repository.test.ts`

#### Test Scenarios

##### Escritura
- **`insert`** — GIVEN un `Repository` con reloj e id inyectados WHEN `insert` THEN la fila tiene `id` (v7), `created_at` y `updated_at` del reloj, `rev = 1`, `device_id` y `deleted_at = null`.
- **`update`** — GIVEN una fila WHEN `update` THEN `rev` sube en 1 y `updated_at` se actualiza.
- **`update` de un borrado** — GIVEN una fila borrada WHEN `update` THEN lanza error de no encontrado.

##### Borrado lógico
- **`softDelete` genérico** — GIVEN una fila WHEN `softDelete` THEN `deleted_at` queda marcado, `rev` sube y `getById` ya no la devuelve.
- **`softDelete` de asistente** — GIVEN un asistente con nombre, apellidos, teléfono, notas y acompañante WHEN `softDelete` THEN esos campos quedan vacíos.

##### Lectura
- **`list`** — GIVEN filas vivas y borradas WHEN `list` con un filtro de columna THEN devuelve solo las vivas que coinciden.

##### Seguridad
- **tabla inválida** — GIVEN un nombre fuera de la lista blanca WHEN se usa en cualquier método THEN se rechaza.
- **columna inválida** — GIVEN un nombre de columna con una inyección SQL WHEN `insert` THEN se rechaza y no se ejecuta nada.

### Implementation Notes
- **Layer(s):** `packages/core/src/db/repository.ts`.
- **Key decisions:** D3. Firma del plan: `insert`, `update`, `softDelete`, `getById`, `list` sobre `Repository(driver, { deviceId, clock?, newId? })`. Valida tablas y columnas contra `schema.ts`; los valores siempre van como parámetros.
- **Libraries:** ninguna nueva.

### Scope Boundaries
- Do NOT añadir métodos de negocio (número de inscripción, búsqueda).
- Do NOT crear un ORM ni constructores de consultas.
- Only implementar los cinco métodos del plan.

### Files Expected
**New files:** `packages/core/src/db/repository.ts`, `packages/core/tests/repository.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta `Repository`).
**Must NOT modify:** archivos de la raíz del repo.

## Task T7: Exportación de un evento

> **Status:** not started
> **Effort:** m
> **Priority:** high
> **Depends on:** T6

### Description
Exporta un evento completo a un sobre JSON versionado con checksum SHA-256 y conteos por tabla. Es la base de los respaldos y del traspaso entre dispositivos.

### Test Plan

#### Test File(s)
- `packages/core/tests/export.test.ts`

#### Test Scenarios

##### Checksum y JSON canónico
- **claves ordenadas** — GIVEN un objeto con claves en distinto orden WHEN se canoniza THEN las claves salen ordenadas en todos los niveles y sin espacios.
- **checksum estable** — GIVEN el mismo contenido WHEN se calcula el SHA-256 dos veces THEN es idéntico y tiene 64 caracteres hexadecimales en minúsculas.
- **checksum sensible** — GIVEN un contenido WHEN cambia un valor THEN cambia el hash.

##### `exportEvent`
- **contenido** — GIVEN un evento con filas, lápidas, iglesias y tipos de control referenciados WHEN `exportEvent` THEN el sobre incluye todo eso.
- **conteos** — GIVEN el sobre WHEN se lee `counts` THEN coincide con el tamaño de cada lista de `tables`.
- **aislamiento** — GIVEN dos eventos en la base WHEN se exporta uno THEN no incluye filas del otro.
- **metadatos** — GIVEN un reloj y un `deviceId` inyectados WHEN `exportEvent` THEN el sobre trae `format: 'mi-evento'`, `schema_version = SCHEMA_VERSION`, `device_id` y `exported_at` del reloj.
- **evento inexistente** — GIVEN un id que no existe WHEN `exportEvent` THEN lanza `ExportError` con `code: 'EVENT_NOT_FOUND'`.

### Implementation Notes
- **Layer(s):** `packages/core/src/export`.
- **Key decisions:** D5 (SHA-256 con `crypto.subtle`), D9 (`counts` en el sobre). JSON canónico: claves ordenadas, sin espacios, UTF-8. Hash hexadecimal en minúsculas sobre el sobre sin el campo `sha256`. Incluye lápidas y las iglesias y tipos de control referenciados. Las tablas y sus filtros por evento salen de `schema.ts`.
- **Libraries:** ninguna nueva (WebCrypto).

### Scope Boundaries
- Do NOT cifrar ni comprimir.
- Do NOT leer ni escribir archivos: solo devuelve el objeto.
- Only implementar `envelope`, `checksum` y `exportEvent`, con `ExportError`.

### Files Expected
**New files:** `packages/core/src/export/{envelope,checksum,exporter}.ts`, `packages/core/tests/export.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta).
**Must NOT modify:** archivos de la raíz del repo.

## Task T8: Importación de un evento

> **Status:** not started
> **Effort:** m
> **Priority:** high
> **Depends on:** T7

### Description
Importa un sobre validándolo por completo antes de tocar la base y, si todo es correcto, insertándolo en una sola transacción. Permite restaurar y traspasar eventos sin riesgo de datos a medias.

### Test Plan

#### Test File(s)
- `packages/core/tests/import.test.ts`

#### Test Scenarios

##### Camino correcto
- **ida y vuelta** — GIVEN un evento con todos los tipos de entidad y un asistente borrado WHEN se exporta e importa en una base nueva THEN las filas son idénticas (ids, tiempos y `rev`).
- **iglesia existente** — GIVEN una iglesia con el mismo `id` ya en la base WHEN se importa THEN no se duplica y se cuenta en `skipped`.

##### Validaciones
- **formato** — GIVEN un `format` desconocido WHEN `importEnvelope` THEN lanza `INVALID_FORMAT`.
- **versión** — GIVEN `schema_version` 2 WHEN `importEnvelope` THEN lanza `UNSUPPORTED_VERSION`.
- **checksum** — GIVEN un sobre con un carácter alterado WHEN `importEnvelope` THEN lanza `CHECKSUM_MISMATCH`.
- **conteos** — GIVEN `counts` incorrecto con el checksum recalculado WHEN `importEnvelope` THEN lanza `COUNT_MISMATCH`.
- **evento existente** — GIVEN un evento que ya existe WHEN `importEnvelope` THEN lanza `EVENT_EXISTS` y no cambia nada.

##### Atomicidad
- **fallo a mitad** — GIVEN una fila que viola una clave foránea al final del sobre WHEN `importEnvelope` THEN falla y no queda nada importado.

### Implementation Notes
- **Layer(s):** `packages/core/src/export`.
- **Key decisions:** orden de validación: formato, versión, checksum, conteos. Solo `SCHEMA_VERSION` exacta. Inserta con `id`, tiempos, `rev` y `device_id` intactos, en orden seguro para las claves foráneas y dentro de una sola transacción. `ExportError` con los seis códigos: `INVALID_FORMAT`, `UNSUPPORTED_VERSION`, `CHECKSUM_MISMATCH`, `COUNT_MISMATCH`, `EVENT_EXISTS` y `EVENT_NOT_FOUND`.
- **Libraries:** ninguna nueva.

### Scope Boundaries
- Do NOT reemplazar ni fusionar eventos (FASE-1D y FASE-4).
- Do NOT leer archivos ni mostrar vistas previas.
- Only implementar `importEnvelope` y sus errores.

### Files Expected
**New files:** `packages/core/src/export/importer.ts`, `packages/core/tests/import.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta).
**Must NOT modify:** archivos de la raíz del repo.

## Task T9: Datos de referencia (provincias y municipios)

> **Status:** not started
> **Effort:** s
> **Priority:** medium
> **Depends on:** T1

### Description
Entrega las 16 provincias y los 168 municipios de Cuba con claves estables. El formulario de registro los usará para rellenar provincia y municipio sin conexión.

### Test Plan

#### Test File(s)
- `packages/core/tests/reference.test.ts`

#### Test Scenarios

##### Estructura
- **provincias** — GIVEN la lista WHEN se cuenta THEN son 16.
- **municipios** — GIVEN la lista WHEN se cuenta THEN son 168.
- **claves únicas** — GIVEN todas las claves WHEN se comprueba THEN no hay repetidas y cada una cumple `^[a-z0-9-]+(\.[a-z0-9-]+)?$`.
- **integridad** — GIVEN cada municipio WHEN se busca su provincia THEN existe.
- **conteo por provincia** — GIVEN la tabla de municipios por provincia del plan WHEN se cuenta cada provincia THEN coincide: Pinar del Río 11, Artemisa 11, La Habana 15, Mayabeque 11, Matanzas 13, Villa Clara 13, Cienfuegos 8, Sancti Spíritus 8, Ciego de Ávila 10, Camagüey 13, Las Tunas 8, Holguín 14, Granma 13, Santiago de Cuba 9, Guantánamo 10 e Isla de la Juventud 1.

### Implementation Notes
- **Layer(s):** `packages/core/src/reference`.
- **Key decisions:** D6 (claves legibles como `matanzas` y `matanzas.cardenas`). Intentar obtener los nombres de una fuente oficial. Si no es accesible, escribirlos de memoria y marcar el archivo con un comentario de verificación pendiente, y avisar al desarrollador.
- **Libraries:** ninguna.

### Scope Boundaries
- Do NOT añadir poblaciones, coordenadas ni códigos oficiales.
- Do NOT leer estos datos desde la red en tiempo de ejecución.
- Only implementar las dos listas y su prueba.

### Files Expected
**New files:** `packages/core/src/reference/{provincias,municipios}.ts`, `packages/core/tests/reference.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta).
**Must NOT modify:** archivos de la raíz del repo.

## Task T10: Suite de contrato de adaptadores

> **Status:** not started
> **Effort:** s
> **Priority:** high
> **Depends on:** T6

### Description
`runDriverContract(driver)` ejecuta las mismas comprobaciones sobre cualquier adaptador de `SqlDriver`. La usan Vitest aquí y el banco de pruebas en los dispositivos, para comprobar que Capacitor y Tauri se comportan igual que `node:sqlite`.

### Test Plan

#### Test File(s)
- `packages/core/tests/contract.test.ts`

#### Test Scenarios

##### Suite de contrato
- **adaptador correcto** — GIVEN el adaptador de `node:sqlite` WHEN `runDriverContract` THEN todos los casos devuelven `ok: true`.
- **detecta un adaptador roto** — GIVEN un adaptador cuyo rollback no deshace nada WHEN `runDriverContract` THEN el caso de rollback devuelve `ok: false` con un mensaje de error.
- **nombres únicos** — GIVEN la lista de resultados WHEN se comparan los nombres THEN no hay repetidos y son estables entre ejecuciones.
- **independiente de Vitest** — GIVEN un `SqlDriver` cualquiera WHEN se llama fuera de Vitest THEN funciona recibiendo solo el driver.

### Implementation Notes
- **Layer(s):** `packages/core/src/db/contract.ts`.
- **Key decisions:** devuelve `Array<{ name: string; ok: boolean; error?: string }>`. Cubre ejecutar, consultar, parámetros (entero, texto y `null`), transacciones, rollback y claves foráneas, creando y limpiando sus propias tablas temporales. No depende de Vitest.
- **Libraries:** ninguna.

### Scope Boundaries
- Do NOT importar Vitest dentro de `contract.ts`.
- Do NOT cubrir lógica de negocio: solo el comportamiento del puerto.
- Only implementar `runDriverContract` y su prueba.

### Files Expected
**New files:** `packages/core/src/db/contract.ts`, `packages/core/tests/contract.test.ts`
**Modified files:** `packages/core/src/index.ts` (reexporta `runDriverContract`).
**Must NOT modify:** archivos de la raíz del repo.

## Task T11: `ui`, tokens y fuentes locales

> **Status:** not started
> **Effort:** s
> **Priority:** medium
> **Depends on:** T1

### Description
Crea el paquete `@mi-evento/ui` con los tokens del diseño como única fuente CSS y las cuatro fuentes empaquetadas en local. Garantiza que el estilo no dependa de Internet y que los colores cumplan el contraste.

### Test Plan

#### Test File(s)
- `packages/ui/tests/tokens.test.ts`

#### Test Scenarios

##### Contraste
- **texto** — GIVEN los pares de texto del diseño (tinta sobre fondo, tinta secundaria sobre fondo, blanco sobre azul, tinta sobre naranja, blanco sobre rojo, `#6B4600` sobre `#FFF3CC`, `#14592F` sobre `#E3F4EA`, blanco sobre verde, `#8F4512` sobre `#FDEBDD`) WHEN se calcula el contraste leyendo `tokens.css` THEN todos dan 4,5 o más.
- **borde de campo** — GIVEN `#8A93A3` sobre blanco WHEN se calcula el contraste THEN da 3 o más.

##### Tokens
- **variables definidas** — GIVEN `tokens.css` WHEN se leen las variables THEN existen todas las listadas en el plan (colores, colores de equipo, radios 12 y 16 px, alto de botón 56 px y 48 px compacto, texto base 18 px, mínimo 16 px, secundario 15 px).
- **sin sombras ni degradados** — GIVEN los CSS de `ui` WHEN se buscan `box-shadow` y `gradient` THEN no aparecen.

##### Fuentes
- **fuentes locales** — GIVEN `fonts.css` WHEN se analiza THEN tiene 4 `@font-face` con `font-display: swap` y solo `url()` relativas.
- **archivos presentes** — GIVEN los cuatro `.woff2` WHEN se comprueba su tamaño THEN existen y no están vacíos.

### Implementation Notes
- **Layer(s):** `packages/ui`.
- **Key decisions:** D7 (`tokens.css` única fuente). Fuentes tomadas de `@fontsource` (Nunito 700 y 800, Atkinson Hyperlegible 400 y 700, latin), licencia OFL con archivo de licencia incluido. Caída a `system-ui`. El test lee el CSS con una expresión regular y calcula la luminancia relativa.
- **Libraries:** `@fontsource/nunito@5.3.0` y `@fontsource/atkinson-hyperlegible@5.3.0` solo para copiar los archivos (no quedan como dependencia de ejecución).

### Scope Boundaries
- Do NOT copiar las fuentes de `src/fonts` de Battery Calculator.
- Do NOT añadir sombras, degradados ni más tokens que los del plan.
- Only implementar tokens, fuentes y su prueba.

### Files Expected
**New files:** `packages/ui/{package.json,tsconfig.json,vitest.config.ts}`, `packages/ui/src/{tokens.css,fonts.css}`, `packages/ui/src/fonts/*.woff2`, `packages/ui/src/fonts/LICENSE.md`, `packages/ui/tests/tokens.test.ts`
**Modified files:** ninguno.
**Must NOT modify:** `src/fonts/` de la raíz del repo.

## Task T12: `ui`, componentes

> **Status:** not started
> **Effort:** m
> **Priority:** medium
> **Depends on:** T11

### Description
Implementa Button, Field, Card y StatusMessage con el estilo del diseño y accesibles desde el HTML nativo. Son los cuatro componentes mínimos que validan que el estilo funciona.

### Test Plan

#### Test File(s)
- `packages/ui/tests/components.test.tsx`

#### Test Scenarios

##### `Button`
- **botón nativo** — GIVEN un `Button` WHEN se renderiza THEN es un `<button type="button">` con la clase de su variante.
- **tamaños** — GIVEN `size="compact"` y `size="md"` WHEN se renderizan THEN llevan clases distintas.

##### `Field`
- **etiqueta enlazada** — GIVEN un `Field` con etiqueta WHEN se consulta con `getByLabelText` THEN devuelve el campo.
- **con error** — GIVEN un `Field` con error WHEN se renderiza THEN el campo tiene `aria-invalid="true"` y `aria-describedby` apunta al mensaje de error.
- **opcional** — GIVEN `optional` WHEN se renderiza THEN muestra «(opcional)».

##### `StatusMessage`
- **iconos y texto** — GIVEN `success`, `warning` y `error` WHEN se renderizan THEN cada uno muestra un icono propio con `aria-hidden="true"` y su texto.
- **rol de error** — GIVEN `kind="error"` WHEN se renderiza THEN el contenedor tiene `role="alert"`.

##### `Card`
- **hijos** — GIVEN un `Card` con contenido WHEN se renderiza THEN muestra sus hijos.

### Implementation Notes
- **Layer(s):** `packages/ui/src/components`.
- **Key decisions:** HTML nativo (`<button>`, `<label for>`). Variantes de `Button`: `primary`, `secondary`, `accent`, `danger`, `warning`, `ghost`. Iconos SVG propios: círculo con visto, triángulo y círculo con equis.
- **Libraries:** `react@19.3.1`, `@testing-library/react@16.3.3`, `jsdom@31.0.1`.

### Scope Boundaries
- Do NOT añadir más variantes ni componentes.
- Do NOT usar librerías de UI ni de iconos.
- Only implementar los cuatro componentes y reexportarlos.

### Files Expected
**New files:** `packages/ui/src/components/{Button,Field,Card,StatusMessage}.tsx`, `packages/ui/src/index.ts`, `packages/ui/tests/components.test.tsx`
**Modified files:** `packages/ui/package.json` (dependencias de React y de pruebas).
**Must NOT modify:** archivos de la raíz del repo.

## Task T13: Crate `db` en Rust

> **Status:** not started
> **Effort:** m
> **Priority:** high
> **Depends on:** None

### Description
La capa SQLite de la app de Windows: una sola conexión con WAL y claves foráneas que ofrece ejecutar, consultar y transacciones reales. Existe porque el plugin SQL de Tauri no garantiza transacciones sobre una conexión única.

### Test Plan

#### Test File(s)
- `apps/shell-desktop/crates/db/tests/db.rs`

#### Test Scenarios

##### Apertura
- **pragmas** — GIVEN un archivo temporal WHEN se abre la base THEN `PRAGMA journal_mode` es `wal` y `PRAGMA foreign_keys` es 1.

##### Ejecución y consulta
- **`execute` informa cambios** — GIVEN una tabla vacía WHEN se inserta una fila THEN devuelve 1 fila afectada.
- **parámetros** — GIVEN un entero, un texto y NULL WHEN se enlazan THEN se leen con el mismo tipo.
- **`query` devuelve mapas** — GIVEN filas con valores NULL WHEN se consultan THEN llegan como mapas con `null`.

##### Transacciones
- **commit** — GIVEN `begin`, una inserción y `commit` WHEN se consulta THEN la fila persiste.
- **rollback** — GIVEN `begin`, una inserción y `rollback` WHEN se consulta THEN no queda ninguna fila.
- **concurrencia** — GIVEN dos hilos que hacen `begin` … `commit` sobre el mismo contador WHEN terminan THEN el resultado es consistente.

##### Errores
- **SQL inválido** — GIVEN una sentencia mal escrita WHEN se ejecuta THEN devuelve `Err` con un mensaje.
- **base cerrada** — GIVEN una base cerrada WHEN se usa THEN devuelve `Err`.

### Implementation Notes
- **Layer(s):** crate Rust sin dependencia de Tauri.
- **Key decisions:** D4 y D13. Una conexión bajo `Mutex`. `query` devuelve filas como mapas JSON. Sin Tauri para poder probarla aquí con `cargo test`.
- **Libraries:** `rusqlite` con SQLite incluido, `serde_json`. Rust 1.97 está instalado.

### Scope Boundaries
- Do NOT usar `tauri-plugin-sql`.
- Do NOT depender de Tauri en este crate.
- Only implementar el crate y sus pruebas.

### Files Expected
**New files:** `apps/shell-desktop/crates/db/{Cargo.toml,src/lib.rs,tests/db.rs}`
**Modified files:** ninguno.
**Must NOT modify:** archivos de la raíz del repo.

## Task T14: `apps/web`, banco de pruebas

> **Status:** not started
> **Effort:** l
> **Priority:** high
> **Depends on:** T10, T12

### Description
La app web mínima que sirve de banco de pruebas y que empaquetan las dos cáscaras. Reúne el estilo de `ui`, el diagnóstico de plataforma y las pruebas de contrato de SQLite. Es necesaria para medir los spikes en dispositivos reales.

### Test Plan

#### Test File(s)
- `apps/web/e2e/offline.spec.ts`

#### Test Scenarios

##### Sin conexión
- **sin peticiones fallidas** — GIVEN la web compilada y la red bloqueada WHEN se abre THEN no hay peticiones fallidas.
- **consola limpia** — GIVEN la misma carga WHEN termina THEN no hay errores de consola.
- **fuentes locales** — GIVEN la página cargada WHEN se consulta `document.fonts.check('700 16px Nunito')` THEN es verdadero y no hubo peticiones de fuentes a otro origen.

##### Diagnóstico y plataforma
- **plataforma web** — GIVEN un navegador normal WHEN se abre la sección de diagnóstico THEN muestra plataforma `web`.
- **WebView antiguo** — GIVEN un UA con `Chrome/51` WHEN se abre THEN muestra el aviso de WebView antiguo.
- **plataforma Capacitor** — GIVEN `window.Capacitor` simulado WHEN `detectPlatform()` THEN devuelve `capacitor`.
- **plataforma Tauri** — GIVEN `__TAURI_INTERNALS__` simulado WHEN `detectPlatform()` THEN devuelve `tauri`.

##### Datos e imagen
- **sin SQLite en navegador** — GIVEN un navegador normal WHEN se abre la sección de datos THEN está desactivada con un mensaje que lo explica.
- **imagen** — GIVEN las fuentes cargadas WHEN se pulsa el botón de imagen THEN se genera un PNG de 1080×1350.
- **copiar resultados** — GIVEN mediciones en pantalla WHEN se pulsa «Copiar resultados» THEN el portapapeles contiene el texto de las mediciones.

##### Verificación manual (no automatizable aquí)
Las siguientes comprobaciones las hace el desarrollador en sus dispositivos y se documentan en los spikes: «Ejecutar pruebas de contrato» sobre Capacitor y sobre Tauri, «Cargar 500 asistentes» y «Buscar» con sus tiempos, «Probar escritura en Documentos», y compartir la imagen con `@capacitor/share`.

### Implementation Notes
- **Layer(s):** `apps/web`, app Vite con React sin pantallas de negocio.
- **Pattern reference:** `ui` para el estilo y `core` (`runDriverContract`, `Repository`, `exportEvent`, `importEnvelope`, `isWebViewSupported`).
- **Key decisions:** D2. `build.target: es2017`. `detectPlatform()` devuelve `capacitor`, `tauri` o `web`. `sqlite-capacitor.ts` usa `@capacitor-community/sqlite` 8.1.1; `sqlite-tauri.ts` llama a los comandos del crate `db`. La sección de datos se desactiva en un navegador normal. La imagen de 1080×1350 se dibuja con Canvas 2D tras `document.fonts.load()`.
- **Libraries:** `vite@8.3.8`, `@vitejs/plugin-react@6.3.0`, `react@19.3.1`, `@playwright/test@1.63.0`, `@capacitor-community/sqlite@8.1.1`, `@capacitor/share@8.0.3`, `@capacitor/filesystem@8.1.5`, `@tauri-apps/api@2.12.5`.

### Scope Boundaries
- Do NOT crear pantallas de negocio.
- Do NOT añadir SQLite al navegador normal.
- Only implementar las cuatro secciones del plan, los adaptadores y la prueba sin conexión.

### Files Expected
**New files:** `apps/web/{package.json,vite.config.ts,index.html,playwright.config.ts}`, `apps/web/src/{main.tsx,Harness.tsx}`, `apps/web/src/platform/{index,sqlite-capacitor,sqlite-tauri}.ts`, `apps/web/e2e/offline.spec.ts`
**Modified files:** ninguno.
**Must NOT modify:** archivos de la raíz del repo.

## Task T15: `apps/shell-android`

> **Status:** not started
> **Effort:** m
> **Priority:** high
> **Depends on:** T14

### Description
El proyecto Capacitor listo para compilar la APK con el banco de pruebas. No se compila aquí porque no hay Android SDK; se verifica la configuración de forma estática y el desarrollador compila.

### Test Plan

#### Test File(s)
- `apps/shell-android/tests/config.test.ts`

#### Test Scenarios

##### Configuración estática
- **WebView mínima** — GIVEN `capacitor.config.ts` WHEN se lee THEN `android.minWebViewVersion` es 60.
- **webDir** — GIVEN la configuración WHEN se lee THEN `webDir` apunta al build de `apps/web`.
- **identificador** — GIVEN la configuración WHEN se lee THEN `appId` es `org.mievento.app` y el nombre es «Mi Evento».
- **minSdk** — GIVEN `variables.gradle` WHEN se lee THEN `minSdkVersion` es 24.
- **INTERNET fuera del release** — GIVEN el manifiesto de release WHEN se lee THEN quita el permiso INTERNET con `tools:node="remove"`.
- **dependencias fijadas** — GIVEN `package.json` WHEN se lee THEN fija `@capacitor/share` 8.0.3 y `@capacitor/filesystem` 8.1.5.

### Implementation Notes
- **Layer(s):** `apps/shell-android`.
- **Key decisions:** el permiso INTERNET se declara en el manifiesto principal por la recarga en vivo; el de release lo quita (también el de los plugins). El spike 4 comprueba que la app funciona sin él. La compilación y la firma quedan para el CI y el desarrollador.
- **Libraries:** `@capacitor/core`, `@capacitor/cli` y `@capacitor/android` 8.6.2, `@capacitor/share` 8.0.3, `@capacitor/filesystem` 8.1.5.

### Scope Boundaries
- Do NOT crear ni subir keystores.
- Do NOT compilar la APK en esta tarea.
- Only configurar el proyecto Capacitor, generar `android/` y las pruebas estáticas.

### Files Expected
**New files:** `apps/shell-android/{package.json,capacitor.config.ts}`, `apps/shell-android/tests/config.test.ts`, `apps/shell-android/android/` (generado por Capacitor), `apps/shell-android/android/app/src/release/AndroidManifest.xml`
**Modified files:** ninguno.
**Must NOT modify:** archivos de la raíz del repo.

## Task T16: `apps/shell-desktop`, envoltura Tauri

> **Status:** not started
> **Effort:** m
> **Priority:** high
> **Depends on:** T13, T14

### Description
La envoltura Tauri que expone los comandos de base de datos del crate `db` al banco de pruebas y define las tres configuraciones de instalador. No se compila aquí porque falta `webkit2gtk`; se verifica la configuración de forma estática.

### Test Plan

#### Test File(s)
- `apps/shell-desktop/tests/config.test.ts`

#### Test Scenarios

##### Configuración estática
- **instalador por usuario** — GIVEN `tauri.conf.json` WHEN se lee THEN usa NSIS con `installMode: currentUser`.
- **configuración slim** — GIVEN `tauri.slim.conf.json` WHEN se lee THEN usa `downloadBootstrapper`.
- **configuración completa** — GIVEN `tauri.full.conf.json` WHEN se lee THEN usa `offlineInstaller`.
- **frontend** — GIVEN `tauri.conf.json` WHEN se lee THEN `frontendDist` apunta al build de `apps/web`.
- **identificador** — GIVEN `tauri.conf.json` WHEN se lee THEN `identifier` es `org.mievento.app` y el nombre del producto es «Mi Evento».
- **comandos registrados** — GIVEN `src-tauri/src/main.rs` WHEN se lee THEN registra `db_open`, `db_execute`, `db_query`, `db_begin`, `db_commit` y `db_rollback`.

### Implementation Notes
- **Layer(s):** `apps/shell-desktop/src-tauri`.
- **Key decisions:** D4. Envoltura delgada sobre el crate `db` (T13). No se usa `tauri-plugin-sql`.
- **Libraries:** `@tauri-apps/cli@2.12.6`, `@tauri-apps/api@2.12.5`, `tauri` 2.x, `mi-evento-db` por ruta.

### Scope Boundaries
- Do NOT compilar el instalador ni firmar con certificado.
- Do NOT duplicar la lógica de SQLite: solo delegar en el crate `db`.
- Only configurar Tauri, registrar los comandos y las pruebas estáticas.

### Files Expected
**New files:** `apps/shell-desktop/{package.json,tests/config.test.ts}`, `apps/shell-desktop/src-tauri/{Cargo.toml,build.rs,tauri.conf.json,tauri.slim.conf.json,tauri.full.conf.json}`, `apps/shell-desktop/src-tauri/src/main.rs`
**Modified files:** ninguno.
**Must NOT modify:** archivos de la raíz del repo.

## Task T17: CI en GitHub Actions

> **Status:** not started
> **Effort:** m
> **Priority:** medium
> **Depends on:** T15, T16

### Description
El flujo de GitHub Actions con los tres trabajos del plan: pruebas, APK e instalador de Windows. No se puede ejecutar aquí; se valida con una prueba que parsea el YAML y revisa su estructura, y se confirma al subir la rama.

### Test Plan

#### Test File(s)
- `mi-evento/tests/workflow.test.ts` (en la raíz de `mi-evento/`, con su propia configuración de Vitest)

#### Test Scenarios

##### Estructura del flujo
- **YAML válido** — GIVEN `.github/workflows/mi-evento.yml` WHEN se parsea THEN no lanza error.
- **tres trabajos** — GIVEN el flujo WHEN se listan los trabajos THEN son exactamente `test`, `apk` y `windows`.
- **trabajo `test`** — GIVEN el trabajo WHEN se lee THEN usa Node 22 y ejecuta tipos, Vitest, `cargo test`, la compilación de la web y Playwright.
- **trabajo `apk`** — GIVEN el trabajo WHEN se lee THEN usa JDK 21, firma solo si existen los secretos de keystore e imprime los permisos del release.
- **APK de depuración** — GIVEN que no existen los secretos WHEN el trabajo sube el artefacto THEN el nombre lleva `-debug`.
- **trabajo `windows`** — GIVEN el trabajo WHEN se lee THEN ejecuta en `windows-latest` y sube los instaladores slim y full y el `.exe` portable como artefactos.

### Implementation Notes
- **Layer(s):** `.github/workflows` y una prueba en `mi-evento/tests`.
- **Key decisions:** D8. El paso de permisos solo imprime y no falla el trabajo, hasta que el spike 4 decida. La ejecución real ocurre al subir la rama; puede requerir ajustes.
- **Libraries:** `js-yaml` como dependencia de desarrollo solo para la prueba.

### Scope Boundaries
- Do NOT añadir secretos ni claves.
- Do NOT publicar releases.
- Only crear el flujo y su prueba estructural.

### Files Expected
**New files:** `.github/workflows/mi-evento.yml`, `mi-evento/tests/workflow.test.ts`
**Modified files:** `mi-evento/package.json` (script de prueba y `js-yaml` de desarrollo).
**Must NOT modify:** cualquier otro flujo o archivo de la raíz del repo.

## Task T18: Plantillas de spikes y decisión

> **Status:** not started
> **Effort:** s
> **Priority:** high
> **Depends on:** T14

### Description
Los ocho documentos para que el desarrollador mida en sus dispositivos y concluya. No inventa mediciones ni conclusiones: deja los resultados pendientes. El ticket FASE-0 no se cierra hasta que estén completos.

### Test Plan

#### Test File(s)
- `mi-evento/tests/spikes-docs.test.ts` (en la raíz de `mi-evento/`)

#### Test Scenarios

##### Estructura de los documentos
- **ocho archivos** — GIVEN `docs/mi-evento/spikes/` WHEN se lista THEN existen `README.md`, `SPIKE-1-webview.md`, `SPIKE-2-tauri-windows.md`, `SPIKE-3-sqlite-capacitor.md`, `SPIKE-4-permiso-internet.md`, `SPIKE-5-respaldo-android.md`, `SPIKE-6-imagen-whatsapp.md` y `DECISION-capacitor-vs-kotlin.md`.
- **secciones de cada spike** — GIVEN cada `SPIKE-N` WHEN se lee THEN tiene las secciones Objetivo, Pasos y Mediciones, y la línea `Conclusión: PENDIENTE`.
- **dispositivos** — GIVEN `README.md` WHEN se lee THEN lista los dispositivos necesarios y el procedimiento general.
- **decisión** — GIVEN `DECISION-capacitor-vs-kotlin.md` WHEN se lee THEN presenta las dos opciones y la línea `Conclusión: PENDIENTE`.

### Implementation Notes
- **Layer(s):** `docs/mi-evento/spikes` y una prueba en `mi-evento/tests`.
- **Key decisions:** D10. Cada spike con objetivo, pasos exactos con el banco de pruebas de T14, tabla de mediciones vacía y conclusión pendiente. Los seis spikes son los del ticket: WebView en móviles viejos, Tauri en Windows 10/11, SQLite en Capacitor, permiso INTERNET, respaldo en Android 10+ e imagen de WhatsApp.
- **Libraries:** ninguna.

### Scope Boundaries
- Do NOT inventar mediciones ni conclusiones.
- Do NOT marcar ningún spike como completado.
- Only crear las plantillas y la prueba estructural.

### Files Expected
**New files:** `docs/mi-evento/spikes/{README.md,SPIKE-1-webview.md,SPIKE-2-tauri-windows.md,SPIKE-3-sqlite-capacitor.md,SPIKE-4-permiso-internet.md,SPIKE-5-respaldo-android.md,SPIKE-6-imagen-whatsapp.md,DECISION-capacitor-vs-kotlin.md}`, `mi-evento/tests/spikes-docs.test.ts`
**Modified files:** ninguno.
**Must NOT modify:** archivos de la raíz del repo.
