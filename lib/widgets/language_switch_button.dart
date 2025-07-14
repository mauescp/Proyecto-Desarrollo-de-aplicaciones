import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class LanguageSwitchButton extends StatelessWidget {
  final Color? iconColor;
  
  const LanguageSwitchButton({Key? key, this.iconColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish();
    
    return IconButton(
      icon: Icon(
        Icons.language,
        color: iconColor ?? Colors.white,
      ),
      tooltip: isEnglish ? 'Cambiar a Español' : 'Switch to English',
      onPressed: () {
        // Cambiar al otro idioma
        final newLanguage = isEnglish ? 'es' : 'en';
        languageProvider.changeLanguage(newLanguage);
        
        // Mostrar un mensaje de confirmación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEnglish ? 'Idioma cambiado a Español' : 'Language changed to English',
            ),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}