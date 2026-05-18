import 'package:ultimate_wheel/config/translations.dart';

extension StringL10n on String {
  String get tr {
    if (AppLanguage.currentLanguage == 'en') {
      return appTranslations['en']?[this] ?? this;
    }
    return this;
  }
}
