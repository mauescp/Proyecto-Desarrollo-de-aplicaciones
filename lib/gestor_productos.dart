import 'database_helper.dart';

class GestorProductos {
  static final GestorProductos instance = GestorProductos._internal();
  List<Map<String, dynamic>> productos = [];

  GestorProductos._internal();

  // Cargar productos desde la base de datos
  Future<void> cargarProductos() async {
    productos = List<Map<String, dynamic>>.from(await DatabaseHelper.instance.getAllProductos());
  }

  // Agregar un nuevo producto
  Future<void> agregarProducto(String nombre, int cantidad, String ubicacion, String fecha) async {
    final producto = {
      'nombre': nombre,
      'cantidad': cantidad,
      'ubicacion': ubicacion,
      'fecha': fecha,
    };
    
    final id = await DatabaseHelper.instance.insertProducto(producto);
    
    // Crear una copia del producto con el ID y agregarlo a la lista
    final productoConId = Map<String, dynamic>.from(producto);
    productoConId['id'] = id;
    
    // Asegurarse de que la lista sea mutable
    if (productos is List<Map<String, dynamic>>) {
      productos.add(productoConId);
    } else {
      productos = List<Map<String, dynamic>>.from(productos);
      productos.add(productoConId);
    }
  }

  // Actualizar un producto existente
  Future<void> actualizarProducto(Map<String, dynamic> producto) async {
    await DatabaseHelper.instance.updateProducto(producto);
    
    final index = productos.indexWhere((p) => p['id'] == producto['id']);
    if (index != -1) {
      // Asegurarse de que la lista sea mutable
      if (productos is List<Map<String, dynamic>>) {
        productos[index] = producto;
      } else {
        productos = List<Map<String, dynamic>>.from(productos);
        productos[index] = producto;
  }
}
  }

  // Eliminar un producto
  Future<void> eliminarProducto(int index) async {
    final id = productos[index]['id'];
    await DatabaseHelper.instance.deleteProducto(id);
    
    // Asegurarse de que la lista sea mutable
    if (productos is List<Map<String, dynamic>>) {
      productos.removeAt(index);
    } else {
      productos = List<Map<String, dynamic>>.from(productos);
      productos.removeAt(index);
    }
  }
}