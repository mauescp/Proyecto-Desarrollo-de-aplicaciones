import 'package:appgestion/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/productos_provider.dart';
import 'models/producto.dart';
import 'widgets/language_switch_button.dart';

class InventarioScreen extends StatefulWidget {
  @override
  _InventarioScreenState createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  // Controladores para los campos de edición
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Cargar productos al iniciar la pantalla
    Future.microtask(() => 
      Provider.of<ProductosProvider>(context, listen: false).cargarProductos()
    );
  }
    
  // Método para mostrar el selector de fecha
  Future<void> _seleccionarFecha(BuildContext context) async {
    // Intentar parsear la fecha actual del controlador
    DateTime fechaInicial;
              try {
      // Asumiendo formato dd/MM/yyyy
      final partes = _fechaController.text.split('/');
      if (partes.length == 3) {
        fechaInicial = DateTime(
          int.parse(partes[2]), // año
          int.parse(partes[1]), // mes
          int.parse(partes[0]), // día
              );
      } else {
        fechaInicial = DateTime.now();
      }
              } catch (e) {
      fechaInicial = DateTime.now();
}

    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: fechaInicial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blueAccent,
            colorScheme: ColorScheme.light(primary: Colors.blueAccent),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      _fechaController.text = DateFormat('dd/MM/yyyy').format(fechaSeleccionada);
  }
  }

  // Método para mostrar el diálogo de edición
  void _mostrarDialogoEdicion(BuildContext context, Producto producto) {
    // Inicializar controladores con valores actuales
    _nombreController.text = producto.nombre;
    _cantidadController.text = producto.cantidad.toString();
    _ubicacionController.text = producto.ubicacion;
    _fechaController.text = producto.fecha;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Producto'),
        content: SingleChildScrollView(
          child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                        ),
              SizedBox(height: 10),
              TextField(
                controller: _cantidadController,
                decoration: InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
                        ),
              SizedBox(height: 10),
              TextField(
                controller: _ubicacionController,
                decoration: InputDecoration(labelText: 'Ubicación'),
                    ),
              SizedBox(height: 10),
              // Campo de fecha con botón para abrir el calendario
              TextField(
                controller: _fechaController,
                readOnly: true, // Evitar edición directa
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _seleccionarFecha(context),
                  ),
                ),
                onTap: () => _seleccionarFecha(context),
            ),
            ],
          ),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              // Validar que la cantidad sea un número
              int? cantidad;
              try {
                cantidad = int.parse(_cantidadController.text);
              } catch (e) {
                _mostrarNotificacion(context, 'La cantidad debe ser un número válido', esError: true);
                return;
}

              // Actualizar el producto
              final productoActualizado = Producto(
                id: producto.id,
                nombre: _nombreController.text,
                cantidad: cantidad,
                ubicacion: _ubicacionController.text,
                fecha: _fechaController.text,
              );
              
              try {
                await Provider.of<ProductosProvider>(context, listen: false)
                  .actualizarProducto(productoActualizado);
                
                // Cerrar el diálogo
                Navigator.pop(context);
                
                // Mostrar notificación
                _mostrarNotificacion(context, 'Producto actualizado con éxito');
              } catch (e) {
                _mostrarNotificacion(context, 'Error al actualizar producto: ${e.toString()}', esError: true);
}
            },
            child: Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Método para mostrar notificaciones de manera segura
  void _mostrarNotificacion(BuildContext context, String mensaje, {bool esError = false}) {
    // Verificar que el contexto sigue siendo válido y montado
    if (!context.mounted) return;
    
    // Usar un post-frame callback para asegurarse de que el widget está completamente construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
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
                if (context.mounted) {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }
                          },
                        ),
                    ),
                );
      }
    });
  }

  @override
  void dispose() {
    // Liberar recursos de los controladores
    _nombreController.dispose();
    _cantidadController.dispose();
    _ubicacionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("inventory")),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          // Botón de cambio de idioma
          LanguageSwitchButton(),
          // Botón de actualizar
                        IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => Provider.of<ProductosProvider>(context, listen: false).cargarProductos(),
                        ),
                                ],
                              ),
      body: Consumer<ProductosProvider>(
        builder: (context, productosProvider, child) {
          if (productosProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          final productos = productosProvider.productos;
          
          if (productos.isEmpty) {
            return Center(
              child: Text(
                localizations.translate("no_products_in_inventory"),
                style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
            );
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final producto = productos[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      producto.nombre,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
            ),
      ),
                    subtitle: Text(
                      'Cantidad: ${producto.cantidad} - '
                      'Ubicación: ${producto.ubicacion} - '
                      'Fecha: ${producto.fecha}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón de edición
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _mostrarDialogoEdicion(context, producto),
                          tooltip: localizations.translate("edit_product"),
                        ),
                        // Botón de eliminación
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            // Mostrar diálogo de confirmación
                            final confirmar = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(localizations.translate("confirm_deletion")),
                                content: Text(localizations.translate("are_you_sure_delete_product")),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(localizations.translate("cancel")),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(localizations.translate("delete"), style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
    );
                            
                            if (confirmar == true) {
                              try {
                                await Provider.of<ProductosProvider>(context, listen: false)
                                  .eliminarProducto(producto.id!);
                                _mostrarNotificacion(context, localizations.translate("product_deleted_successfully"));
                              } catch (e) {
                                _mostrarNotificacion(context, localizations.translate("error_deleting_product") + ': ${e.toString()}', esError: true);
  }
}
                          },
                          tooltip: localizations.translate("delete_product"),
                        ),
                      ],
                    ),
                    onTap: () => _mostrarDialogoEdicion(context, producto),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}