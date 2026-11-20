# Calculadora de Batería: especificación funcional

Fuente de verdad del comportamiento. Si algo choca con las imágenes de `reference/screens/`, manda este documento. Si algo choca con el prototipo `reference/prototype/prototype-src.html`, manda este documento, salvo en los textos (ver §8).

## 1. Qué es

Una app Android para personas que tienen paneles solares, inversor y batería en casa. Responde dos preguntas:

1. **De noche:** ¿hasta qué hora me alcanza la batería con el consumo que tengo, y llego al amanecer?
2. **Cargando con la red:** ¿cuánto tarda en cargarse la batería con la corriente de la calle, y cuánta energía de la red gasta?

Se reparte como APK por WhatsApp y Telegram. Funciona **100% sin internet**: no pide el permiso `INTERNET`, no tiene analítica, cuentas, anuncios ni historial.

Usuarios: gente que no sabe de informática, de cualquier edad. A menudo usan el teléfono a una mano, de noche o durante un apagón. Lo que más importa es entender la respuesta de un vistazo.

## 2. Alcance (no añadir nada más)

- **Batería** (se pide una vez y se recuerda): capacidad en kWh, o voltios y Ah. Atajos: 5,12, 10,24 y 15 kWh.
- **De noche:** porciento ahora, consumo (W), hora ahora y hora en que vuelve el sol. Opciones avanzadas: pérdidas del inversor (10%) y reserva (6% por defecto, de 0 a 90%).
- **Cargando con la red:** porciento ahora, hasta qué porciento cargar, potencia de carga (en W, o en A × V) y hora ahora.
- **Reporte:** una imagen PNG vertical de 1080 px de ancho, para compartir o guardar.
- **Ajustes:** idioma (es/en; la primera vez, el del teléfono), tema (auto/claro/oscuro) y letra grande (×1,2).
- Mensajes de ayuda y de error junto a cada campo.

## 3. Constantes

| Nombre | Valor | Uso |
|---|---|---|
| `RESERVE_DEFAULT` | 6 (%) | Reserva por defecto |
| `RESERVE_MIN/MAX` | 0 / 90 (%) | Rango válido de la reserva |
| `LOSS_FACTOR` | 0,9 | Pérdidas del inversor (−10%) y pérdidas al cargar |
| `SLOW_FROM` | 90 (%) | Del 90% al 100% el cargador va a la mitad de la potencia |
| `WEIRD_POWER_W` | 10 000 | Consumo o potencia de carga mayor que esto: aviso «¿Seguro?» |
| `WEIRD_CAPACITY_KWH` | 100 | Capacidad mayor que esto: aviso «¿Seguro?» |

## 4. Fórmulas (no cambiar)

### 4.1 Capacidad

- Modo kWh: `cap = kWh`.
- Modo V/Ah: `cap = V × Ah / 1000`. Debajo de los campos se muestra «Tu batería es de unos X kWh».

### 4.2 De noche

Entradas: `pct` (0–100), `W` (≥ 0), `rsv` (0–90), `loss` (bool), `now` y `sun` (minutos desde medianoche; `now` puede faltar).

```
s      = loss ? 0.9 : 1
i      = max(0, pct − rsv)            // % útil
c      = cap × i / 100 × s            // kWh utilizables
d      = W / 1000                     // kW
u      = d > 0 ? c / d : ∞            // horas de duración
perPct = cap × 0.01 × s               // kWh útiles por cada 1% (se muestra en Wh)
wm     = round(60 × u)                // minutos de duración
```

Qué muestra la tarjeta, en este orden de prioridad:

- `i == 0`: «Ya está en la reserva». La batería ya está en la reserva del `rsv`%; no queda energía para usar.
- `d == 0`: «Sin consumo». La energía se mantiene: tienes `c` kWh guardados.
- `wm < 1`: dura «menos de 1 min».
- Falta `now`, o `wm ≥ 1440`: «La batería dura `dur(u)`» (duración, sin hora).
- En otro caso: «La batería dura hasta la(s) `now + 60·u`» (hora de fin).

**Veredicto** (solo si hay `now` y `sun`, `i > 0` y `d > 0`):

```
e = sun − now; if e < 0: e += 1440          // minutos hasta el sol
if e > 0:
  a    = e / 60                             // horas hasta el sol
  need = d × a
  si c ≥ need  o  wm ≥ e  →  LLEGA
     left    = max(0, c − need)
     pctDawn = round(rsv + left / (cap × s) × 100)
     texto: «Sobran unos {q(left)}. A {hora sol} marcará cerca de {pctDawn}%.»
            (si left < 0,001: «La energía alcanza justo hasta {hora sol}.»)
  si no  →  NO LLEGA
     k  = c / a × 1000;  k = k ≥ 10 ? 10·floor(k/10) : floor(k)     // W máximos para llegar
     falta = need − c
     texto: «Faltan unos {q(falta)}. Para llegar a {hora sol}, baja el consumo a {k} W o menos.»
            (si k == 0: «Faltan unos {q(falta)}. Casi no queda energía para usar.»)
     botón «Probar con {k} W» solo si 0 < k < W. Al tocarlo, pone W = k.
```

**Regla de la noche** (indicador gráfico; solo cuando hay veredicto):

```
days = wm ≥ 1440
span = days ? a / 0.06 : max(u, a) × 1.04
fill = days ? 100% : min(100, u / span × 100)        // barra ámbar
sunX = clamp(a / span × 100, 4, 98)                  // marcador del sol
```

- Si no llega, el tramo entre `fill` y `sunX` va rayado en color de reserva.
- Si `days`, en lugar del marcador de fin hay una flecha.
- Leyenda de tres columnas en el orden en que aparecen en la barra: Ahora, Sale el sol y Se acaba (o Se acaba y luego Sale el sol).

**Cifras:**

- `c` en kWh, con 2 decimales (4 si `c < 0,1`).
- Duración `dur(u)`.
- `perPct` en Wh: 1 decimal si es menor que 10, si no, 0.

**Paso a paso:**

1. `pct% − rsv% de reserva = i% útil`. Si `i == 0`: `pct% no pasa de la reserva del rsv%: queda 0% útil`.
2. `cap × i% = cap·i/100`, y si `loss`, «; quitando el 10% de pérdidas quedan `c`». Valores en kWh con hasta 3 decimales.
3. Solo si `d > 0` e `i > 0`: `c ÷ d de consumo = dur(u)`. `d` en kW con hasta 3 decimales, o en W si `d < 1`.

### 4.3 Cargando con la red

```
W  = modo W ? watts : amps × volts            // mostrar «Equivale a unos X W de carga.» en modo A
si pct o tgt no están en 0..100  → error
si W vacío o ≤ 0                 → «Falta la potencia de carga»
si tgt ≤ pct                     → «No hace falta cargar» (tarjeta en verde, no es un error)
c     = tgt − pct
dKwh  = cap × c / 100                         // kWh por cargar
u     = W / 1000                              // kW
g     = max(0, min(tgt, 90) − pct)            // % del tramo rápido
m     = max(0, tgt − max(pct, 90))            // % del tramo lento
vMin  = round(cap·g/100 / u × 60)
wMin  = round(cap·m/100 / (u/2) × 60)
horas = (vMin + wMin) / 60
porHora = min(100, u / cap × 100)             // «≈ 24%» (1 decimal si < 10)
red   = dKwh / 0.9                            // kWh que gasta de la red
```

- Grande: `dur(horas)`.
- Debajo, si hay `now` y `horas < 24`: «Llega al `tgt`% cerca de la(s) `now + horas`».
- Pista de carga: tramo rápido verde sólido y tramo lento rayado. Leyenda: Ahora | Llega al 90% (solo si hay dos tramos) | Llega al `tgt`%.
- Aviso de información: «Gasta de la red unos `red` kWh. Al cargar se pierde cerca del 10%. Es lo que se suma a la factura de la luz.»
- Cifras: `dKwh` kWh «por cargar» y `≈ porHora%` «sube cada hora».

**Paso a paso:**

- Si el modo es A: `A × V = W de carga`.
- `tgt% − pct% = c% por cargar`.
- `cap × c% = dKwh`.
- Si hay dos tramos:
  - «De pct% a 90%: … ÷ u = dur»
  - «De 90% a tgt%, a mitad de potencia: … ÷ u/2 = dur»
  - «Total: a + b = total»
- Si hay un solo tramo, la línea simple: `dKwh ÷ u de carga = dur`.

### 4.4 Formatos

- `dur(h)`:
  - `"∞"` si no es finito.
  - Si `round(h·60) ≥ 1440`: «unos N días» (N con 1 decimal si es menor que 10), o «cerca de 1 día».
  - Si no: «X h Y min» (se omite «Y min» si es 0, y «X h» si es 0).
- `q(kWh)`: si es menor que 0,1, en Wh; si no, en kWh con 2 decimales.
- Números: separador decimal según el idioma (es: coma; en: punto). **Sin separador de miles.**
- Horas: siguen la configuración de 12/24 h del teléfono (`MediaQuery.alwaysUse24HourFormat`). En español el artículo depende de la hora: «la 1:31», «las 2:30».

## 5. Entrada de números y validación

- Teclado numérico (`TextInputType.numberWithOptions(decimal: true)`). Se aceptan dígitos y un separador, coma o punto.
- Si se escribe otro carácter, se elimina y aparece el aviso «Solo se pueden escribir números.» hasta salir del campo.
- **Lectura de miles:** en W, Ah y A, un patrón `^\d{1,3}[.,]\d{3}$` («25.000») se lee como 25000. Aparece la nota de información: «Se entendió: 25000 W. Si querías 25 W, escríbelo sin punto.»
- **Los errores se muestran al salir del campo, no mientras se escribe.** Mientras tanto, la tarjeta de resultado ya dice qué falta.

| Campo | Regla | Mensaje |
|---|---|---|
| Capacidad, V, Ah, W de carga, A, V de carga | número > 0 | «Escribe un número.» / «Debe ser mayor que 0.» |
| Porciento ahora, Cargar hasta | 0..100 | «Escribe un número del 0 al 100.» |
| Consumo | número ≥ 0 (vacío = estado vacío, no error) | «Escribe un número.» |
| Reserva | 0..90 | «Escribe un número del 0 al 90.» Además abre «Más opciones» |
| W > 10 000 o capacidad > 100 kWh | aviso, no bloquea | «¿Seguro? Es más de lo normal en una casa.» |

Estados de la tarjeta cuando no hay resultado:

- **Vacío:** gris, sin rojo.
- **Corregir:** rojo, con el botón «Ir al dato», que lleva el foco y desplaza la pantalla al campo.
- **En la reserva**, **Sin consumo**, **No hace falta cargar**.

## 6. Persistencia

Todo se guarda en el teléfono (`shared_preferences`) en cada cambio:

- La batería.
- Todos los campos.
- Las opciones avanzadas.
- La pestaña activa.
- El idioma, el tema y la letra grande.

La «hora ahora» **no** se recuerda: al abrir la app, toma la hora actual. Existe una acción «Borrar mis datos y empezar de nuevo» en Ajustes, con confirmación de dos toques dentro de la app.

## 7. Reporte PNG

Una imagen de 1080 px de ancho, de alto variable (unos 1700–2000 px), **siempre en tema claro**, con este contenido:

1. **Cabecera** azul noche: ícono, «Reporte de batería», el modo (De noche / Cargando con la red), y la fecha y hora.
2. **Frase de entrada** y respuesta grande (≈ 156 px de altura de letra).
3. **Veredicto o aviso** de la red.
4. **Regla** (de noche).
5. **Tres cifras.**
6. **Datos usados**, en dos columnas, junto a **Así se calcula**.
7. **Nota de aproximación** y pie con el nombre de la app.

Implementación sugerida: un widget `ReportCard` de 1080 dp de ancho, renderizado fuera de pantalla con `RepaintBoundary.toImage(pixelRatio: 1)`.

- **Compartir:** abre la hoja de compartir del sistema (`share_plus`) con el PNG.
- **Guardar en el teléfono:** guarda en la galería (paquete `gal`, sin pedir permisos en Android 10+).
- Nombre de archivo: `reporte-noche.png` / `reporte-carga.png` (en inglés: `night-report.png` / `charging-report.png`).

## 8. Textos

Todos los textos, en español e inglés, están en el objeto `STR` de `reference/prototype/prototype-src.html`. Pásalos a ARB (`lib/l10n/app_es.arb`, `app_en.arb`) con sus parámetros.

- El español es el idioma de referencia: diseña para que quepa el español.
- Respeta la redacción salvo errores evidentes.
- Hay textos que solo existen en el prototipo y sobran en la app: «Prototipo…», «Este navegador no puede…».

## 9. Casos de prueba

`docs/test-vectors.json` tiene 12 casos de noche y 8 de carga. Se sacaron ejecutando el prototipo con `es-ES` y horario de 24 h: la entrada y los textos esperados de la tarjeta, cifras y pasos.

Son el contrato de la lógica: los tests unitarios de `CalculatorService` y de los formateadores deben reproducirlos (los valores; los textos, con la misma configuración de idioma y 24 h).
