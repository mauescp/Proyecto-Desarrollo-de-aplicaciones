import 'package:flutter/material.dart';
import 'app_localizations.dart';

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
  
  String tr(String key) => loc.translate(key);
}