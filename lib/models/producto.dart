class Producto {
  final int? id;
  final String nombre;
  final int cantidad;
  final String ubicacion;
  final String fecha;

  Producto({
    this.id,
    required this.nombre,
    required this.cantidad,
    required this.ubicacion,
    required this.fecha,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
      'ubicacion': ubicacion,
      'fecha': fecha,
    };
  }

  factory Producto.fromMap(Map<String, dynamic> map) {
    return Producto(
      id: map['id'],
      nombre: map['nombre'],
      cantidad: map['cantidad'],
      ubicacion: map['ubicacion'],
      fecha: map['fecha'],
    );
  }

  Producto copyWith({
    int? id,
    String? nombre,
    int? cantidad,
    String? ubicacion,
    String? fecha,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      ubicacion: ubicacion ?? this.ubicacion,
      fecha: fecha ?? this.fecha,
    );
  }
}