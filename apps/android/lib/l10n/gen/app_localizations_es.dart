// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Calculadora de Batería';

  @override
  String get offline => 'Funciona sin internet';

  @override
  String get intro =>
      'Mira cuánto te dura la batería, si llegas al amanecer y cuánto tarda en cargar con la corriente de la calle.';

  @override
  String get sizeQ => '¿De qué tamaño es tu batería?';

  @override
  String get batHow => 'Cómo conoces el tamaño';

  @override
  String get modeKwh => 'En kWh';

  @override
  String get modeAh => 'En voltios y Ah';

  @override
  String get common => 'Baterías comunes';

  @override
  String get otherCap => 'U otra capacidad';

  @override
  String get capacity => 'Capacidad';

  @override
  String get capHint => 'Aparece en la etiqueta o en el manual de la batería.';

  @override
  String get volts => 'Voltios';

  @override
  String get ah => 'Amperios hora';

  @override
  String get ahHint => 'Están en la etiqueta; por ejemplo, 51,2 V y 200 Ah.';

  @override
  String get startHint =>
      'Elige o escribe el tamaño para empezar. Se guarda en el teléfono y puedes cambiarlo después.';

  @override
  String get start => 'Empezar';

  @override
  String get yourBat => 'Tu batería';

  @override
  String get settings => 'Ajustes';

  @override
  String get close => 'Cerrar';

  @override
  String get ok => 'Listo';

  @override
  String get tabsAria => 'Qué quieres calcular';

  @override
  String get tabNight => 'De noche';

  @override
  String get tabCharge => 'Cargando con la red';

  @override
  String get nightData => 'Datos de la noche';

  @override
  String get pctNow => 'Porciento que marca ahora';

  @override
  String get load => 'Consumo de la casa';

  @override
  String get phLoad => 'Ej.: 600';

  @override
  String get loadHint => 'Míralo en el inversor o en su app. Si sube y baja, usa un promedio.';

  @override
  String get timeNow => 'Hora ahora';

  @override
  String get nowBtn => 'Ahora';

  @override
  String get sunrise => 'Hora en que vuelve el sol';

  @override
  String get sunHint => 'Cuando los paneles empiezan a cargar.';

  @override
  String get more => 'Más opciones';

  @override
  String get loss => 'Contar las pérdidas del inversor (10%)';

  @override
  String get lossHint => 'Más realista. Apágalo para ver la cuenta simple.';

  @override
  String get rsvLabel => 'Reserva de la batería';

  @override
  String get rsvHint =>
      'La batería se apaga sola al llegar a este porciento. Cámbialo solo si tu inversor usa otro. Puede ser de 0 a 90%.';

  @override
  String get rsvReset => 'Volver a 6%';

  @override
  String get minus => 'Bajar 1%';

  @override
  String get plus => 'Subir 1%';

  @override
  String get how => 'Cómo se calcula';

  @override
  String get howSub => 'Paso a paso de la cuenta';

  @override
  String legRsv(String r) {
    return 'Reserva $r% (no se usa)';
  }

  @override
  String legUse(String u) {
    return 'Puedes usar $u%';
  }

  @override
  String get nNote =>
      'Es un aproximado. El consumo cambia durante la noche (el refrigerador arranca y para; el aire o la plancha lo suben mucho). Se supone que los paneles no cargan hasta que vuelve el sol.';

  @override
  String get share => 'Compartir resultado';

  @override
  String get chargeData => 'Datos de la carga';

  @override
  String get batLevel => 'Porciento de la batería';

  @override
  String get nowShort => 'Ahora';

  @override
  String get tgt => 'Cargar hasta';

  @override
  String get legNow => 'Tiene ahora';

  @override
  String get legToCharge => 'Lo que se va a cargar';

  @override
  String get power => 'Potencia de carga';

  @override
  String get powHow => 'Cómo conoces la potencia de carga';

  @override
  String get modeW => 'Sé los watts';

  @override
  String get modeA => 'Sé los amperios';

  @override
  String get powW => 'Potencia de carga en watts';

  @override
  String get phPow => 'Ej.: 2500';

  @override
  String get amps => 'Amperios';

  @override
  String get powHintW => 'Es la potencia de carga desde la red que tiene configurada el inversor.';

  @override
  String get powHintA => 'La corriente de carga desde la red del inversor; por ejemplo, 50 A en una batería de 51,2 V.';

  @override
  String aResult(String x) {
    return 'Equivale a unos $x W de carga.';
  }

  @override
  String get cNote =>
      'Es un aproximado. Del 90% al 100% el cargador va más despacio, por eso ese tramo se calcula a la mitad de la potencia. Si se va la corriente, la carga se detiene.';

  @override
  String get langHint => 'La primera vez se usa el idioma del teléfono.';

  @override
  String get themeL => 'Colores de la pantalla';

  @override
  String get thAuto => 'Auto';

  @override
  String get thLight => 'Claro';

  @override
  String get thDark => 'Oscuro';

  @override
  String get themeHint => 'Auto sigue al teléfono.';

  @override
  String get bigText => 'Letra grande';

  @override
  String get bigHint => 'Los textos se ven un 20% más grandes.';

  @override
  String get resetAll => 'Borrar mis datos y empezar de nuevo';

  @override
  String get numBad => 'Escribe un número.';

  @override
  String get gt0 => 'Debe ser mayor que 0.';

  @override
  String get pctBad => 'Escribe un número del 0 al 100.';

  @override
  String get tgtBad => '«Cargar hasta» debe ser un número del 0 al 100.';

  @override
  String get rsvBad => 'Escribe un número del 0 al 90.';

  @override
  String get weird => '¿Seguro? Es más de lo normal en una casa.';

  @override
  String get onlyNums => 'Solo se pueden escribir números.';

  @override
  String get sepDot => 'punto';

  @override
  String get sepComma => 'coma';

  @override
  String kNight(String w) {
    return 'De noche · $w W de consumo';
  }

  @override
  String get kNight0 => 'De noche';

  @override
  String kCharge(String w) {
    return 'Cargando con la red · $w W';
  }

  @override
  String get kCharge0 => 'Cargando con la red';

  @override
  String get leadUntil => 'La batería dura hasta las';

  @override
  String get leadUntil1 => 'La batería dura hasta la';

  @override
  String get leadFor => 'La batería dura';

  @override
  String get almost => 'menos de 1 min';

  @override
  String get okT => 'Llegas al amanecer';

  @override
  String okTxt(String k, String t, String p) {
    return 'Sobran unos $k. A $t marcará cerca de $p%.';
  }

  @override
  String okJust(String t) {
    return 'La energía alcanza justo hasta $t.';
  }

  @override
  String get badT => 'No llegas al amanecer';

  @override
  String badTxt(String k, String t, String w) {
    return 'Faltan unos $k. Para llegar a $t, baja el consumo a $w W o menos.';
  }

  @override
  String badLow(String k) {
    return 'Faltan unos $k. Casi no queda energía para usar.';
  }

  @override
  String tryW(String w) {
    return 'Probar con $w W';
  }

  @override
  String get lNow => 'Ahora';

  @override
  String get lSun => 'Sale el sol';

  @override
  String get lEnd => 'Se acaba';

  @override
  String inDays(String d) {
    return 'en $d';
  }

  @override
  String get fUsable => 'que puedes usar';

  @override
  String get fDur => 'de duración';

  @override
  String get fPer => 'útil por cada 1%';

  @override
  String get emptyT => 'Falta el consumo de la casa';

  @override
  String get emptyX => 'Escríbelo abajo y aquí verás hasta qué hora te dura la batería.';

  @override
  String get fixT => 'Falta corregir un dato';

  @override
  String get fixPct => 'El porciento debe ser un número del 0 al 100.';

  @override
  String get fixW => 'El consumo debe ser un número.';

  @override
  String get fixRsv => 'Revisa la reserva: debe ser un número del 0 al 90.';

  @override
  String get goField => 'Ir al dato';

  @override
  String get inRsvT => 'Ya está en la reserva';

  @override
  String inRsvX(String r) {
    return 'La batería ya está en la reserva del $r%: no queda energía para usar.';
  }

  @override
  String get noLoadT => 'Sin consumo';

  @override
  String noLoadX(String k) {
    return 'Sin consumo, la energía se mantiene: tienes $k kWh guardados.';
  }

  @override
  String get cLead => 'Tarda en cargar';

  @override
  String gridT(String k) {
    return 'Gasta de la red unos $k kWh';
  }

  @override
  String get gridX => 'Al cargar se pierde cerca del 10%. Es lo que se suma a la factura de la luz.';

  @override
  String get fToCharge => 'por cargar';

  @override
  String get fPerHour => 'sube cada hora';

  @override
  String lAt(String p) {
    return 'Llega al $p%';
  }

  @override
  String get alreadyT => 'No hace falta cargar';

  @override
  String alreadyX(String a, String b) {
    return 'La batería ya está en $a%, igual o más que el $b% que quieres.';
  }

  @override
  String get noPowT => 'Falta la potencia de carga';

  @override
  String get noPowX => 'Pon la potencia de carga: debe ser mayor que 0.';

  @override
  String get fixC => 'Los porcientos deben ser de 0 a 100.';

  @override
  String lReserve(String a, String r, String u) {
    return '$a% − $r% de reserva = $u% útil';
  }

  @override
  String lBelow(String a, String r) {
    return '$a% no pasa de la reserva del $r%: queda 0% útil';
  }

  @override
  String lRun(String k, String w, String d) {
    return '$k ÷ $w de consumo = $d';
  }

  @override
  String lAmps(String a, String v, String w) {
    return '$a A × $v V = $w W de carga';
  }

  @override
  String lDelta(String b, String a, String d) {
    return '$b% − $a% = $d% por cargar';
  }

  @override
  String lKwh(String c, String d, String k) {
    return '$c × $d% = $k';
  }

  @override
  String lTime(String k, String p, String t) {
    return '$k ÷ $p de carga = $t';
  }

  @override
  String lFast(String a, String b, String k, String p, String t) {
    return 'De $a% a $b%: $k ÷ $p = $t';
  }

  @override
  String lSlow(String a, String b, String k, String p, String t) {
    return 'De $a% a $b%, a mitad de potencia: $k ÷ $p = $t';
  }

  @override
  String lTotal(String a, String b, String c) {
    return 'Total: $a + $b = $c';
  }

  @override
  String get shareT => 'Compartir el reporte';

  @override
  String get shareDesc => 'Una imagen con la respuesta, los datos y el paso a paso. Se lee bien en el chat.';

  @override
  String get shareImg => 'Compartir imagen';

  @override
  String get saveImg => 'Guardar en el teléfono';

  @override
  String get shareHint => '«Compartir» abre la lista del teléfono: elige WhatsApp, Telegram u otra app.';

  @override
  String saved(String n) {
    return 'Imagen guardada: $n';
  }

  @override
  String get fixFirst => 'Corrige los datos para compartir el resultado.';

  @override
  String get rTitleN => 'Reporte de batería';

  @override
  String get rSubN => 'De noche';

  @override
  String get rSubC => 'Cargando con la red';

  @override
  String get dataUsed => 'Datos usados';

  @override
  String get howR => 'Así se calcula';

  @override
  String get dBat => 'Batería';

  @override
  String get dLevel => 'Porciento ahora';

  @override
  String get dLoad => 'Consumo';

  @override
  String get dAt => 'Hora del cálculo';

  @override
  String get dSun => 'Vuelve el sol';

  @override
  String get dRsv => 'Reserva de la batería';

  @override
  String get dLoss => 'Pérdidas del inversor';

  @override
  String get lossYes => 'Incluidas (10%)';

  @override
  String get lossNo => 'No incluidas';

  @override
  String get dTgt => 'Cargar hasta';

  @override
  String get dPow => 'Potencia de carga';

  @override
  String footN(String r) {
    return 'Es un aproximado: el consumo cambia durante la noche. La batería se apaga al $r% para cuidar su salud.';
  }

  @override
  String get footC =>
      'Es un aproximado: del 90% al 100% el cargador va más despacio, por eso ese tramo se calcula a la mitad de la potencia.';

  @override
  String get fileN => 'reporte-noche';

  @override
  String get fileC => 'reporte-carga';

  @override
  String get stripErr => 'Falta corregir un dato';

  @override
  String get stripEmpty => 'Falta el consumo';

  @override
  String get hasta => 'Hasta ';

  @override
  String get tagOk => 'Llegas';

  @override
  String get tagBad => 'No llegas';

  @override
  String get tagFix => 'Revisa';

  @override
  String get enPhrase => 'En ';

  @override
  String version(String v) {
    return 'Versión $v · Funciona sin internet';
  }

  @override
  String days(String d) {
    String _temp0 = intl.Intl.selectLogic(d, {'1': 'cerca de 1 día', 'other': 'unos $d días'});
    return '$_temp0';
  }

  @override
  String moreS(String on, String r) {
    String _temp0 = intl.Intl.selectLogic(on, {'true': 'sí', 'other': 'no'});
    return 'Pérdidas del inversor: $_temp0 · Reserva: $r%';
  }

  @override
  String readAs(String v) {
    return 'Se entendió: $v.';
  }

  @override
  String readAsAlt(String v, String alt, String sep) {
    return 'Se entendió: $v. Si querías $alt, escríbelo sin $sep.';
  }

  @override
  String lCap(String c, String u, String x) {
    return '$c × $u% = $x';
  }

  @override
  String lCapLoss(String c, String u, String x, String y) {
    return '$c × $u% = $x; quitando el 10% de pérdidas quedan $y';
  }

  @override
  String cSub(String p, String t) {
    return 'Llega al $p% cerca de $t';
  }

  @override
  String get batLblPrefix => 'Tu batería: ';

  @override
  String get ahResultPrefix => 'Tu batería es de unos ';

  @override
  String trying(String w) {
    return 'Probando con $w W';
  }

  @override
  String get appShort => 'Batería';

  @override
  String get confirmReset => 'Toca otra vez para borrar todo';

  @override
  String example(String x) {
    return 'Ej.: $x';
  }

  @override
  String get stripTakes => 'Tarda ';

  @override
  String get saveFailed => 'No se pudo guardar la imagen.';

  @override
  String get saveNoPerm => 'Para guardar, permite el acceso a fotos y archivos en los ajustes del teléfono.';

  @override
  String timeToast(String t) {
    return 'Hora: $t';
  }

  @override
  String get tabRuntime => 'Duración';

  @override
  String kRuntime(String w) {
    return 'Duración · $w W de consumo';
  }

  @override
  String get kRuntime0 => 'Duración';

  @override
  String get runtimeData => 'Datos del consumo';

  @override
  String get rtEmptyX => 'Escríbelo abajo y aquí verás cuánto te dura la batería.';

  @override
  String rtSub(String t1, String t2) {
    return 'Empezando a $t1, se acaba cerca de $t2';
  }

  @override
  String get fromTime => 'Desde qué hora';

  @override
  String get fromHint => 'Si no la cambias, es la hora actual.';

  @override
  String get toTime => 'Hasta qué hora (opcional)';

  @override
  String get toHint => 'Ponla para saber si la batería te alcanza hasta esa hora.';

  @override
  String get toEmpty => 'Sin hora de fin';

  @override
  String get toClear => 'Quitar la hora de fin';

  @override
  String rtOkT(String t) {
    return 'Alcanza hasta $t';
  }

  @override
  String rtBadT(String t) {
    return 'No alcanza hasta $t';
  }

  @override
  String get lStart => 'Inicio';

  @override
  String get lUntil => 'Hasta';

  @override
  String get fPerHourDown => 'baja cada hora';

  @override
  String get stripLasts => 'Dura ';

  @override
  String get tagReach => 'Alcanza';

  @override
  String get tagShort => 'No alcanza';

  @override
  String get rNote =>
      'Es un aproximado. El consumo cambia según lo que esté encendido (el refrigerador arranca y para; el aire o la plancha lo suben mucho). Se supone que los paneles no cargan mientras tanto.';

  @override
  String get rSubR => 'Duración';

  @override
  String get fileR => 'reporte-duracion';

  @override
  String get dFrom => 'Desde';

  @override
  String get dTo => 'Hasta';

  @override
  String footR(String r) {
    return 'Es un aproximado: el consumo cambia según lo que esté encendido. La batería se apaga al $r% para cuidar su salud.';
  }
}
