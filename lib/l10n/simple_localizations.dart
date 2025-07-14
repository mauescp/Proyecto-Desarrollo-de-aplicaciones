import 'package:flutter/material.dart';

class SimpleLocalizations {
  final Locale locale;
  
  SimpleLocalizations(this.locale);
  
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_title': 'RIM LOGISTIC - Shipment Management',
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      // Añade todas las traducciones en inglés aquí
    },
    'es': {
      'app_title': 'RIM LOGISTIC - Gestión de Embarques',
      'login': 'Ingresar',
      'username': 'Usuario',
      'password': 'Contraseña',
      // Añade todas las traducciones en español aquí
    },
  };
  
  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
  
  static SimpleLocalizations of(BuildContext context) {
    return Localizations.of<SimpleLocalizations>(context, SimpleLocalizations)!;
  }
}

class SimpleLocalizationsDelegate extends LocalizationsDelegate<SimpleLocalizations> {
  const SimpleLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<SimpleLocalizations> load(Locale locale) {
    return Future.value(SimpleLocalizations(locale));
  }

  @override
  bool shouldReload(SimpleLocalizationsDelegate old) => false;
}