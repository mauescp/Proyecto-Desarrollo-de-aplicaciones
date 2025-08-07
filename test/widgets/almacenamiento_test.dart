import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:appgestion/almacenamiento.dart';
import 'package:appgestion/providers/productos_provider.dart';
import 'package:appgestion/models/producto.dart';

class MockProductosProvider extends ChangeNotifier implements ProductosProvider {
  List<Producto> _productos = [];
  bool _isLoading = false;

  @override
  List<Producto> get productos => _productos;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<void> cargarProductos() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> agregarProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    final nuevoProducto = Producto(
      id: _productos.length + 1,
      nombre: producto.nombre,
      cantidad: producto.cantidad,
      ubicacion: producto.ubicacion,
      fecha: producto.fecha,
    );
    _productos.add(nuevoProducto);
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> eliminarProducto(int id) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    _productos.removeWhere((producto) => producto.id == id);
    _isLoading = false;
    notifyListeners();
  }

  @override
  Future<void> actualizarProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(Duration(milliseconds: 100));
    final index = _productos.indexWhere((p) => p.id == producto.id);
    if (index != -1) {
      _productos[index] = producto;
    }
    _isLoading = false;
    notifyListeners();
  }

  @override
  Producto getProductoByIndex(int index) {
    if (index < 0 || index >= _productos.length) {
      throw RangeError('Índice fuera de rango');
    }
    return _productos[index];
  }

  @override
  Producto? getProductoById(int id) {
    try {
      return _productos.firstWhere((producto) => producto.id == id);
    } catch (e) {
      return null;
    }
  }
}

void main() {
  group('AlmacenamientoScreen Widget Tests', () {
    late MockProductosProvider productosProvider;

    setUp(() {
      productosProvider = MockProductosProvider();
    });
    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: ChangeNotifierProvider<ProductosProvider>.value(
          value: productosProvider,
          child: AlmacenamientoScreen(),
        ),
      );
    }

    testWidgets('Debe mostrar título y campos de entrada', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Gestión de Almacenamiento'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Nombre del producto'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Cantidad disponible'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Ubicación en el almacén'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Agregar Producto'), findsOneWidget);
    });

    testWidgets('Debe mostrar mensaje cuando no hay productos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('No hay productos registrados'), findsOneWidget);
    });

    testWidgets('Debe mostrar error al intentar agregar producto sin datos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Agregar Producto'));
      await tester.pumpAndSettle();

      expect(find.text('Por favor, completa los campos requeridos'), findsOneWidget);
    });

    testWidgets('Debe permitir ingresar datos en los campos', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del producto'), 'Producto Test');
      await tester.enterText(find.widgetWithText(TextField, 'Cantidad disponible'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'Ubicación en el almacén'), 'A1');
      await tester.pump();

      final nombreField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Nombre del producto')
      );
      final cantidadField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Cantidad disponible')
      );
      final ubicacionField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Ubicación en el almacén')
      );

      expect(nombreField.controller?.text, 'Producto Test');
      expect(cantidadField.controller?.text, '10');
      expect(ubicacionField.controller?.text, 'A1');
    });

    testWidgets('Debe mostrar error al ingresar cantidad no numérica', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del producto'), 'Producto Test');
      await tester.enterText(find.widgetWithText(TextField, 'Cantidad disponible'), 'abc');
      await tester.tap(find.text('Agregar Producto'));
      await tester.pumpAndSettle();

      expect(find.text('La cantidad debe ser un número válido'), findsOneWidget);
    });

    testWidgets('Debe mostrar botón de refresh en AppBar', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('Debe mostrar campos con decoración correcta', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.production_quantity_limits), findsOneWidget);
      expect(find.byIcon(Icons.confirmation_number), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('Debe tener un diseño responsive', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Expanded), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('Debe limpiar campos después de agregar producto', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del producto'), 'Producto Test');
      await tester.enterText(find.widgetWithText(TextField, 'Cantidad disponible'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'Ubicación en el almacén'), 'A1');
      
      await tester.tap(find.text('Agregar Producto'));
      await tester.pumpAndSettle();

      final nombreField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Nombre del producto')
      );
      final cantidadField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Cantidad disponible')
      );
      final ubicacionField = tester.widget<TextField>(
        find.widgetWithText(TextField, 'Ubicación en el almacén')
      );

      expect(nombreField.controller?.text, '');
      expect(cantidadField.controller?.text, '');
      expect(ubicacionField.controller?.text, '');
      expect(find.text('Producto agregado con éxito'), findsOneWidget);
    });

    testWidgets('Debe mostrar producto agregado en la lista', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del producto'), 'Producto Test');
      await tester.enterText(find.widgetWithText(TextField, 'Cantidad disponible'), '10');
      await tester.enterText(find.widgetWithText(TextField, 'Ubicación en el almacén'), 'A1');
      
      await tester.tap(find.text('Agregar Producto'));
      await tester.pumpAndSettle();

      expect(find.text('Producto Test'), findsOneWidget);
      expect(find.textContaining('Cantidad: 10'), findsOneWidget);
      expect(find.textContaining('Ubicación: A1'), findsOneWidget);
      
      // Verificar que el producto se agregó al provider
      expect(productosProvider.productos.length, 1);
      expect(productosProvider.productos.first.nombre, 'Producto Test');
      expect(productosProvider.productos.first.cantidad, 10);
      expect(productosProvider.productos.first.ubicacion, 'A1');
    });

    testWidgets('Debe mostrar fecha actual en producto nuevo', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      final fechaActual = DateFormat('dd/MM/yyyy').format(DateTime.now());

      await tester.enterText(find.widgetWithText(TextField, 'Nombre del producto'), 'Producto Test');
      await tester.enterText(find.widgetWithText(TextField, 'Cantidad disponible'), '10');
      await tester.tap(find.text('Agregar Producto'));
      await tester.pumpAndSettle();

      expect(find.textContaining(fechaActual), findsOneWidget);
    });
  });
}
