import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'providers/productos_provider.dart';
import 'models/producto.dart';
class AlmacenamientoScreen extends StatefulWidget {
  @override
  _AlmacenamientoScreenState createState() => _AlmacenamientoScreenState();
}

class _AlmacenamientoScreenState extends State<AlmacenamientoScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  String _fechaIngreso = DateFormat('dd/MM/yyyy').format(DateTime.now());
  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar la pantalla
    Future.microtask(() => 
      Provider.of<ProductosProvider>(context, listen: false).cargarProductos()
    );
  }
    
  // Método para mostrar notificaciones
  void _mostrarNotificacion(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
                    ),
        margin: EdgeInsets.all(10),
        duration: Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            },
                          ),
                  ),
    );
  }

  Future<void> _agregarProducto() async {
    if (_nombreController.text.isEmpty || _cantidadController.text.isEmpty) {
      _mostrarNotificacion('Por favor, completa los campos requeridos', esError: true);
      return;
    }

    // Validar que la cantidad sea un número
    int? cantidad;
    try {
      cantidad = int.parse(_cantidadController.text);
    } catch (e) {
      _mostrarNotificacion('La cantidad debe ser un número válido', esError: true);
      return;
    }

    final nuevoProducto = Producto(
      nombre: _nombreController.text,
      cantidad: cantidad,
      ubicacion: _ubicacionController.text.isEmpty ? 'Sin ubicación' : _ubicacionController.text,
      fecha: _fechaIngreso,
    );

    try {
      await Provider.of<ProductosProvider>(context, listen: false).agregarProducto(nuevoProducto);
      _nombreController.clear();
      _cantidadController.clear();
      _ubicacionController.clear();
      
      // Mostrar notificación de éxito
      _mostrarNotificacion('Producto agregado con éxito');
    } catch (e) {
      _mostrarNotificacion('Error al agregar el producto: ${e.toString()}', esError: true);
  }
}

  @override
  void dispose() {
    _nombreController.dispose();
    _cantidadController.dispose();
    _ubicacionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Almacenamiento'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => Provider.of<ProductosProvider>(context, listen: false).cargarProductos(),
          ),
        ],
      ),
      body: Consumer<ProductosProvider>(
        builder: (context, productosProvider, child) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextField(
                          controller: _nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre del producto',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.production_quantity_limits),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _cantidadController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Cantidad disponible',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.confirmation_number),
                          ),
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _ubicacionController,
                          decoration: InputDecoration(
                            labelText: 'Ubicación en el almacén',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: productosProvider.isLoading ? null : _agregarProducto,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                            textStyle: TextStyle(fontSize: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: productosProvider.isLoading 
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text('Agregar Producto'),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Expanded(
                  child: productosProvider.isLoading
                      ? Center(child: CircularProgressIndicator())
                      : productosProvider.productos.isEmpty
                          ? Center(
                              child: Text(
                                'No hay productos registrados',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: productosProvider.productos.length,
                              itemBuilder: (context, index) {
                                final producto = productosProvider.productos[index];
                                return Card(
                                  elevation: 3,
                                  margin: EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.all(16),
                                    title: Text(
                                      producto.nombre,
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Cantidad: ${producto.cantidad} - '
                                      'Ubicación: ${producto.ubicacion} - '
                                      'Fecha: ${producto.fecha}',
                                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}