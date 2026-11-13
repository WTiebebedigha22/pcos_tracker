// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Lunora';

  @override
  String get medicalDisclaimer =>
      'Lunora is not a medical device and does not provide medical advice.';

  @override
  String get settings => 'Settings';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String get exportData => 'Export my data';
}
