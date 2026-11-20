# Calculadora de Batería: especificación de diseño

Tokens exactos en `design/tokens.json`. Capturas de cada pantalla en `reference/screens/` (en claro y oscuro, a 360 × 800 dp). Para ver cómo se comporta de verdad, abre `reference/prototype/prototype.html` en Chrome a 360 px de ancho.

## 1. Principios

1. **La respuesta primero.** La tarjeta de resultado va arriba, con la hora a 48 sp. Se recalcula mientras se escribe; no hay botón «Calcular».
2. **«¿Llego?» se entiende sin leer.** Siempre van juntos el color, el ícono (✓ o !) y una frase. Nunca solo el color.
3. **Tono tranquilo.** El rojo es ladrillo y no ocupa nunca toda la pantalla. Si no llega, la app dice cómo arreglarlo.
4. **Pensada para una mano.** Las pestañas van abajo. Todo lo táctil mide al menos 48 × 48 dp. El botón principal queda al final, cerca del pulgar.
5. **Lo secundario va plegado:** «Más opciones», «Cómo se calcula» y la nota de aproximación.
6. **Ligera.** Solo vectores, sin imágenes ni animaciones complejas; como mucho, transiciones de 150 ms.

## 2. Estructura

```
┌ Barra superior (56 dp, se queda fija arriba) ───────┐
│ [🔋 Tu batería: 10,24 kWh ✎]          [ajustes ⚙] │
├ Franja de respuesta (56 dp; aparece al desaparecer  ┤
│  la tarjeta de resultado de la vista o al escribir) │
│  [luna] Hasta las 9:08 a. m.         [✓ Llegas]     │
├─────────────────────────────────────────────────────┤
│ Tarjeta de resultado                                │
│ Tarjeta «Datos del consumo» / «Datos de la noche» / │
│  «Datos de la carga»                                │
│ Nota de aproximación                                │
│ [ Compartir resultado ]  (botón principal)          │
├ Barra inferior (82 dp) ─────────────────────────────┤
│ [ (reloj) Duración ] [ (luna) De noche ] [ (enchufe) Cargando con la red ] │
└─────────────────────────────────────────────────────┘
```

- **Márgenes y espacios:** 12 dp a los lados de la pantalla; 12 dp entre tarjetas; 16 dp de relleno dentro de las tarjetas; 18 dp entre bloques de datos.
- **Pestaña activa:** fondo `sel`, ícono dentro de una píldora ámbar de 56 × 28 dp y texto en negrita. La inactiva lleva el texto en `tx2`.
- **Barra superior:** a la izquierda, el botón «Tu batería», con borde `ln`, alto 48 y radio 24; abre la hoja de batería. A la derecha, el botón de ajustes (48 × 48).
- **Cambio de pestaña:** la pantalla vuelve arriba.

## 3. Pantallas

Hay una captura por pantalla en `reference/screens/` (`flujo-claro-*`, `flujo-oscuro-*`, `estados-*`, `peor-caso-*`, `reporte-*` e `ingles-*`).

0. **Duración** (la primera pestaña):
   - Tarjeta: encabezado «Duración · 600 W de consumo» con el ícono de reloj y el botón de compartir.
   - «La batería dura» (17 sp, `tx2`), la duración (48 sp, negrita) y debajo «Empezando a las 9:00 p. m., se acaba cerca de las 9:08 a. m.» (17 sp, negrita).
   - Con hora de fin: veredicto «Alcanza hasta las 2:00 a. m.» (verde) o «No alcanza hasta las 6:00 a. m.» (ladrillo, con «Probar con N W») y la regla, con una bandera en el círculo del marcador en lugar del sol.
   - Tres cifras: que puedes usar, baja cada hora y útil por cada 1%.
   - «Datos del consumo»: la batería deslizable con su campo, el consumo, «Desde qué hora» (campo de hora con el botón «Ahora» y la ayuda «Si no la cambias, es la hora actual.»), «Hasta qué hora (opcional)» (campo de hora con ícono de bandera; vacío dice «Sin hora de fin»; con valor lleva al lado un botón X de 48 × 56 dp, «Quitar la hora de fin»), «Más opciones» y «Cómo se calcula».
   - Los campos de porciento, consumo, pérdidas y reserva son los mismos que en De noche: lo que se cambia en una pestaña se ve en la otra.
1. **Primera vez** (solo si no hay batería):
   - Arriba, el ícono (56, radio 16), «Calculadora de Batería», el texto «Funciona sin internet» con un ✓ y una línea de introducción.
   - Una tarjeta «¿De qué tamaño es tu batería?» con el selector [En kWh | En voltios y Ah], los tres atajos y el campo «U otra capacidad».
   - Abajo, la ayuda y el botón «Empezar», deshabilitado hasta tener una capacidad válida.
2. **De noche · llega:**
   - Tarjeta: encabezado «De noche · 600 W de consumo» con el botón de compartir (48 dp, en la esquina).
   - «La batería dura hasta las» (17 sp, `tx2`) y la hora (48 sp, negrita).
   - Veredicto en verde.
   - Regla de la noche.
   - Tres cifras.
3. **De noche · no llega:** veredicto en ladrillo, con el botón secundario pequeño «Probar con 430 W». En la regla, el tramo que falta va rayado.
4. **Cargando con la red:**
   - «Tarda en cargar», la duración grande y debajo «Llega al 100% cerca de la 1:31 p. m.» (17 sp, negrita).
   - La regla de carga.
   - El aviso azul «Gasta de la red unos 7,96 kWh».
   - Dos cifras.
5. **Hoja «Tu batería» en kWh:**
   - Hoja inferior con un asa y el título más el botón de cerrar (48 dp).
   - El selector y los atajos (el elegido lleva borde de 2,5 dp `tx`, fondo `sel` y un ✓ en la esquina, por fuera).
   - El campo «Capacidad» y el botón «Listo».
6. **Hoja «Tu batería» en voltios y Ah:** dos campos en cuadrícula de 2 columnas («Voltios» y «Amperios hora»), una ayuda y el resultado en una caja `infBg` con el ícono «=»: «Tu batería es de unos 10,24 kWh».
7. **Más opciones** (desplegable dentro de «Datos de la noche»):
   - El interruptor «Contar las pérdidas del inversor (10%)» con su ayuda.
   - «Reserva de la batería»: [−] [ 6 % ] [+], con botones de 56 dp, ayuda y el botón de texto «Volver a 6%» (deshabilitado si ya vale 6).
8. **Ajustes** (hoja): Idioma · Language [Español | English], Colores de la pantalla [Auto | Claro | Oscuro], el interruptor «Letra grande», el botón «Listo» y «Versión … · Funciona sin internet».

Estados (§5 de SPEC):

- Vacío, campo inválido, valor raro, reserva inválida.
- No hace falta cargar.
- Duración de días: «unos 59 días»; la regla termina con una flecha.
- Teclado abierto.
- Carga con la potencia vacía.

## 4. Componentes

- **Campo numérico con unidad:** alto mínimo 56, radio 14, borde de 1,5 dp `ln`, fondo `sf`. Valor a 22 sp en negrita, alineado a la izquierda; la unidad (W, %, kWh…) va dentro, a la derecha, a 17 sp en negrita `tx2`. Etiqueta encima (16 sp, negrita); ayuda y mensajes debajo.

  | Estado | Aspecto |
  |---|---|
  | Enfocado | Borde de 2 dp `focus` y halo de 4 dp `infBg` |
  | Error | Borde de 2 dp `bad`. Mensaje en `bad`, negrita, con ícono de alerta en círculo |
  | Aviso | Borde de 2 dp `warn`. Mensaje en una caja `warnBg`, con triángulo |
  | Nota | Texto `inf` con ícono «i» |
  | Deshabilitado | Borde discontinuo `dis`, fondo `disBg` |

- **Campo de hora:** parece un campo con ícono de reloj. Al tocarlo abre el selector de hora de Material, no el teclado. Junto al de «Hora ahora» va el botón con borde «Ahora» (mínimo 72 × 56 dp).
- **Batería deslizable** (el indicador principal, en los datos):
  - Cuerpo con borde de 3 dp `tx`, radio 12, alto 56 y relleno interior de 5 dp; borne de 7 × 22 dp.
  - En el modo noche: la reserva rayada `rsv` (0..rsv) y el relleno ámbar (rsv..pct).
  - En el modo carga: el relleno ámbar (0..pct), el rayado `chg` (pct..tgt) y **dos manijas**.
  - Manija: 16 × 82 dp, fondo `sf`, borde de 3 dp `tx` y radio 8. Su zona táctil mide al menos 48 dp de ancho. Con foco lleva un halo de 4 dp `focus`.
  - Se arrastra, se toca o se ajusta con el teclado del lector de pantalla (`Semantics` con valor e incremento/decremento de 1). Siempre va con su campo numérico (en noche, el campo de 100 dp va a la derecha; en carga hay dos campos debajo: «Ahora» y «Cargar hasta»). En carga, una manija no puede cruzar a la otra.
  - Leyenda debajo con muestras de 16 dp: «Reserva 6% (no se usa)» y «Puedes usar 79%».
- **Regla de la noche:**
  - Pista de 14 dp, radio 7, color `track` y contorno de 1,5 dp `ln`; el relleno es ámbar.
  - Marcador de fin: barra de 4 × 28 dp `tx`.
  - Sol: círculo de 38 dp, fondo `sf`, borde de 2,5 dp `tx` e ícono de sol de 20 dp.
  - Leyenda en 3 columnas: etiqueta a 13 sp `tx2` con un ícono de 15 dp, y valor a 15 sp en negrita. Con 320 dp y letra grande pasa a una lista de filas (etiqueta a la izquierda, valor a la derecha).
- **Regla de carga:** igual, pero el tramo rápido va verde `chg` sólido y el lento rayado. Lleva una marca en el 90% y otra al final.
- **Tarjeta de resultado:** fondo `sf`, radio 22, relleno de 14/16 y separación de 12. Arriba el encabezado (14 sp, negrita, `tx2`, con ícono de 18 dp) y, a la derecha, el botón de compartir.
- **Aviso o veredicto:** caja con radio 16 y relleno de 12/14. Lleva un círculo de 36 dp de color sólido con el ícono en el color del fondo, un título a 18 sp en negrita del color del tipo, y el texto a 15 sp `tx`.

  | Tipo | Ícono | Colores |
  |---|---|---|
  | ok | ✓ | `ok` / `okBg` |
  | bad / err | ! | `bad` / `badBg` |
  | info | enchufe | `inf` / `infBg` |
  | warn | triángulo | `warn` / `warnBg` |
  | neutral | rayo | `tx2` / `sf2` |

- **Tarjeta de estado** (vacío, error, ya cargada): círculo de 44 dp, título a 22 sp en negrita, texto a 16 sp `tx2` y, si hace falta, el botón secundario «Ir al dato».
- **Cifras:** cuadrícula de N columnas con separación de 6. Cada celda: fondo `sf2`, radio 12, relleno de 8, valor a 16 sp en negrita sin partir y etiqueta a 13 sp `tx2`. Con 320 dp y letra grande pasan a filas (etiqueta a la izquierda, valor a la derecha) dentro de una sola caja `sf2`.
- **Selector segmentado:** contenedor con fondo `sf2`, borde de 1,5 dp `ln`, radio 15 y relleno de 4. Opciones de 48 dp de alto con radio 11. La elegida va **invertida** (fondo `tx`, texto `bg`, negrita y un ✓); las demás, transparentes y sin ícono.
- **Interruptor:** 56 × 32 dp. Encendido: fondo `tx` con la bolita `bg` y un ✓. Apagado: fondo `sf2`, borde `ln` y bolita `ln`. La etiqueta y la ayuda van a la izquierda; toda la fila es táctil.
- **Desplegable:** línea de 1 dp `ln2` arriba, fila de 56 dp con ícono, título (16 sp, negrita), resumen (14 sp `tx2`) y una flecha que gira 180° al abrirse.
- **Botón principal:** alto 56, radio 16, fondo `amb`, texto `onAmb` a 17 sp en negrita, con ícono de 22 dp.
  - Presionado: fondo `ambTx`, texto `bg`.
  - Enfocado: anillo de 3 dp `focus`, separado 3 dp.
  - Deshabilitado: fondo `disBg`, texto `dis` y borde discontinuo.
- **Botón secundario:** borde de 2 dp `tx`, transparente; presionado, fondo `sf2`. La versión pequeña mide 48 dp.
- **Botón de texto:** subrayado; deshabilitado, en `dis` y sin subrayado.
- **Franja de respuesta:** 56 dp, fondo `sf`, borde inferior `ln2` y una sombra suave. Lleva el ícono del modo, el texto a 18 sp en negrita («Dura 12 h 8 min» / «Hasta las 9:08 a. m.» / «Tarda 3 h 16 min») y una píldora con el estado (✓ Alcanza / ! No alcanza / ✓ Llegas / ! No llegas / ! Revisa).
- **Hoja inferior:** radio superior 28, asa de 40 × 5 dp, velo `scrim` y relleno de 20. Se cierra con la X, tocando fuera o con el botón atrás.

## 5. Comportamiento

- **Teclado:** al enfocar un campo, la pantalla se desplaza hasta que el campo queda centrado por encima del teclado (`Scrollable.ensureVisible`). La franja de respuesta sigue arriba y se actualiza al escribir. Se oculta la barra inferior mientras el teclado está abierto.
- **Franja de respuesta:** aparece cuando la tarjeta de resultado sale de la vista (por ejemplo, con `VisibilityDetector` o comprobando su posición) o al abrir el teclado.
- **Letra grande:** multiplica la escala de texto por 1,2 *sobre* la escala del sistema (`MediaQuery.textScaler`). Por debajo de 400 dp de ancho, la letra grande activa el modo estrecho: cifras y leyendas en lista y el botón de batería solo con «10,24 kWh».
- **Tema:** Auto sigue `MediaQuery.platformBrightness`. Ver la tabla de colores claro y oscuro en `tokens.json`.
- **Accesibilidad:**
  - TalkBack lee la respuesta (región `liveRegion` en la tarjeta).
  - Las imágenes decorativas se excluyen de la lectura.
  - Los botones que solo tienen ícono llevan etiqueta.
  - El orden de foco sigue el orden visual.
  - Contraste AA verificado (tabla `contrast` en tokens).
- **Ancho:** se diseñó a 360 dp. Debe funcionar de 320 a 411 dp, y por encima, con un ancho máximo de contenido de 480 dp centrado. Solo vertical.

## 6. Ícono y pantalla de inicio

- **Ícono adaptativo** (en `assets/icon/`):
  - Fondo: `#0D1626` plano.
  - Frente: una batería crema `#F7EEDC` con el sol ámbar `#F0A93B` saliendo dentro, en la zona segura de 66 dp.
  - Monocromo: la misma forma en un solo color.
  - Hay SVG de 108 × 108 y PNG de 512 y 1024. Conviene generar los VectorDrawable a partir de los SVG.
- **Pantalla de inicio:** la de Android 12+ (`flutter_native_splash` o la configuración nativa): el ícono sobre `#EEF2F6` en claro y `#0D1626` en oscuro. Sin animación.
- **Nombre en el escritorio:** «Batería» (es) / «Battery» (en). Nombre completo: «Calculadora de Batería».

## 7. Tipografía e íconos

- **Fuente:** Atkinson Hyperlegible 400 y 700 (TTF en `assets/fonts/`, licencia OFL; ocupa unos 76 KB). Si hay que ahorrar peso, Roboto del sistema con los mismos tamaños.
- **Íconos:** de trazo de 2 dp con puntas redondeadas, en caja de 24 dp. Las rutas están en el objeto `ICONS` del prototipo. Úsalos como `CustomPainter`/`Path` o SVG mediante `flutter_svg`, o genera una pequeña fuente de íconos. **No uses** Material Icons completos ni emojis.
