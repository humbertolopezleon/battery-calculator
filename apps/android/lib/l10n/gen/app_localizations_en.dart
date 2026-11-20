// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Battery Calculator';

  @override
  String get offline => 'Works without internet';

  @override
  String get intro => 'See how long your battery lasts at night and how long it takes to charge from the grid.';

  @override
  String get sizeQ => 'How big is your battery?';

  @override
  String get batHow => 'How you know the size';

  @override
  String get modeKwh => 'In kWh';

  @override
  String get modeAh => 'In volts and Ah';

  @override
  String get common => 'Common batteries';

  @override
  String get otherCap => 'Or another capacity';

  @override
  String get capacity => 'Capacity';

  @override
  String get capHint => 'It’s on the battery label or in its manual.';

  @override
  String get volts => 'Volts';

  @override
  String get ah => 'Amp-hours';

  @override
  String get ahHint => 'They’re on the label; for example, 51.2 V and 200 Ah.';

  @override
  String get startHint => 'Pick or type the size to start. It’s saved on your phone and you can change it later.';

  @override
  String get start => 'Start';

  @override
  String get yourBat => 'Your battery';

  @override
  String get settings => 'Settings';

  @override
  String get close => 'Close';

  @override
  String get ok => 'Done';

  @override
  String get tabsAria => 'What to calculate';

  @override
  String get tabNight => 'At night';

  @override
  String get tabCharge => 'Charging from grid';

  @override
  String get nightData => 'Night data';

  @override
  String get pctNow => 'Battery level right now';

  @override
  String get load => 'Home power use';

  @override
  String get phLoad => 'E.g. 600';

  @override
  String get loadHint => 'Check the inverter or its app. If it goes up and down, use an average.';

  @override
  String get timeNow => 'Time now';

  @override
  String get nowBtn => 'Now';

  @override
  String get sunrise => 'Sunrise time';

  @override
  String get sunHint => 'When the panels start charging.';

  @override
  String get more => 'More options';

  @override
  String get loss => 'Count inverter losses (10%)';

  @override
  String get lossHint => 'More realistic. Turn off for the simple math.';

  @override
  String get rsvLabel => 'Battery reserve';

  @override
  String get rsvHint =>
      'The battery shuts off on its own at this level. Change it only if your inverter uses another one. From 0 to 90%.';

  @override
  String get rsvReset => 'Back to 6%';

  @override
  String get minus => 'Down 1%';

  @override
  String get plus => 'Up 1%';

  @override
  String get how => 'How it’s calculated';

  @override
  String get howSub => 'Step by step';

  @override
  String legRsv(String r) {
    return '$r% reserve (not used)';
  }

  @override
  String legUse(String u) {
    return 'You can use $u%';
  }

  @override
  String get nNote =>
      'This is an estimate. Power use changes during the night (the fridge starts and stops; AC or an iron raise it a lot). It assumes the panels don’t charge until sunrise.';

  @override
  String get share => 'Share result';

  @override
  String get chargeData => 'Charging data';

  @override
  String get batLevel => 'Battery level';

  @override
  String get nowShort => 'Now';

  @override
  String get tgt => 'Charge to';

  @override
  String get legNow => 'Charge now';

  @override
  String get legToCharge => 'To be charged';

  @override
  String get power => 'Charging power';

  @override
  String get powHow => 'How you know the charging power';

  @override
  String get modeW => 'I know the watts';

  @override
  String get modeA => 'I know the amps';

  @override
  String get powW => 'Charging power in watts';

  @override
  String get phPow => 'E.g. 2500';

  @override
  String get amps => 'Amps';

  @override
  String get powHintW => 'The grid charging power set in your inverter.';

  @override
  String get powHintA => 'The grid charging current set in your inverter; for example, 50 A on a 51.2 V battery.';

  @override
  String aResult(String x) {
    return 'That’s about $x W of charging.';
  }

  @override
  String get cNote =>
      'This is an estimate. From 90% to 100% the charger slows down, so that part is calculated at half power. If the grid goes out, charging stops.';

  @override
  String get langHint => 'The first time, the phone’s language is used.';

  @override
  String get themeL => 'Screen colors';

  @override
  String get thAuto => 'Auto';

  @override
  String get thLight => 'Light';

  @override
  String get thDark => 'Dark';

  @override
  String get themeHint => 'Auto follows your phone.';

  @override
  String get bigText => 'Large text';

  @override
  String get bigHint => 'Text looks 20% bigger.';

  @override
  String get resetAll => 'Erase my data and start over';

  @override
  String get numBad => 'Enter a number.';

  @override
  String get gt0 => 'It must be greater than 0.';

  @override
  String get pctBad => 'Enter a number from 0 to 100.';

  @override
  String get tgtBad => '“Charge to” must be a number from 0 to 100.';

  @override
  String get rsvBad => 'Enter a number from 0 to 90.';

  @override
  String get weird => 'Are you sure? That’s more than usual for a home.';

  @override
  String get onlyNums => 'Only numbers can be typed.';

  @override
  String get sepDot => 'period';

  @override
  String get sepComma => 'comma';

  @override
  String kNight(String w) {
    return 'At night · $w W in use';
  }

  @override
  String get kNight0 => 'At night';

  @override
  String kCharge(String w) {
    return 'Charging from the grid · $w W';
  }

  @override
  String get kCharge0 => 'Charging from the grid';

  @override
  String get leadUntil => 'Your battery lasts until';

  @override
  String get leadUntil1 => 'Your battery lasts until';

  @override
  String get leadFor => 'Your battery lasts';

  @override
  String get almost => 'under 1 min';

  @override
  String get okT => 'You’ll make it to sunrise';

  @override
  String okTxt(String k, String t, String p) {
    return 'About $k to spare. At $t it will show about $p%.';
  }

  @override
  String okJust(String t) {
    return 'The energy lasts just until $t.';
  }

  @override
  String get badT => 'You won’t make it to sunrise';

  @override
  String badTxt(String k, String t, String w) {
    return 'About $k short. To last until $t, lower your use to $w W or less.';
  }

  @override
  String badLow(String k) {
    return 'About $k short. There’s almost no energy left to use.';
  }

  @override
  String tryW(String w) {
    return 'Try $w W';
  }

  @override
  String get lNow => 'Now';

  @override
  String get lSun => 'Sunrise';

  @override
  String get lEnd => 'Runs out';

  @override
  String inDays(String d) {
    return 'in $d';
  }

  @override
  String get fUsable => 'you can use';

  @override
  String get fDur => 'runtime';

  @override
  String get fPer => 'usable per 1%';

  @override
  String get emptyT => 'Home power use is missing';

  @override
  String get emptyX => 'Type it below and you’ll see here how long your battery lasts.';

  @override
  String get fixT => 'Something needs fixing';

  @override
  String get fixPct => 'The level must be a number from 0 to 100.';

  @override
  String get fixW => 'Power use must be a number.';

  @override
  String get fixRsv => 'Check the reserve: it must be a number from 0 to 90.';

  @override
  String get goField => 'Go to it';

  @override
  String get inRsvT => 'Already at the reserve';

  @override
  String inRsvX(String r) {
    return 'The battery is already at its $r% reserve: no energy left to use.';
  }

  @override
  String get noLoadT => 'No power use';

  @override
  String noLoadX(String k) {
    return 'With no power use, energy stays: you have $k kWh stored.';
  }

  @override
  String get cLead => 'Time to charge';

  @override
  String gridT(String k) {
    return 'Uses about $k kWh from the grid';
  }

  @override
  String get gridX => 'About 10% is lost while charging. This is what adds to your power bill.';

  @override
  String get fToCharge => 'to charge';

  @override
  String get fPerHour => 'added per hour';

  @override
  String lAt(String p) {
    return 'At $p%';
  }

  @override
  String get alreadyT => 'No need to charge';

  @override
  String alreadyX(String a, String b) {
    return 'The battery is already at $a%, equal to or above the $b% you want.';
  }

  @override
  String get noPowT => 'Charging power is missing';

  @override
  String get noPowX => 'Enter the charging power: it must be greater than 0.';

  @override
  String get fixC => 'Levels must be from 0 to 100.';

  @override
  String lReserve(String a, String r, String u) {
    return '$a% − $r% reserve = $u% usable';
  }

  @override
  String lBelow(String a, String r) {
    return '$a% is not above the $r% reserve: 0% usable is left';
  }

  @override
  String lRun(String k, String w, String d) {
    return '$k ÷ $w in use = $d';
  }

  @override
  String lAmps(String a, String v, String w) {
    return '$a A × $v V = $w W of charging';
  }

  @override
  String lDelta(String b, String a, String d) {
    return '$b% − $a% = $d% to charge';
  }

  @override
  String lKwh(String c, String d, String k) {
    return '$c × $d% = $k';
  }

  @override
  String lTime(String k, String p, String t) {
    return '$k ÷ $p of charging = $t';
  }

  @override
  String lFast(String a, String b, String k, String p, String t) {
    return 'From $a% to $b%: $k ÷ $p = $t';
  }

  @override
  String lSlow(String a, String b, String k, String p, String t) {
    return 'From $a% to $b%, at half power: $k ÷ $p = $t';
  }

  @override
  String lTotal(String a, String b, String c) {
    return 'Total: $a + $b = $c';
  }

  @override
  String get shareT => 'Share the report';

  @override
  String get shareDesc => 'An image with the answer, the data and the steps. Easy to read in a chat.';

  @override
  String get shareImg => 'Share image';

  @override
  String get saveImg => 'Save to phone';

  @override
  String get shareHint => '“Share” opens your phone’s list: pick WhatsApp, Telegram or another app.';

  @override
  String saved(String n) {
    return 'Image saved: $n';
  }

  @override
  String get fixFirst => 'Fix the data to share the result.';

  @override
  String get rTitleN => 'Battery report';

  @override
  String get rSubN => 'At night';

  @override
  String get rSubC => 'Charging from the grid';

  @override
  String get dataUsed => 'Data used';

  @override
  String get howR => 'How it’s calculated';

  @override
  String get dBat => 'Battery';

  @override
  String get dLevel => 'Level now';

  @override
  String get dLoad => 'Power use';

  @override
  String get dAt => 'Time of calculation';

  @override
  String get dSun => 'Sunrise';

  @override
  String get dRsv => 'Battery reserve';

  @override
  String get dLoss => 'Inverter losses';

  @override
  String get lossYes => 'Included (10%)';

  @override
  String get lossNo => 'Not included';

  @override
  String get dTgt => 'Charge to';

  @override
  String get dPow => 'Charging power';

  @override
  String footN(String r) {
    return 'This is an estimate: power use changes during the night. The battery shuts off at $r% to protect its health.';
  }

  @override
  String get footC =>
      'This is an estimate: from 90% to 100% the charger slows down, so that part is calculated at half power.';

  @override
  String get fileN => 'night-report';

  @override
  String get fileC => 'charging-report';

  @override
  String get stripErr => 'Something needs fixing';

  @override
  String get stripEmpty => 'Power use is missing';

  @override
  String get hasta => 'Until ';

  @override
  String get tagOk => 'You make it';

  @override
  String get tagBad => 'Short';

  @override
  String get tagFix => 'Check';

  @override
  String get enPhrase => 'In ';

  @override
  String version(String v) {
    return 'Version $v · Works without internet';
  }

  @override
  String days(String d) {
    String _temp0 = intl.Intl.selectLogic(d, {'1': 'about 1 day', 'other': 'about $d days'});
    return '$_temp0';
  }

  @override
  String moreS(String on, String r) {
    String _temp0 = intl.Intl.selectLogic(on, {'true': 'on', 'other': 'off'});
    return 'Inverter losses: $_temp0 · Reserve: $r%';
  }

  @override
  String readAs(String v) {
    return 'Read as: $v.';
  }

  @override
  String readAsAlt(String v, String alt, String sep) {
    return 'Read as: $v. If you meant $alt, type it without the $sep.';
  }

  @override
  String lCap(String c, String u, String x) {
    return '$c × $u% = $x';
  }

  @override
  String lCapLoss(String c, String u, String x, String y) {
    return '$c × $u% = $x; minus 10% losses leaves $y';
  }

  @override
  String cSub(String p, String t) {
    return 'Reaches $p% around $t';
  }

  @override
  String get batLblPrefix => 'Your battery: ';

  @override
  String get ahResultPrefix => 'Your battery is about ';

  @override
  String trying(String w) {
    return 'Trying $w W';
  }

  @override
  String get appShort => 'Battery';

  @override
  String get confirmReset => 'Tap again to erase everything';

  @override
  String example(String x) {
    return 'E.g. $x';
  }

  @override
  String get stripTakes => 'Takes ';

  @override
  String get saveFailed => 'The image couldn’t be saved.';

  @override
  String get saveNoPerm => 'To save, allow access to photos and files in your phone’s settings.';

  @override
  String timeToast(String t) {
    return 'Time: $t';
  }
}
