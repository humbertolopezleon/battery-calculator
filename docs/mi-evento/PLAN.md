# Mi Evento — Plan de implementación

Sistema para registrar asistentes a eventos cristianos. Dos herramientas independientes que más adelante se integrarán:

1. App Android (APK) de registro.
2. App web instalable en PC (Windows principalmente) que también sirve para el registro.

Ambas funcionan 100 % sin conexión, en español, con una interfaz simple para voluntarios de nivel técnico básico.

Diseño de referencia de la interfaz: https://claude.ai/artifact/SiHuWyWtBGWTEKv9ga1WVR

> Estado: plan aprobado en conversación. Última actualización: 2026-11-20.

## Índice

1. [Decisiones tomadas](#1-decisiones-tomadas)
2. [Stack](#2-stack)
3. [Modelo de datos](#3-modelo-de-datos)
4. [Hospedajes: reglas y algoritmo de sugerencia](#4-hospedajes-reglas-y-algoritmo-de-sugerencia)
5. [Equipos: balanceo](#5-equipos-balanceo)
6. [Control de comidas](#6-control-de-comidas)
7. [MVP y fases](#7-mvp-y-fases)
8. [Integración futura entre la APK y la web](#8-integración-futura-entre-la-apk-y-la-web)
9. [Respaldo de datos](#9-respaldo-de-datos)
10. [Privacidad](#10-privacidad)
11. [Distribución e instalación](#11-distribución-e-instalación)
12. [Riesgos](#12-riesgos)
13. [Esfuerzo estimado](#13-esfuerzo-estimado)
14. [Mapa de pantallas](#14-mapa-de-pantallas)
15. [Suposiciones abiertas](#15-suposiciones-abiertas)

---

## 1. Decisiones tomadas

| Tema | Decisión |
|---|---|
| Desarrollo | Un solo desarrollador, con experiencia en web (TypeScript/React). |
| Stack | Una base TypeScript/React. Capacitor para la APK, Tauri 2 para Windows, PWA como plan B. |
| Android | Mínimo recomendado Android 7.0 (API 24), con WebView actualizado (Chrome 60 o superior). |
| Windows | Windows 10/11 en su mayoría. |
| Tamaño de evento | Hasta ~500 asistentes. Las personas no se reutilizan entre eventos. |
| Identificación en comidas | Búsqueda por nombre y número de inscripción. QR en la Fase 3. |
| Hospedaje | Cada hospedaje tiene habitaciones con capacidad. Cualquier hospedaje puede recibir las tres categorías. |
| Sexo de cada habitación | Libre por defecto (la fija el primer ocupante). Se puede fijar un tipo cuando el anfitrión lo exige. |
| Habitación de matrimonio | Un matrimonio por habitación. Si está abierta a otros, la app no restringe quién entra. |
| Menores | Menor = menos de 18 años. Solo aviso, nunca bloqueo. Se vincula con un «acompañante responsable». |
| Equipos | Estrategia A: rangos de edad por sexo. Rangos definidos el día del evento. Sugerencia de equipo al registrar a cada persona. |
| Prioridad del balanceo | Edad, luego sexo, luego tamaño. Diferencia de tamaño limitada a 1. |
| Avisos de equipos | Solo cuando un rango de edad difiere en más de 1 entre equipos. |
| Capitanes | Forman parte del equipo pero no cuentan en el balance. |
| Grupos | No intervienen en los equipos. Sí en el hospedaje. |
| Primer evento real | Usa hospedaje y equipos, por lo que ambos entran en el MVP. |
| Principio general | Toda función automática es opcional y solo sugiere. La decisión final es del usuario, que puede aceptar, modificar o descartar. |

---

## 2. Stack

### Arquitectura recomendada: una base de código, tres cáscaras

```
packages/core   → modelo, validaciones, migraciones SQL, exportar/importar,
                  algoritmos (hospedaje, equipos), pruebas. TS puro, sin UI.
packages/ui     → componentes React + tokens del diseño (colores, Nunito/Atkinson)
apps/shell-android (Capacitor)  → APK
apps/shell-desktop (Tauri 2)    → instalador / .exe portable de Windows
(opcional) build PWA            → mismo build servido desde una URL
```

Siguen siendo dos herramientas independientes: cada una se instala por separado y tiene su propia base de datos. Lo que se comparte es el código, aproximadamente entre el 80 y el 90 %. Compartirlo simplifica la integración futura, porque ambas apps usan el mismo serializador de exportación, las mismas migraciones y las mismas validaciones. El riesgo es que un bug en `core` afecta a las dos; se mitiga con pruebas fuertes y formato versionado.

### Elecciones por capa

| Capa | Elección | Motivo |
|---|---|---|
| Lenguaje y UI | TypeScript, React, Vite | Experiencia del desarrollador. |
| Estilos | CSS con variables a partir de los tokens del diseño | Sin librería de UI pesada. El diseño no usa sombras ni degradados. |
| Formularios | react-hook-form + zod | El mismo esquema valida en ambas apps y en la importación. |
| Arrastrar (solo PC) | `@dnd-kit` | En móvil se usa tocar y «Mover a…». |
| QR (Fase 3) | `qr-scanner` y `qrcode` | Funcionan sin conexión, en JS puro, con cámara o webcam. |
| Excel | `write-excel-file` y `read-excel-file`, cargados bajo demanda | Mucho más livianos que SheetJS o ExcelJS. |
| PDF | `pdf-lib` con fuente embebida, bajo demanda | Listas imprimibles y compartibles. |
| Imagen para WhatsApp | Canvas 2D dibujado a mano | Más fiable que capturar el DOM en WebViews viejos. |
| IDs | `uuid` v7 | `crypto.randomUUID()` no existe en WebViews antiguos. Los v7 se ordenan por tiempo. |
| Pruebas | Vitest para `core`, Playwright para la web | Los algoritmos puros son fáciles de probar. |

### Almacenamiento

| Opción | Pros | Contras |
|---|---|---|
| **A. SQLite nativo por plataforma (recomendada)** | Transacciones y recuperación ante cierres bruscos. En PC es un archivo visible, fácil de respaldar. Un solo esquema SQL en `core`. | Dos adaptadores (`@capacitor-community/sqlite` y el plugin SQL de Tauri) detrás de una interfaz `Repository`. |
| B. IndexedDB (Dexie) en ambas | Una sola implementación. | El sistema o el usuario pueden borrar los datos, es opaco y es difícil respaldar. |

Con A, cambiar a B más adelante solo toca los adaptadores.

### APK: alternativas

| Opción | Pros | Contras |
|---|---|---|
| **Capacitor (recomendada)** | Reutiliza todo el código. APK ≈ 5–10 MB. Sin tienda. | Depende del WebView del teléfono. |
| Kotlin + Compose | La más liviana y robusta en gama baja. | No comparte nada con la PC. Duplica UI y algoritmos. |
| Flutter | Comparte código con Windows. | APK más pesada y Dart nuevo para el desarrollador. |
| React Native | Rendimiento nativo. | No comparte UI con la PC y es débil en Windows. |

**Versión mínima: Android 7.0 (API 24), con 2 GB de RAM.** La condición real es el WebView (Chrome 60 o superior). En Android 7–9 el proveedor de WebView puede ser Chrome si está instalado. La app comprueba la versión al iniciar y avisa si es antigua. Compilar con `build.target` bajo (ES2017 o menos) y probar en 2 o 3 móviles viejos reales en la Fase 0. Si falla, la salida es Kotlin nativo para la APK; por eso `core` debe permanecer puro.

### PC: alternativas

| Opción | Pros | Contras |
|---|---|---|
| **Tauri 2 (recomendada)** | Instalador de 5–10 MB, SQLite real en un archivo, diálogos nativos de guardar e imprimir, copia automática a una carpeta, instala sin permisos de administrador. | Usa WebView2, presente en Win11 y en la mayoría de Win10 actualizados. Si falta, el instalador lo descarga (internet una vez) o se usa la variante offline de unos 130 MB. Curva de compilación con Rust (el código en Rust es mínimo). |
| Electron | Autocontenido y muy conocido. | 80–100 MB y más mantenimiento. Solo se justificaría con Windows 7/8. |
| PWA pura | Sin instalador. Mismo build. | Necesita internet una vez. Los datos viven en el perfil del navegador y se pueden borrar. |
| Servidor local portable | Reutiliza la web. | Hay que abrir consolas y puertos, hostil para voluntarios. |

**Por qué Tauri:** es lo más parecido a «instalar y listo» y da un archivo de datos que se copia y respalda a una carpeta, algo que la PWA no garantiza. Como todo sale de la misma base web, la PWA queda como plan B gratis.

---

## 3. Modelo de datos

**Convenciones.**
- Tipos: `UUID` = texto v7, `TS` = entero epoch ms UTC, `DATE` = `yyyy-mm-dd`, `B` = booleano 0/1.
- **Columnas base** (todas las tablas sincronizables): `id UUID PK`, `created_at TS`, `updated_at TS`, `deleted_at TS?`, `rev INT`, `device_id UUID`.
- Los borrados son lógicos. Al borrar a una persona, la lápida conserva solo el `id` y se vacían los datos personales.
- Los enums son texto con `CHECK`.

| Entidad | Campos (además de las base) | Restricciones y relaciones |
|---|---|---|
| **Event** | name, start_date, end_date, venue, organizer, offers_lodging B, status (activo/archivado), next_reg_number INT, owner_device_id, age_ranges (JSON: etiqueta, edad mín., edad máx.) | `age_ranges` debe cubrir todas las edades, sin huecos ni solapes. |
| **Church** (catálogo global) | name, name_norm, province_code, municipality_code, merged_into_id UUID? | UNIQUE(name_norm, municipality_code). `merged_into_id` permite fusionar duplicados sin perder referencias. |
| **Attendee** | event_id, registration_number INT, first_name, last_name1, last_name2?, name_norm, sex (M/F), age INT, church_id, phone?, province_code, municipality_code, needs_lodging B, notes?, guardian_id UUID?, consent_at TS? | UNIQUE(event_id, registration_number), nunca se reutiliza. CHECK edad 0–120. Índice (event_id, name_norm). `guardian_id` apunta a otro asistente del mismo evento. |
| **Couple** | event_id, attendee_a_id, attendee_b_id | a≠b, UNIQUE(a), UNIQUE(b). La app verifica que nadie esté en ambas columnas. |
| **Group** | event_id, name, kind (iglesia/preferencia/familia), church_id? | — |
| **GroupMember** | group_id, attendee_id | UNIQUE(attendee_id): máximo un grupo por persona. |
| **Lodging** | event_id, name, kind (albergue/casa), contact_phone?, directions?, zone?, distance_m INT?, is_active B, notes? | La capacidad total es la suma de sus habitaciones y no se guarda. |
| **Room** | lodging_id, name, capacity INT, fixed_type (null/hombres/mujeres/matrimonio), couple_allows_others B, is_active B | `fixed_type = null` significa libre: la define el primer ocupante. `couple_allows_others` solo aplica si la habitación aloja un matrimonio. |
| **LodgingAssignment** | event_id, room_id, attendee_id, source (manual/sugerida/sugerida-modificada), unit_ref?, warnings_json | UNIQUE(event_id, attendee_id). El hospedaje se deduce de la habitación. `warnings_json` guarda los avisos aceptados. |
| **Team** | event_id, name, color?, captain_id?, position INT | El capitán no cuenta en el balance. |
| **TeamMembership** | event_id, team_id, attendee_id, source (sugerido/manual/traslado) | UNIQUE(event_id, attendee_id). |
| **TeamMove** | event_id, attendee_id, from_team_id, to_team_id, kind (traslado/intercambio), swap_id?, had_warning B | Historial. |
| **ControlType** (global) | name, icon, is_builtin B | Desayuno, merienda, almuerzo, cena y los que se creen. |
| **ControlSession** | event_id, control_type_id, name, date, status (abierta/cerrada), opened_at, closed_at?, summary_json? | `summary_json` es una instantánea de los totales al cerrar. |
| **ControlRecord** | session_id, attendee_id, passed_at TS, method (nombre/número/qr/manual) | UNIQUE(session_id, attendee_id) WHERE deleted_at IS NULL. «Deshacer» marca `deleted_at`. |
| **Proposal** | event_id, kind (hospedaje/equipos), params_json, result_json, status (abierta/aceptada/descartada) | Persiste los borradores para no perderlos si el teléfono se apaga. |
| **Setting / BackupLog** | clave-valor del dispositivo | Local, no se exporta. Incluye device_id, hash del PIN y último respaldo. |

**Datos de referencia estáticos** (en el código): provincias y municipios de Cuba, unos 10 KB.

**Unidad de asignación.** No es una tabla. En tiempo de ejecución es una persona, una pareja o un grupo.

**Derivados, no guardados.** Pendientes de una sesión (asistentes vivos menos registros vivos), ocupación de habitaciones, estado de cada habitación (libre, hombres, mujeres, matrimonio) y composición de equipos.

### Formato de exportación

JSON con sobre versionado y checksum:

```json
{ "format": "mi-evento", "schema_version": 1, "exported_at": 1765000000000,
  "device_id": "…", "sha256": "…",
  "event": { "…": "…" },
  "tables": { "churches": [], "attendees": [], "couples": [], "lodgings": [], "rooms": [] } }
```

- **JSON:** respaldo e integración entre apps.
- **XLSX:** para humanos, una hoja por entidad.
- **CSV:** UTF-8 con BOM y separador `;`, que es lo que abre bien el Excel en español.

---

## 4. Hospedajes: reglas y algoritmo de sugerencia

### Reglas

| Situación | Comportamiento |
|---|---|
| Habitación de hombres o de mujeres | Solo personas de ese sexo. Si se rompe, se pide confirmación explícita. |
| Matrimonio | Máximo uno por habitación. La pareja nunca se separa. |
| Habitación de matrimonio con `couple_allows_others = false` | El matrimonio la ocupa entera. Las plazas restantes aparecen como «bloqueadas por el matrimonio» y cuentan como ocupadas. |
| Habitación de matrimonio con `couple_allows_others = true` | Sin restricción. Puede entrar cualquier persona de cualquier sexo, sin aviso ni bloqueo. Solo se respeta la capacidad. |
| Menor de 18 años | Solo un aviso, nunca un bloqueo. Aparece cuando comparte habitación con alguien de distinto sexo que no es su acompañante responsable. |
| Capacidad | Se respeta siempre. Superarla requiere confirmación explícita. |
| `fixed_type` | Se respeta. Romperlo requiere confirmación explícita. |

El estado de una habitación sin tipo fijo vuelve a «Libre» cuando queda vacía. Como el sexo se fija al ocupar, no existe un único número de plazas libres; cada hospedaje muestra algo como «2 habitaciones · 1 libre · 1 de hombres con 1 plaza libre».

### Algoritmo

**Principio.** Solo propone. Nunca escribe en `LodgingAssignment` sin que el usuario acepte.

**Entrada.** La unidad a ubicar (persona, matrimonio, grupo explícito o «todos los de la iglesia X que necesitan hospedaje»), las habitaciones activas con su estado actual, las asignaciones existentes y preferencias opcionales (permitir dividir, preferir cercanía, preferir llenar habitaciones ya abiertas).

**Preproceso.**
1. Se excluyen los miembros con `needs_lodging = false` y se muestran como excluidos.
2. Los miembros ya asignados se tratan como fijos.
3. Se forman átomos: una pareja es un átomo de tamaño 2, indivisible; una persona suelta es un átomo de tamaño 1. Cada átomo tiene clase H, M o P (pareja).

**Búsqueda.**
1. **Pareja:** una habitación libre o ya de matrimonio compatible, sin otro matrimonio.
2. **Hombres y mujeres sueltos:** se empaquetan en habitaciones de su sexo o libres. Primero se llenan las ya abiertas de ese sexo; luego se abre una libre.
3. **Hospedaje:** se prefiere que todo el grupo quede en el mismo hospedaje (por ejemplo, mujeres en una habitación y hombres en otra de la misma casa). Si no cabe, se reparte en hospedajes cercanos o del mismo tipo.
4. Se usa *beam search* con ancho 8 y se devuelven los 3 mejores planes. Con ≤30 átomos y ≤60 habitaciones cuesta milisegundos.

**Reglas sobre habitaciones de matrimonio abiertas a otros.** Las sugerencias automáticas no llenan sus plazas libres, porque eso se coordina con el matrimonio. Esas plazas se usan solo en asignación manual.

**Menores.** Se sugiere al menor junto a su acompañante responsable siempre que se pueda. Si el acompañante está en una habitación de su mismo sexo con plaza, esa es la primera opción. Si no cabe, se sugiere una habitación del sexo del menor y aparece el aviso.

**Puntuación** (menor es mejor, pesos configurables):

| Concepto | Penalización |
|---|---|
| Hospedajes usados por encima del mínimo | 100 por cada uno |
| Clase partida en trozos | 40 por cada partición |
| Zonas distintas o distancia máxima entre partes | 15 por unidad normalizada |
| Mezclar albergue y casa en un mismo plan | 10 |
| Dejar una persona sola cuando era posible 3+2 en lugar de 4+1 | 12 |
| Habitaciones usadas por encima del mínimo | 15 por cada una |
| Abrir una habitación libre cuando una ya abierta del mismo sexo tiene plaza | 20 |
| Plazas bloqueadas por un matrimonio en habitación exclusiva | 8 por plaza |
| Partir un mismo grupo entre habitaciones del mismo hospedaje | 5 |
| Plazas sobrantes (ajuste *best-fit*) | 5 por cada una |

El desempate es determinista (distancia, nombre, id): misma entrada produce misma salida, lo que permite pruebas de instantánea.

**Salida.**

```ts
type Suggestion = {
  rank: 1 | 2 | 3,
  placements: { atomIds: UUID[]; roomId: UUID; people: number }[],
  unplaced: { atomIds: UUID[]; reason: string }[],
  metrics: { lodgingsUsed: number; roomsUsed: number; splits: number; maxDistanceM?: number },
  warnings: string[],        // p. ej. «menor sin acompañante»
  explanation: string[]      // frases en español para el usuario
}
```

La UI usa el componente «Propuesta» del diseño (borde discontinuo y etiqueta). Ofrece Aceptar, Modificar (abre la asignación manual precargada) y Descartar.

### Casos límite

| Caso | Comportamiento |
|---|---|
| Capacidad total insuficiente | Plan parcial más lista de no ubicados, con aviso por clase: «faltan 3 plazas para mujeres». |
| Ninguna habitación admite un matrimonio | No hay planes. Se muestra el motivo. Se ofrece «separar el matrimonio» solo si el usuario lo activa. |
| Grupo mixto que no cabe en un hospedaje | Se divide por clase, prefiriendo hospedajes cercanos y del mismo tipo. |
| 5 mujeres y habitaciones de 2 | Propone 3+2 antes que 2+2+1 si hay una habitación de 3. |
| Parte del grupo ya está hospedada | Se fijan esos miembros y se da bonificación a las habitaciones del mismo hospedaje o cercanas. |
| Se reduce la capacidad de una habitación ocupada | Alerta de sobreasignación. No se mueve a nadie solo. |
| Se fija `fixed_type` en una habitación con ocupantes incompatibles | Se rechaza o se avisa con la lista de afectados. |
| Hospedaje sin habitaciones | No puede recibir asignaciones. La app lo indica al crear. |
| Asignación manual que incumple reglas | Se permite con confirmación explícita y queda en `warnings_json`. |
| Observaciones médicas | Se muestran como información en la propuesta. No afectan al cálculo. |

**Fase posterior: modo global.** «Sugerir para todos los pendientes» ordena primero lo más restringido, mejora con intercambios de búsqueda local y se presenta como una propuesta única con aceptación por fila.

### Vistas y salidas

- Vista de quién está hospedado dónde, por hospedaje y por habitación.
- Lista imprimible por hospedaje para el anfitrión: por defecto solo nombres y cantidad de personas, sin edad, teléfono ni observaciones. PDF en Android, impresión del sistema en PC.

---

## 5. Equipos: balanceo

**Estrategia A: rangos de edad por sexo**, con la sugerencia calculada persona por persona al registrar.

### Configuración por evento

El día del evento, antes de registrar, se definen:
- El número de equipos, con nombre y color.
- Los rangos de edad. La app trae una plantilla editable: <13, 13–17, 18–29, 30–49 y 50+. Deben cubrir todas las edades.

### Qué hace al registrar

La pantalla «Registro guardado» muestra el equipo sugerido con un motivo y dos botones, **Aceptar** y **Cambiar**. Puede dejarse sin equipo. La función central es pura:

```ts
suggestTeam(persona, equipos, rangos) → { team, reason }
```

Entre los equipos candidatos, ordena por:
1. **Candidatos:** solo los equipos cuyo tamaño sea el mínimo o el mínimo más 1. Así la diferencia de tamaño nunca supera 1.
2. Menos personas **en el mismo rango de edad** que la persona (el criterio que más pesa).
3. Menos personas **del mismo sexo dentro de ese rango**.
4. **Menor tamaño.**
5. Orden de los equipos, para que el resultado sea predecible.

Ejemplo de motivo: «Rojo es el equipo con menos jóvenes de 13–17 años: tiene 3 y los otros 4».

### Capitanes

Pertenecen al equipo, pero **no cuentan** en los contadores por edad, por sexo ni de tamaño. Si se designa capitán a alguien que estaba en otro equipo, la app pide confirmar el traslado. Si estaba contado, deja de contar y el panel se recalcula.

### Avisos de desbalance

Se avisa al asignar, trasladar o intercambiar cuando, tras la acción, la diferencia entre el equipo con más y el equipo con menos personas en un mismo rango de edad supera 1. No hay umbrales configurables. El aviso indica el rango y la diferencia, por ejemplo: «Rango 13–17: Rojo quedaría con 5 y Azul con 3 (diferencia 2)». Nunca bloquea: el usuario puede continuar. El sexo y el tamaño se muestran en el panel sin generar aviso.

### Comportamientos

| Situación | Comportamiento |
|---|---|
| Se cambian los rangos con gente ya registrada | Nadie se mueve solo. El panel se recalcula y muestra un banner con los equipos desbalanceados. |
| Se añade un equipo | Pasa a ser el de menor tamaño y recibe las siguientes sugerencias. Los ya asignados no se mueven. |
| Se edita la edad y cambia de rango | Se recalcula el panel y, si hay desbalance, aparece el aviso. |
| Personas registradas antes de crear los equipos | Botón «Sugerir equipos para los ya registrados». Procesa en orden de inscripción con la misma regla y se presenta como propuesta a revisar. |
| Registro en lote o importado | Se sugiere persona por persona. |

### Panel de composición

Muestra, por equipo, la cantidad de integrantes, la distribución por rango de edad y por sexo, y el capitán. Debe permitir ver el balance de un vistazo.

---

## 6. Control de comidas

- Tipos configurables (desayuno, merienda, almuerzo, cena y los que se quieran: entrega de materiales, taller…).
- Sesiones concretas, por ejemplo «Almuerzo del sábado».
- **Identificación en el MVP:** búsqueda por nombre (sin distinguir tildes) y número de inscripción con teclado numérico grande. Los resultados muestran nombre completo, iglesia y edad para distinguir homónimos.
- **QR en la Fase 3:** cada código se genera y se envía por WhatsApp; la lectura se hace con la cámara del dispositivo.
- Aviso claro cuando la persona ya pasó en esa sesión. «Deshacer» marca el registro como borrado.
- Contadores en tiempo real: inscritos, pasaron y faltan, con lista de pendientes.
- Quien llega sin estar inscrito se registra desde la misma pantalla.
- Al cerrar la sesión: exportar a CSV, Excel o imagen para WhatsApp. La imagen se dibuja con Canvas 2D (1080×1350, unos 100–200 KB), espera a que carguen las fuentes y se comparte con el menú del sistema. Contiene solo agregados, sin nombres.

---

## 7. MVP y fases

| Fase | Contenido | Semanas |
|---|---|---|
| **0. Cimientos** | Monorepo, `core` (modelo, migraciones, exportar/importar, `Repository`), tokens y componentes base, fuentes locales, CI que genera APK e instalador. Pruebas en móviles viejos reales y spikes de WebView, Tauri y SQLite. | 2–3 |
| **1. MVP** | Eventos (crear, editar, elegir). Catálogo de iglesias con provincia y municipio. Asistentes: registro, edición, búsqueda, aviso de duplicado, número de inscripción, lista, matrimonios, grupos y acompañante responsable. **Hospedajes:** alta con habitaciones, asignación manual con las reglas, vista de quién está dónde y lista imprimible. **Equipos:** configuración de equipos y rangos, sugerencia al registrar, asignación manual, traslado e intercambio con avisos, panel de composición. **Comidas:** tipos, sesiones, marcar por nombre o número, aviso «ya pasó», contadores, pendientes, cierre, CSV e imagen de WhatsApp. **Respaldo:** automático y manual, exportar e importar JSON, restaurar. Modo ensayo y PIN opcional. Ambas apps. | 12–15 |
| **2** | Sugerencia automática de hospedaje, reportes básicos, importación de asistentes por CSV/Excel. | 5–6 |
| **3** | QR (generar y leer), cifrado de la base y de los respaldos, reportes completos, modo global de hospedaje. | 4–5 |
| **4** | Integración entre la APK y la web con importación y vista previa de diferencias. Opcional: sincronización por Wi‑Fi local o nube. | 4–6 |

El MVP concentra hospedaje y equipos. Si hay presión de fecha, conviene cortar funciones que no se usen en el primer evento antes que retrasarlo.

### Reportes (básicos en Fase 2, completos en Fase 3)

Totales por sexo, rango de edad, iglesia, hospedaje y equipo. Listados exportables e imprimibles.

---

## 8. Integración futura entre la APK y la web

Hoy cada evento tiene un solo dispositivo que escribe, así que no hace falta resolver conflictos de edición concurrente. El diseño deja todo listo para después.

- **Desde el inicio:** UUID v7, `created_at`, `updated_at`, `rev` y `deleted_at` en todo; `device_id` y `owner_device_id` en el evento; `schema_version` en el formato de exportación.
- **Traspaso de un evento:** «Exportar paquete» genera un `.mievento.json` con checksum. Al importarlo en la otra app, si el evento no existe se crea; si existe, se muestra una **vista previa de diferencias** («12 nuevos, 3 modificados, 0 conflictos») y el usuario confirma antes de aplicar.
- **Resolución:** por registro. Gana el de mayor `rev`, con `updated_at` y `device_id` como desempate. Los conflictos reales se listan para revisión manual.
- **Aviso de propiedad:** al exportar para traspaso, el evento queda marcado como «entregado al dispositivo X». Si alguien sigue editándolo en el origen, la app avisa.
- **Reloj del dispositivo:** muchos móviles tienen la fecha mal. Se avisa si la fecha es anterior a la de compilación, y la comparación usa `rev` y no solo la hora.
- **Después:** tabla `change_log` para exportar solo los cambios desde la última vez, y sincronización por Wi‑Fi local (la PC sirve un pequeño servidor al que se conecta el móvil) o nube opcional, sobre el mismo formato.

---

## 9. Respaldo de datos

Estrategia en capas:

1. **Continua:** SQLite con transacciones. Si el móvil se apaga o la app se cierra, no se pierde nada ya guardado.
2. **Instantáneas automáticas rotativas:** cada ~10 minutos de actividad y tras acciones importantes (cerrar una sesión de comida, terminar un lote de registros). Se conservan las últimas 20 dentro de la app.
3. **Copia fuera del dispositivo:**
   - Botón «Hacer copia» siempre visible.
   - Aviso si pasaron más de 30 minutos o más de 20 cambios sin copia externa.
   - En Android, compartir el archivo por WhatsApp (a un chat de organizadores), Bluetooth o memoria. En PC, carpeta automática `Documentos/MiEvento/Respaldos` y, si el usuario lo elige, una segunda carpeta o USB.
   - Recordatorio al final de cada sesión de comida y de cada día.
4. **Restaurar:** importar el JSON verificando checksum y conteos, con vista previa.
5. **Último recurso:** imprimir o exportar a PDF la lista de asistentes antes del evento para operar en papel.

Pendiente de confirmar en el spike de la Fase 0: dónde puede escribir una copia automática en Android 10+ por las restricciones de almacenamiento. Si no se puede automatizar, el recordatorio con «Compartir» sigue cubriendo la capa 3.

---

## 10. Privacidad

- **Datos sensibles:** sexo, edad, teléfono, estado civil (matrimonios) y observaciones, que pueden incluir datos de salud. Además, la pertenencia a una iglesia es un dato delicado en muchos contextos.
- **Todo local.** Sin nube, sin telemetría, sin analíticas. Para la APK, intentar **no declarar el permiso INTERNET** en la versión final: es una garantía verificable de que no puede enviar datos. Hay que confirmar en el spike que Capacitor funciona sin él.
- **Minimización:** solo los campos necesarios. El campo de observaciones advierte «No escribas datos de salud si no es imprescindible».
- **Acceso:** PIN opcional al abrir o tras inactividad. En la Fase 3, cifrado de la base con SQLCipher (clave en Android Keystore) y respaldos con contraseña (WebCrypto AES-GCM).
- **Exportaciones con selector de campos.** Por defecto, la lista para el anfitrión lleva solo nombres y cantidad de personas. La imagen de WhatsApp contiene solo agregados.
- **Consentimiento:** mensaje breve en el registro y marca de consentimiento del tutor para menores de 18.
- **Retención:** función «Cerrar evento y borrar datos personales» que conserva solo estadísticas agregadas. La app recuerda hacerlo pasado un plazo configurable.
- **Aviso al compartir copias** por WhatsApp: contienen todo; enviar solo a organizadores de confianza.
- **Marco legal:** en Cuba rige la Ley 149 de 2022 de Protección de Datos Personales, hasta donde se sabe; confirmarlo con asesoría local. Los principios de finalidad, minimización, consentimiento y seguridad aplican igual.

---

## 11. Distribución e instalación

### Android

- APK universal firmada, ≈ 5–10 MB, nombrada `MiEvento-1.0.0.apk`.
- **Guardar la keystore en al menos dos sitios.** Si se pierde, los teléfonos ya instalados no podrán actualizarse.
- Se reparte por WhatsApp como *documento*, Bluetooth, USB, SHAREit o Xender.
- Tarjeta de una página con capturas: «Permitir instalar desde esta fuente» e «Instalar de todas formas» en Play Protect.
- Idea para la Fase 2: botón «Compartir esta app» dentro de la app, para pasar la APK a otro móvil (requiere un pequeño plugin nativo).

### Windows

- Instalador Tauri por usuario (sin permisos de administrador), ≈ 6–10 MB. También un `.exe` portable.
- Sin certificado de firma, Windows muestra SmartScreen («Más información → Ejecutar de todas formas»). Un certificado cuesta dinero cada año. Si no se compra, documentarlo con capturas y publicar el SHA‑256 por un canal confiable. Windows Defender puede dar falsos positivos con ejecutables sin firmar.
- Paquete en carpeta o USB: instalador slim (≈ 10 MB), instalador completo con WebView2 (≈ 130 MB), la APK y una guía PDF de una página.
- Las actualizaciones se instalan encima y los datos se conservan.

### Capacitación

Un evento de ensayo precargado, tutorial de primer uso, guía de una página y un video corto de 3 minutos. Lista de comprobación de «antes del evento»: cargar hospedajes, definir equipos y rangos, hacer copia, cargar la batería.

---

## 12. Riesgos

| Riesgo | Mitigación |
|---|---|
| WebView antiguo en móviles viejos | Prueba temprana en móviles reales, build de bajo target, aviso al iniciar. Plan B: Kotlin nativo para la APK. |
| Pérdida de datos por apagón, robo o móvil roto | Capas de respaldo (§9) con recordatorios y copia externa. |
| Duplicados y nombres de iglesia mal escritos | Detección aproximada, catálogo con autocompletado, herramienta para fusionar iglesias. |
| Homónimos en el control de comidas | Mostrar iglesia y edad en los resultados. |
| Reglas de habitaciones difíciles de usar en el momento | Habitaciones libres por defecto, «Duplicar habitación», confirmaciones claras en vez de bloqueos. |
| Rangos de edad mal definidos el día del evento | Plantilla por defecto y validación de que cubran todas las edades. |
| Usuarios no técnicos borran o cometen errores | Deshacer en acciones frecuentes, confirmaciones en las destructivas, modo ensayo. |
| SmartScreen y Play Protect asustan | Guías con capturas, checksum, canal de distribución confiable. |
| Pérdida de la keystore | Copias en varios lugares, documentado. |
| Datos sensibles expuestos al compartir copias | Selector de campos, aviso, cifrado de respaldos (Fase 3). |
| Dos dispositivos editando el mismo evento por error | Marca de propietario, importación con vista previa y resolución por registro. |
| Fecha del móvil incorrecta | Aviso al iniciar. Comparar por `rev`. |
| Curva de Tauri o Rust | El spike de la Fase 0 lo detecta pronto. Plan B: Electron o PWA, que reutilizan todo. |
| MVP muy grande por incluir hospedaje y equipos | Cortar funciones secundarias antes que retrasar la fecha. |
| Un solo desarrollador | Documentación y `core` pequeño y bien probado. |

---

## 13. Esfuerzo estimado

Un desarrollador, dedicación completa.

| Fase | Semanas |
|---|---|
| 0. Cimientos y spikes | 2–3 |
| 1. MVP (incluye hospedaje con habitaciones y equipos) | 12–15 |
| 2. Sugerencia de hospedaje, reportes básicos, importación | 5–6 |
| 3. QR, cifrado, reportes completos, modo global | 4–5 |
| 4. Integración | 4–6 |
| **Total** | **≈ 27–35 semanas (6,5–8 meses)** |

Margen de ±30 %. Supuestos: el diseño visual ya existe (ahorra unas 3–4 semanas), no hay revisión de tienda y las pruebas en dispositivos reales están incluidas. A media jornada, el calendario se duplica. Lo más incierto es la Fase 0 y el comportamiento del WebView en gama baja.

---

## 14. Mapa de pantallas

**Navegación.** En móvil, barra inferior con **Evento, Registrar, Comidas, Equipos, Más** (el diseño ya la trae). En PC, barra lateral con las mismas secciones más Hospedajes y Reportes. «Más» agrupa Asistentes, Hospedajes, Reportes, Respaldo, Ajustes y Ayuda.

### Ya diseñadas (en el diseño de referencia)

| Pantalla | Móvil | PC |
|---|---|---|
| Identidad visual | ✅ | ✅ |
| Registro de asistente, con aviso de duplicado | ✅ | ✅ |
| Registro guardado | ✅ | — |
| Panel de evento vacío | ✅ | — |
| Control de comidas: éxito | ✅ | ✅ |
| Control de comidas: «ya pasó» | ✅ | — |
| Equipos | ✅ | ✅ (con arrastrar) |
| Confirmar traslado entre equipos | ✅ | — |
| Sugerencia de hospedaje | — | ✅ |
| Cierre de sesión de comida | — | ✅ |
| Imagen de resumen para WhatsApp | ✅ | ✅ |

### Faltan por diseñar

- **Eventos:** selección y lista de eventos, crear y editar evento, panel de evento con datos (solo existe vacío).
- **Asistentes:** lista con búsqueda y filtros, detalle y edición, vincular matrimonio, crear y gestionar grupos, gestionar y fusionar catálogo de iglesias, campo «Acompañante responsable» en el registro.
- **Comidas:** resultados de búsqueda con homónimos, lista de pendientes, tipos y sesiones (crear y configurar), cierre en versión móvil, lector de QR (Fase 3).
- **Hospedajes:** lista; alta de hospedaje con lista de habitaciones («Añadir» y «Duplicar»); vista del hospedaje con ocupantes y tipo de cada habitación; asignación manual; sugerencia en móvil; lista imprimible por anfitrión. Adaptar la «Sugerencia de hospedaje» para que muestre habitación y tipo.
- **Equipos:** configuración de equipos y rangos de edad, equipo sugerido dentro de «Registro guardado», panel de composición por rango, traslado en PC e intercambio.
- **Reportes:** totales por sexo, edad, iglesia, hospedaje y equipo; listados exportables.
- **Transversales:** respaldo, restaurar y exportar/importar, ajustes (PIN, copias), pantalla de bloqueo, onboarding y ayuda, aviso de WebView antiguo.

### Señalamientos sobre el diseño de referencia

1. **Fuentes.** El diseño carga Nunito y Atkinson Hyperlegible desde Google Fonts. Sin conexión no cargan: empaquetarlas en local (WOFF2 con subconjunto latino, unas decenas de KB) y mantener la caída a fuente del sistema.
2. **Registro móvil.** La pantalla mide 1640 px de alto, demasiado con el teclado abierto en un móvil pequeño. Mostrar arriba solo nombre, apellidos, sexo, edad e iglesia, y poner el resto (teléfono, provincia, hospedaje, observaciones, matrimonio, grupo, acompañante) en una sección «Más datos» plegable. «Necesita hospedaje» solo aparece si el evento ofrece hospedaje.
3. **Imagen de WhatsApp.** Dibujar con Canvas 2D, esperando a `document.fonts.load()`. No usar captura del DOM.
4. **Arrastrar y soltar.** Costoso en móvil de gama baja: solo en PC. En móvil, tocar y «Mover a…», más un equivalente por teclado en PC.
5. **Impresión.** En PC, el diálogo del sistema. En Android la impresión desde WebView es mala: la salida es PDF compartible.
6. **Búsqueda en comidas.** Falta el estado con varios resultados (homónimos), que debe mostrar iglesia y edad.

> Nota: de los tableros del diseño solo se revisaron en detalle la identidad visual, el registro móvil, el control de comidas móvil y la imagen de WhatsApp. El resto se ubicó por su título.

---

## 15. Suposiciones abiertas

Siguen en pie y pueden corregirse:

- El sexo es binario (H/M), como en el diseño.
- Una persona pertenece a un solo grupo.
- Los matrimonios no ligan a las personas en los equipos.
- Las sugerencias automáticas de hospedaje no llenan las plazas libres de una habitación de matrimonio abierta a otros.
- Una pareja ocupa 2 plazas de la capacidad de una habitación.
- El capitán queda fuera de todos los contadores del balance, incluido el de tamaño.

## Siguiente paso

Empezar por la Fase 0, comenzando por las pruebas en móviles viejos y el spike de Tauri, porque son lo que más puede cambiar el stack. En paralelo, diseñar las pantallas nuevas con el mismo estilo del diseño de referencia.
