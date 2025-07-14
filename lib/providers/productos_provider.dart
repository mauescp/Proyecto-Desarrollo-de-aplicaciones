import 'package:flutter/foundation.dart';
import '../models/producto.dart';
import '../database_helper.dart';

class ProductosProvider with ChangeNotifier {
  List<Producto> _productos = [];

  List<Producto> get productos => [..._productos];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Cargar productos desde la base de datos
  Future<void> cargarProductos() async {
    _isLoading = true;
    notifyListeners();

    try {
      final productosData = await DatabaseHelper.instance.getAllProductos();
      _productos = productosData.map((item) => Producto.fromMap(item)).toList();
    } catch (e) {
      print('Error al cargar productos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un nuevo producto
  Future<void> agregarProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      final productoMap = producto.toMap();
      final id = await DatabaseHelper.instance.insertProducto(productoMap);
      
      final nuevoProducto = Producto(
        id: id,
        nombre: producto.nombre,
        cantidad: producto.cantidad,
        ubicacion: producto.ubicacion,
        fecha: producto.fecha,
      );
      
      _productos.add(nuevoProducto);
    } catch (e) {
      print('Error al agregar producto: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar un producto existente
  Future<void> actualizarProducto(Producto producto) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseHelper.instance.updateProducto(producto.toMap());
      
      final index = _productos.indexWhere((p) => p.id == producto.id);
      if (index != -1) {
        _productos[index] = producto;
      }
    } catch (e) {
      print('Error al actualizar producto: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Eliminar un producto
  Future<void> eliminarProducto(int id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await DatabaseHelper.instance.deleteProducto(id);
      _productos.removeWhere((producto) => producto.id == id);
    } catch (e) {
      print('Error al eliminar producto: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtener un producto por su índice en la lista
  Producto getProductoByIndex(int index) {
    return _productos[index];
  }

  // Obtener un producto por su ID
  Producto? getProductoById(int id) {
    try {
      return _productos.firstWhere((producto) => producto.id == id);
    } catch (e) {
      return null;
    }
  }
}