import 'package:get/get.dart';
import 'package:clune/translations/es_es.dart';
import 'package:clune/translations/en_us.dart';

/// Configuración de traducciones GetX (español e inglés stub).
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'es_ES': esES,
        'en_US': enUS,
      };
}
