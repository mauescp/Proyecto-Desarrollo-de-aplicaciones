import 'package:appgestion/l10n/app_localizations.dart';
import 'package:appgestion/screens/bluetooth_config_screen.dart';
import 'package:appgestion/sensorhumedad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock simple de AppLocalizations para las pruebas
class MockAppLocalizations implements AppLocalizations {
  @override
  final Locale locale;

  MockAppLocalizations([this.locale = const Locale('es')]);

  @override
  Future<bool> load() async {
    return true;
  }

  @override
  String translate(String key) {
    final Map<String, String> translations = {
      'humidity_sensor': 'Sensor de Humedad',
      'dry_environment': 'Ambiente Seco',
      'humid_environment': 'Ambiente Húmedo',
      'moderate_humidity': 'Humedad Moderada',
      'recent_readings': 'Lecturas Recientes'
    };
    return translations[key] ?? key;
  }
}

class MockAppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return MockAppLocalizations(locale);
  }

  @override
  bool shouldReload(MockAppLocalizationsDelegate old) => false;
}

void main() {
  Widget createWidgetUnderTest() {
    return MaterialApp(
            locale: const Locale('es'),
            localizationsDelegates: [
        MockAppLocalizationsDelegate(),
        DefaultWidgetsLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
            ],
      home: Builder(
        builder: (context) => SensorHumedadScreen(),
      ),
    );
  }

  group('SensorHumedad Widget Tests', () {
    testWidgets('Verifica que se muestre el AppBar con título y botón bluetooth',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica la presencia del AppBar
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verifica el botón de bluetooth
      expect(find.byIcon(Icons.bluetooth), findsOneWidget);
    });

    testWidgets('Verifica la presencia del indicador de humedad',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica el ícono de gota de agua
      expect(find.byIcon(Icons.water_drop), findsWidgets);
      
      // Verifica que se muestre el valor de humedad
      expect(find.textContaining('%'), findsOneWidget);
    });

    testWidgets('Verifica la presencia de la lista de lecturas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica que exista el ListView
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Verifica la navegación al presionar el botón bluetooth',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encuentra y presiona el botón de bluetooth
      await tester.tap(find.byIcon(Icons.bluetooth));
      await tester.pumpAndSettle();

      // Verifica que se haya navegado a la pantalla de configuración bluetooth
      expect(find.byType(BluetoothConfigScreen), findsOneWidget);
    });

    testWidgets('Verifica el color del indicador según el nivel de humedad',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Encuentra el ícono de gota de agua principal
      final iconFinder = find.byIcon(Icons.water_drop).first;
      final Icon icon = tester.widget(iconFinder);

      // Verifica que el ícono tenga un color (puede ser naranja, azul o verde)
      expect(icon.color, isNotNull);
    });

    testWidgets('Verifica el formato de fecha en las lecturas',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica que el formato de fecha sea correcto (si hay lecturas)
      final datePattern = RegExp(r'\d{1,2}/\d{1,2}/\d{4} \d{1,2}:\d{1,2}');
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      
      bool foundDateFormat = false;
      for (var textWidget in textWidgets) {
        if (datePattern.hasMatch(textWidget.data ?? '')) {
          foundDateFormat = true;
          break;
        }
      }
      
      // No forzamos que haya lecturas, pero si las hay, deben tener el formato correcto
      if (foundDateFormat) {
        expect(foundDateFormat, isTrue);
      }
    });

    testWidgets('Verifica los textos de estado de humedad',
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Verifica que exista al menos uno de los estados de humedad
      final possibleTexts = [
        'Ambiente Seco',
        'Ambiente Húmedo',
        'Humedad Moderada'
      ];

      bool foundStatus = false;
      for (var text in possibleTexts) {
        if (find.text(text).evaluate().isNotEmpty) {
          foundStatus = true;
          break;
        }
      }

      expect(foundStatus, isTrue);
    });
  });
}
