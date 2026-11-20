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
