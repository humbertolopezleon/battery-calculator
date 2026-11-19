import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @appName.
  ///
  /// In es, this message translates to:
  /// **'Calculadora de Batería'**
  String get appName;

  /// No description provided for @offline.
  ///
  /// In es, this message translates to:
  /// **'Funciona sin internet'**
  String get offline;

  /// No description provided for @intro.
  ///
  /// In es, this message translates to:
  /// **'Mira hasta qué hora te alcanza la batería de noche y cuánto tarda en cargar con la corriente de la calle.'**
  String get intro;

  /// No description provided for @sizeQ.
  ///
  /// In es, this message translates to:
  /// **'¿De qué tamaño es tu batería?'**
  String get sizeQ;

  /// No description provided for @batHow.
  ///
  /// In es, this message translates to:
  /// **'Cómo conoces el tamaño'**
  String get batHow;

  /// No description provided for @modeKwh.
  ///
  /// In es, this message translates to:
  /// **'En kWh'**
  String get modeKwh;

  /// No description provided for @modeAh.
  ///
  /// In es, this message translates to:
  /// **'En voltios y Ah'**
  String get modeAh;

  /// No description provided for @common.
  ///
  /// In es, this message translates to:
  /// **'Baterías comunes'**
  String get common;

  /// No description provided for @otherCap.
  ///
  /// In es, this message translates to:
  /// **'U otra capacidad'**
  String get otherCap;

  /// No description provided for @capacity.
  ///
  /// In es, this message translates to:
  /// **'Capacidad'**
  String get capacity;

  /// No description provided for @capHint.
  ///
  /// In es, this message translates to:
  /// **'Aparece en la etiqueta o en el manual de la batería.'**
  String get capHint;

  /// No description provided for @volts.
  ///
  /// In es, this message translates to:
  /// **'Voltios'**
  String get volts;

  /// No description provided for @ah.
  ///
  /// In es, this message translates to:
  /// **'Amperios hora'**
  String get ah;

  /// No description provided for @ahHint.
  ///
  /// In es, this message translates to:
  /// **'Están en la etiqueta; por ejemplo, 51,2 V y 200 Ah.'**
  String get ahHint;

  /// No description provided for @startHint.
  ///
  /// In es, this message translates to:
  /// **'Elige o escribe el tamaño para empezar. Se guarda en el teléfono y puedes cambiarlo después.'**
  String get startHint;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Empezar'**
  String get start;

  /// No description provided for @yourBat.
  ///
  /// In es, this message translates to:
  /// **'Tu batería'**
  String get yourBat;

  /// No description provided for @settings.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get settings;

  /// No description provided for @close.
  ///
  /// In es, this message translates to:
  /// **'Cerrar'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In es, this message translates to:
  /// **'Listo'**
  String get ok;

  /// No description provided for @tabsAria.
  ///
  /// In es, this message translates to:
  /// **'Qué quieres calcular'**
  String get tabsAria;

  /// No description provided for @tabNight.
  ///
  /// In es, this message translates to:
  /// **'De noche'**
  String get tabNight;

  /// No description provided for @tabCharge.
  ///
  /// In es, this message translates to:
  /// **'Cargando con la red'**
  String get tabCharge;

  /// No description provided for @nightData.
  ///
  /// In es, this message translates to:
  /// **'Datos de la noche'**
  String get nightData;

  /// No description provided for @pctNow.
  ///
  /// In es, this message translates to:
  /// **'Porciento que marca ahora'**
  String get pctNow;

  /// No description provided for @load.
  ///
  /// In es, this message translates to:
  /// **'Consumo de la casa'**
  String get load;

  /// No description provided for @phLoad.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 600'**
  String get phLoad;

  /// No description provided for @loadHint.
  ///
  /// In es, this message translates to:
  /// **'Míralo en el inversor o en su app. Si sube y baja, usa un promedio.'**
  String get loadHint;

  /// No description provided for @timeNow.
  ///
  /// In es, this message translates to:
  /// **'Hora ahora'**
  String get timeNow;

  /// No description provided for @nowBtn.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get nowBtn;

  /// No description provided for @sunrise.
  ///
  /// In es, this message translates to:
  /// **'Hora en que vuelve el sol'**
  String get sunrise;

  /// No description provided for @sunHint.
  ///
  /// In es, this message translates to:
  /// **'Cuando los paneles empiezan a cargar.'**
  String get sunHint;

  /// No description provided for @more.
  ///
  /// In es, this message translates to:
  /// **'Más opciones'**
  String get more;

  /// No description provided for @loss.
  ///
  /// In es, this message translates to:
  /// **'Contar las pérdidas del inversor (10%)'**
  String get loss;

  /// No description provided for @lossHint.
  ///
  /// In es, this message translates to:
  /// **'Más realista. Apágalo para ver la cuenta simple.'**
  String get lossHint;

  /// No description provided for @rsvLabel.
  ///
  /// In es, this message translates to:
  /// **'Reserva de la batería'**
  String get rsvLabel;

  /// No description provided for @rsvHint.
  ///
  /// In es, this message translates to:
  /// **'La batería se apaga sola al llegar a este porciento. Cámbialo solo si tu inversor usa otro. Puede ser de 0 a 90%.'**
  String get rsvHint;

  /// No description provided for @rsvReset.
  ///
  /// In es, this message translates to:
  /// **'Volver a 6%'**
  String get rsvReset;

  /// No description provided for @minus.
  ///
  /// In es, this message translates to:
  /// **'Bajar 1%'**
  String get minus;

  /// No description provided for @plus.
  ///
  /// In es, this message translates to:
  /// **'Subir 1%'**
  String get plus;

  /// No description provided for @how.
  ///
  /// In es, this message translates to:
  /// **'Cómo se calcula'**
  String get how;

  /// No description provided for @howSub.
  ///
  /// In es, this message translates to:
  /// **'Paso a paso de la cuenta'**
  String get howSub;

  /// No description provided for @legRsv.
  ///
  /// In es, this message translates to:
  /// **'Reserva {r}% (no se usa)'**
  String legRsv(String r);

  /// No description provided for @legUse.
  ///
  /// In es, this message translates to:
  /// **'Puedes usar {u}%'**
  String legUse(String u);

  /// No description provided for @nNote.
  ///
  /// In es, this message translates to:
  /// **'Es un aproximado. El consumo cambia durante la noche (el refrigerador arranca y para; el aire o la plancha lo suben mucho). Se supone que los paneles no cargan hasta que vuelve el sol.'**
  String get nNote;

  /// No description provided for @share.
  ///
  /// In es, this message translates to:
  /// **'Compartir resultado'**
  String get share;

  /// No description provided for @chargeData.
  ///
  /// In es, this message translates to:
  /// **'Datos de la carga'**
  String get chargeData;

  /// No description provided for @batLevel.
  ///
  /// In es, this message translates to:
  /// **'Porciento de la batería'**
  String get batLevel;

  /// No description provided for @nowShort.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get nowShort;

  /// No description provided for @tgt.
  ///
  /// In es, this message translates to:
  /// **'Cargar hasta'**
  String get tgt;

  /// No description provided for @legNow.
  ///
  /// In es, this message translates to:
  /// **'Tiene ahora'**
  String get legNow;

  /// No description provided for @legToCharge.
  ///
  /// In es, this message translates to:
  /// **'Lo que se va a cargar'**
  String get legToCharge;

  /// No description provided for @power.
  ///
  /// In es, this message translates to:
  /// **'Potencia de carga'**
  String get power;

  /// No description provided for @powHow.
  ///
  /// In es, this message translates to:
  /// **'Cómo conoces la potencia de carga'**
  String get powHow;

  /// No description provided for @modeW.
  ///
  /// In es, this message translates to:
  /// **'Sé los watts'**
  String get modeW;

  /// No description provided for @modeA.
  ///
  /// In es, this message translates to:
  /// **'Sé los amperios'**
  String get modeA;

  /// No description provided for @powW.
  ///
  /// In es, this message translates to:
  /// **'Potencia de carga en watts'**
  String get powW;

  /// No description provided for @phPow.
  ///
  /// In es, this message translates to:
  /// **'Ej.: 2500'**
  String get phPow;

  /// No description provided for @amps.
  ///
  /// In es, this message translates to:
  /// **'Amperios'**
  String get amps;

  /// No description provided for @powHintW.
  ///
  /// In es, this message translates to:
  /// **'Es la potencia de carga desde la red que tiene configurada el inversor.'**
  String get powHintW;

  /// No description provided for @powHintA.
  ///
  /// In es, this message translates to:
  /// **'La corriente de carga desde la red del inversor; por ejemplo, 50 A en una batería de 51,2 V.'**
  String get powHintA;

  /// No description provided for @aResult.
  ///
  /// In es, this message translates to:
  /// **'Equivale a unos {x} W de carga.'**
  String aResult(String x);

  /// No description provided for @cNote.
  ///
  /// In es, this message translates to:
  /// **'Es un aproximado. Del 90% al 100% el cargador va más despacio, por eso ese tramo se calcula a la mitad de la potencia. Si se va la corriente, la carga se detiene.'**
  String get cNote;

  /// No description provided for @langHint.
  ///
  /// In es, this message translates to:
  /// **'La primera vez se usa el idioma del teléfono.'**
  String get langHint;

  /// No description provided for @themeL.
  ///
  /// In es, this message translates to:
  /// **'Colores de la pantalla'**
  String get themeL;

  /// No description provided for @thAuto.
  ///
  /// In es, this message translates to:
  /// **'Auto'**
  String get thAuto;

  /// No description provided for @thLight.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get thLight;

  /// No description provided for @thDark.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get thDark;

  /// No description provided for @themeHint.
  ///
  /// In es, this message translates to:
  /// **'Auto sigue al teléfono.'**
  String get themeHint;

  /// No description provided for @bigText.
  ///
  /// In es, this message translates to:
  /// **'Letra grande'**
  String get bigText;

  /// No description provided for @bigHint.
  ///
  /// In es, this message translates to:
  /// **'Los textos se ven un 20% más grandes.'**
  String get bigHint;

  /// No description provided for @resetAll.
  ///
  /// In es, this message translates to:
  /// **'Borrar mis datos y empezar de nuevo'**
  String get resetAll;

  /// No description provided for @numBad.
  ///
  /// In es, this message translates to:
  /// **'Escribe un número.'**
  String get numBad;

  /// No description provided for @gt0.
  ///
  /// In es, this message translates to:
  /// **'Debe ser mayor que 0.'**
  String get gt0;

  /// No description provided for @pctBad.
  ///
  /// In es, this message translates to:
  /// **'Escribe un número del 0 al 100.'**
  String get pctBad;

  /// No description provided for @tgtBad.
  ///
  /// In es, this message translates to:
  /// **'«Cargar hasta» debe ser un número del 0 al 100.'**
  String get tgtBad;

  /// No description provided for @rsvBad.
  ///
  /// In es, this message translates to:
  /// **'Escribe un número del 0 al 90.'**
  String get rsvBad;

  /// No description provided for @weird.
  ///
  /// In es, this message translates to:
  /// **'¿Seguro? Es más de lo normal en una casa.'**
  String get weird;

  /// No description provided for @onlyNums.
  ///
  /// In es, this message translates to:
  /// **'Solo se pueden escribir números.'**
  String get onlyNums;

  /// No description provided for @sepDot.
  ///
  /// In es, this message translates to:
  /// **'punto'**
  String get sepDot;

  /// No description provided for @sepComma.
  ///
  /// In es, this message translates to:
  /// **'coma'**
  String get sepComma;

  /// No description provided for @kNight.
  ///
  /// In es, this message translates to:
  /// **'De noche · {w} W de consumo'**
  String kNight(String w);

  /// No description provided for @kNight0.
  ///
  /// In es, this message translates to:
  /// **'De noche'**
  String get kNight0;

  /// No description provided for @kCharge.
  ///
  /// In es, this message translates to:
  /// **'Cargando con la red · {w} W'**
  String kCharge(String w);

  /// No description provided for @kCharge0.
  ///
  /// In es, this message translates to:
  /// **'Cargando con la red'**
  String get kCharge0;

  /// No description provided for @leadUntil.
  ///
  /// In es, this message translates to:
  /// **'La batería dura hasta las'**
  String get leadUntil;

  /// No description provided for @leadUntil1.
  ///
  /// In es, this message translates to:
  /// **'La batería dura hasta la'**
  String get leadUntil1;

  /// No description provided for @leadFor.
  ///
  /// In es, this message translates to:
  /// **'La batería dura'**
  String get leadFor;

  /// No description provided for @almost.
  ///
  /// In es, this message translates to:
  /// **'menos de 1 min'**
  String get almost;

  /// No description provided for @okT.
  ///
  /// In es, this message translates to:
  /// **'Llegas al amanecer'**
  String get okT;

  /// No description provided for @okTxt.
  ///
  /// In es, this message translates to:
  /// **'Sobran unos {k}. A {t} marcará cerca de {p}%.'**
  String okTxt(String k, String t, String p);

  /// No description provided for @okJust.
  ///
  /// In es, this message translates to:
  /// **'La energía alcanza justo hasta {t}.'**
  String okJust(String t);

  /// No description provided for @badT.
  ///
  /// In es, this message translates to:
  /// **'No llegas al amanecer'**
  String get badT;

  /// No description provided for @badTxt.
  ///
  /// In es, this message translates to:
  /// **'Faltan unos {k}. Para llegar a {t}, baja el consumo a {w} W o menos.'**
  String badTxt(String k, String t, String w);

  /// No description provided for @badLow.
  ///
  /// In es, this message translates to:
  /// **'Faltan unos {k}. Casi no queda energía para usar.'**
  String badLow(String k);

  /// No description provided for @tryW.
  ///
  /// In es, this message translates to:
  /// **'Probar con {w} W'**
  String tryW(String w);

  /// No description provided for @lNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora'**
  String get lNow;

  /// No description provided for @lSun.
  ///
  /// In es, this message translates to:
  /// **'Sale el sol'**
  String get lSun;

  /// No description provided for @lEnd.
  ///
  /// In es, this message translates to:
  /// **'Se acaba'**
  String get lEnd;

  /// No description provided for @inDays.
  ///
  /// In es, this message translates to:
  /// **'en {d}'**
  String inDays(String d);

  /// No description provided for @fUsable.
  ///
  /// In es, this message translates to:
  /// **'que puedes usar'**
  String get fUsable;

  /// No description provided for @fDur.
  ///
  /// In es, this message translates to:
  /// **'de duración'**
  String get fDur;

  /// No description provided for @fPer.
  ///
  /// In es, this message translates to:
  /// **'útil por cada 1%'**
  String get fPer;

  /// No description provided for @emptyT.
  ///
  /// In es, this message translates to:
  /// **'Falta el consumo de la casa'**
  String get emptyT;

  /// No description provided for @emptyX.
  ///
  /// In es, this message translates to:
  /// **'Escríbelo abajo y aquí verás hasta qué hora te dura la batería.'**
  String get emptyX;

  /// No description provided for @fixT.
  ///
  /// In es, this message translates to:
  /// **'Falta corregir un dato'**
  String get fixT;

  /// No description provided for @fixPct.
  ///
  /// In es, this message translates to:
  /// **'El porciento debe ser un número del 0 al 100.'**
  String get fixPct;

  /// No description provided for @fixW.
  ///
  /// In es, this message translates to:
  /// **'El consumo debe ser un número.'**
  String get fixW;

  /// No description provided for @fixRsv.
  ///
  /// In es, this message translates to:
  /// **'Revisa la reserva: debe ser un número del 0 al 90.'**
  String get fixRsv;

  /// No description provided for @goField.
  ///
  /// In es, this message translates to:
  /// **'Ir al dato'**
  String get goField;

  /// No description provided for @inRsvT.
  ///
  /// In es, this message translates to:
  /// **'Ya está en la reserva'**
  String get inRsvT;

  /// No description provided for @inRsvX.
  ///
  /// In es, this message translates to:
  /// **'La batería ya está en la reserva del {r}%: no queda energía para usar.'**
  String inRsvX(String r);

  /// No description provided for @noLoadT.
  ///
  /// In es, this message translates to:
  /// **'Sin consumo'**
  String get noLoadT;

  /// No description provided for @noLoadX.
  ///
  /// In es, this message translates to:
  /// **'Sin consumo, la energía se mantiene: tienes {k} kWh guardados.'**
  String noLoadX(String k);

  /// No description provided for @cLead.
  ///
  /// In es, this message translates to:
  /// **'Tarda en cargar'**
  String get cLead;

  /// No description provided for @gridT.
  ///
  /// In es, this message translates to:
  /// **'Gasta de la red unos {k} kWh'**
  String gridT(String k);

  /// No description provided for @gridX.
  ///
  /// In es, this message translates to:
  /// **'Al cargar se pierde cerca del 10%. Es lo que se suma a la factura de la luz.'**
  String get gridX;

  /// No description provided for @fToCharge.
  ///
  /// In es, this message translates to:
  /// **'por cargar'**
  String get fToCharge;

  /// No description provided for @fPerHour.
  ///
  /// In es, this message translates to:
  /// **'sube cada hora'**
  String get fPerHour;

  /// No description provided for @lAt.
  ///
  /// In es, this message translates to:
  /// **'Llega al {p}%'**
  String lAt(String p);

  /// No description provided for @alreadyT.
  ///
  /// In es, this message translates to:
  /// **'No hace falta cargar'**
  String get alreadyT;

  /// No description provided for @alreadyX.
  ///
  /// In es, this message translates to:
  /// **'La batería ya está en {a}%, igual o más que el {b}% que quieres.'**
  String alreadyX(String a, String b);

  /// No description provided for @noPowT.
  ///
  /// In es, this message translates to:
  /// **'Falta la potencia de carga'**
  String get noPowT;

  /// No description provided for @noPowX.
  ///
  /// In es, this message translates to:
  /// **'Pon la potencia de carga: debe ser mayor que 0.'**
  String get noPowX;

  /// No description provided for @fixC.
  ///
  /// In es, this message translates to:
  /// **'Los porcientos deben ser de 0 a 100.'**
  String get fixC;

  /// No description provided for @lReserve.
  ///
  /// In es, this message translates to:
  /// **'{a}% − {r}% de reserva = {u}% útil'**
  String lReserve(String a, String r, String u);

  /// No description provided for @lBelow.
  ///
  /// In es, this message translates to:
  /// **'{a}% no pasa de la reserva del {r}%: queda 0% útil'**
  String lBelow(String a, String r);

  /// No description provided for @lRun.
  ///
  /// In es, this message translates to:
  /// **'{k} ÷ {w} de consumo = {d}'**
  String lRun(String k, String w, String d);

  /// No description provided for @lAmps.
  ///
  /// In es, this message translates to:
  /// **'{a} A × {v} V = {w} W de carga'**
  String lAmps(String a, String v, String w);

  /// No description provided for @lDelta.
  ///
  /// In es, this message translates to:
  /// **'{b}% − {a}% = {d}% por cargar'**
  String lDelta(String b, String a, String d);

  /// No description provided for @lKwh.
  ///
  /// In es, this message translates to:
  /// **'{c} × {d}% = {k}'**
  String lKwh(String c, String d, String k);

  /// No description provided for @lTime.
  ///
  /// In es, this message translates to:
  /// **'{k} ÷ {p} de carga = {t}'**
  String lTime(String k, String p, String t);

  /// No description provided for @lFast.
  ///
  /// In es, this message translates to:
  /// **'De {a}% a {b}%: {k} ÷ {p} = {t}'**
  String lFast(String a, String b, String k, String p, String t);

  /// No description provided for @lSlow.
  ///
  /// In es, this message translates to:
  /// **'De {a}% a {b}%, a mitad de potencia: {k} ÷ {p} = {t}'**
  String lSlow(String a, String b, String k, String p, String t);

  /// No description provided for @lTotal.
  ///
  /// In es, this message translates to:
  /// **'Total: {a} + {b} = {c}'**
  String lTotal(String a, String b, String c);

  /// No description provided for @shareT.
  ///
  /// In es, this message translates to:
  /// **'Compartir el reporte'**
  String get shareT;

  /// No description provided for @shareDesc.
  ///
  /// In es, this message translates to:
  /// **'Una imagen con la respuesta, los datos y el paso a paso. Se lee bien en el chat.'**
  String get shareDesc;

  /// No description provided for @shareImg.
  ///
  /// In es, this message translates to:
  /// **'Compartir imagen'**
  String get shareImg;

  /// No description provided for @saveImg.
  ///
  /// In es, this message translates to:
  /// **'Guardar en el teléfono'**
  String get saveImg;

  /// No description provided for @shareHint.
  ///
  /// In es, this message translates to:
  /// **'«Compartir» abre la lista del teléfono: elige WhatsApp, Telegram u otra app.'**
  String get shareHint;

  /// No description provided for @saved.
  ///
  /// In es, this message translates to:
  /// **'Imagen guardada: {n}'**
  String saved(String n);

  /// No description provided for @fixFirst.
  ///
  /// In es, this message translates to:
  /// **'Corrige los datos para compartir el resultado.'**
  String get fixFirst;

  /// No description provided for @rTitleN.
  ///
  /// In es, this message translates to:
  /// **'Reporte de batería'**
  String get rTitleN;

  /// No description provided for @rSubN.
  ///
  /// In es, this message translates to:
  /// **'De noche'**
  String get rSubN;

  /// No description provided for @rSubC.
  ///
  /// In es, this message translates to:
  /// **'Cargando con la red'**
  String get rSubC;

  /// No description provided for @dataUsed.
  ///
  /// In es, this message translates to:
  /// **'Datos usados'**
  String get dataUsed;

  /// No description provided for @howR.
  ///
  /// In es, this message translates to:
  /// **'Así se calcula'**
  String get howR;

  /// No description provided for @dBat.
  ///
  /// In es, this message translates to:
  /// **'Batería'**
  String get dBat;

  /// No description provided for @dLevel.
  ///
  /// In es, this message translates to:
  /// **'Porciento ahora'**
  String get dLevel;

  /// No description provided for @dLoad.
  ///
  /// In es, this message translates to:
  /// **'Consumo'**
  String get dLoad;

  /// No description provided for @dAt.
  ///
  /// In es, this message translates to:
  /// **'Hora del cálculo'**
  String get dAt;

  /// No description provided for @dSun.
  ///
  /// In es, this message translates to:
  /// **'Vuelve el sol'**
  String get dSun;

  /// No description provided for @dRsv.
  ///
  /// In es, this message translates to:
  /// **'Reserva de la batería'**
  String get dRsv;

  /// No description provided for @dLoss.
  ///
  /// In es, this message translates to:
  /// **'Pérdidas del inversor'**
  String get dLoss;

  /// No description provided for @lossYes.
  ///
  /// In es, this message translates to:
  /// **'Incluidas (10%)'**
  String get lossYes;

  /// No description provided for @lossNo.
  ///
  /// In es, this message translates to:
  /// **'No incluidas'**
  String get lossNo;

  /// No description provided for @dTgt.
  ///
  /// In es, this message translates to:
  /// **'Cargar hasta'**
  String get dTgt;

  /// No description provided for @dPow.
  ///
  /// In es, this message translates to:
  /// **'Potencia de carga'**
  String get dPow;

  /// No description provided for @footN.
  ///
  /// In es, this message translates to:
  /// **'Es un aproximado: el consumo cambia durante la noche. La batería se apaga al {r}% para cuidar su salud.'**
  String footN(String r);

  /// No description provided for @footC.
  ///
  /// In es, this message translates to:
  /// **'Es un aproximado: del 90% al 100% el cargador va más despacio, por eso ese tramo se calcula a la mitad de la potencia.'**
  String get footC;

  /// No description provided for @fileN.
  ///
  /// In es, this message translates to:
  /// **'reporte-noche'**
  String get fileN;

  /// No description provided for @fileC.
  ///
  /// In es, this message translates to:
  /// **'reporte-carga'**
  String get fileC;

  /// No description provided for @stripErr.
  ///
  /// In es, this message translates to:
  /// **'Falta corregir un dato'**
  String get stripErr;

  /// No description provided for @stripEmpty.
  ///
  /// In es, this message translates to:
  /// **'Falta el consumo'**
  String get stripEmpty;

  /// No description provided for @hasta.
  ///
  /// In es, this message translates to:
  /// **'Hasta '**
  String get hasta;

  /// No description provided for @tagOk.
  ///
  /// In es, this message translates to:
  /// **'Llegas'**
  String get tagOk;

  /// No description provided for @tagBad.
  ///
  /// In es, this message translates to:
  /// **'No llegas'**
  String get tagBad;

  /// No description provided for @tagFix.
  ///
  /// In es, this message translates to:
  /// **'Revisa'**
  String get tagFix;

  /// No description provided for @enPhrase.
  ///
  /// In es, this message translates to:
  /// **'En '**
  String get enPhrase;

  /// No description provided for @version.
  ///
  /// In es, this message translates to:
  /// **'Versión {v} · Funciona sin internet'**
  String version(String v);

  /// No description provided for @days.
  ///
  /// In es, this message translates to:
  /// **'{d, select, 1{cerca de 1 día} other{unos {d} días}}'**
  String days(String d);

  /// No description provided for @moreS.
  ///
  /// In es, this message translates to:
  /// **'Pérdidas del inversor: {on, select, true{sí} other{no}} · Reserva: {r}%'**
  String moreS(String on, String r);

  /// No description provided for @readAs.
  ///
  /// In es, this message translates to:
  /// **'Se entendió: {v}.'**
  String readAs(String v);

  /// No description provided for @readAsAlt.
  ///
  /// In es, this message translates to:
  /// **'Se entendió: {v}. Si querías {alt}, escríbelo sin {sep}.'**
  String readAsAlt(String v, String alt, String sep);

  /// No description provided for @lCap.
  ///
  /// In es, this message translates to:
  /// **'{c} × {u}% = {x}'**
  String lCap(String c, String u, String x);

  /// No description provided for @lCapLoss.
  ///
  /// In es, this message translates to:
  /// **'{c} × {u}% = {x}; quitando el 10% de pérdidas quedan {y}'**
  String lCapLoss(String c, String u, String x, String y);

  /// No description provided for @cSub.
  ///
  /// In es, this message translates to:
  /// **'Llega al {p}% cerca de {t}'**
  String cSub(String p, String t);

  /// No description provided for @batLblPrefix.
  ///
  /// In es, this message translates to:
  /// **'Tu batería: '**
  String get batLblPrefix;

  /// No description provided for @ahResultPrefix.
  ///
  /// In es, this message translates to:
  /// **'Tu batería es de unos '**
  String get ahResultPrefix;

  /// No description provided for @trying.
  ///
  /// In es, this message translates to:
  /// **'Probando con {w} W'**
  String trying(String w);

  /// No description provided for @appShort.
  ///
  /// In es, this message translates to:
  /// **'Batería'**
  String get appShort;

  /// No description provided for @confirmReset.
  ///
  /// In es, this message translates to:
  /// **'Toca otra vez para borrar todo'**
  String get confirmReset;

  /// No description provided for @example.
  ///
  /// In es, this message translates to:
  /// **'Ej.: {x}'**
  String example(String x);

  /// No description provided for @stripTakes.
  ///
  /// In es, this message translates to:
  /// **'Tarda '**
  String get stripTakes;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
