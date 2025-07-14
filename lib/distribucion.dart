import 'package:flutter/material.dart';
import 'dart:math';

class DistribucionScreen extends StatefulWidget {
  @override
  _DistribucionScreenState createState() => _DistribucionScreenState();
}

class _DistribucionScreenState extends State<DistribucionScreen> {
  final TextEditingController _productoController = TextEditingController();
  final TextEditingController _cantidadController = TextEditingController();
  final TextEditingController _destinoController = TextEditingController();
  String _estadoOrden = 'Pendiente';

  List<Map<String, dynamic>> ordenes = [];

  void _agregarOrden() {
    if (_productoController.text.isEmpty || _cantidadController.text.isEmpty || _destinoController.text.isEmpty) {
      return;
    }
    setState(() {
      ordenes.add({
        'id': Random().nextInt(10000),
        'producto': _productoController.text,
        'cantidad': int.parse(_cantidadController.text),
        'destino': _destinoController.text,
        'fecha': DateTime.now().toString().split(' ')[0],
        'estado': _estadoOrden,
      });
      _productoController.clear();
      _cantidadController.clear();
      _destinoController.clear();
    });
  }

  void _eliminarOrden(int index) {
    setState(() {
      ordenes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gestión de Distribución'),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: Padding(
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
                      controller: _productoController,
                      decoration: InputDecoration(
                        labelText: 'Producto a distribuir',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.local_shipping),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _cantidadController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Cantidad',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.confirmation_number),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _destinoController,
                      decoration: InputDecoration(
                        labelText: 'Destino de entrega',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    SizedBox(height: 10),
                    DropdownButtonFormField(
                      value: _estadoOrden,
                      items: ['Pendiente', 'En tránsito', 'Entregado']
                          .map((estado) => DropdownMenuItem(
                                value: estado,
                                child: Text(estado),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _estadoOrden = value.toString();
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Estado de la orden',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _agregarOrden,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text('Agregar Orden'),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ordenes.length,
                itemBuilder: (context, index) {
                  var orden = ordenes[index];
                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        'Orden ID: ${orden['id']} - ${orden['producto']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Cantidad: ${orden['cantidad']} - Destino: ${orden['destino']} - Estado: ${orden['estado']} - Fecha: ${orden['fecha']}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminarOrden(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}