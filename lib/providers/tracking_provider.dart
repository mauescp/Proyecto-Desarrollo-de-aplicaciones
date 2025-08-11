import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TrackingProvider with ChangeNotifier {
  bool _isLoading = false;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;
  
  // Valores predeterminados para origen y destino
  final LatLng _origen = LatLng(19.4326, -99.1332); // Ciudad de México
  final LatLng _destino = LatLng(20.6597, -103.3496); // Guadalajara
  
  // API key de Google Maps - Reemplaza con tu clave real
  final String _apiKey = "AIzaSyA_ExampleAPIKey123456789";

  // Getters
  bool get isLoading => _isLoading;
  Position? get currentPosition => _currentPosition;
  Set<Marker> get markers => _markers;
  Set<Polyline> get polylines => _polylines;
  LatLng get origen => _origen;
  LatLng get destino => _destino;
  
  // Método para inicializar y obtener la ubicación
  Future<void> initLocation() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _determinePosition();
    } catch (e) {
      print("Error inicializando ubicación: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Establecer el controlador del mapa
  void setMapController(GoogleMapController controller) {
    _mapController = controller;
    notifyListeners();
  }

  // Función para obtener la ubicación actual
  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verificar si los servicios de ubicación están habilitados
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Los servicios de ubicación están desactivados');
    }

    // Verificar permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Los permisos de ubicación fueron denegados');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Los permisos de ubicación están permanentemente denegados');
    }

    // Obtener la posición actual
    _currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    // Añadir marcador para la ubicación actual
    _addMarker(
      LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
      "Tu ubicación actual",
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
    );
  }

  // Añadir un marcador al mapa
  void _addMarker(LatLng position, String markerId, BitmapDescriptor icon) {
    _markers.add(
      Marker(
        markerId: MarkerId(markerId),
        position: position,
        infoWindow: InfoWindow(title: markerId),
        icon: icon,
      ),
    );
    notifyListeners();
  }

  // Obtener y dibujar la ruta
  Future<void> getRoute() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Limpiar marcadores existentes excepto la ubicación actual
      _markers.clear();
      _polylines.clear();
      
      if (_currentPosition != null) {
        _addMarker(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          "Tu ubicación actual",
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        );
      }

      // Añadir marcadores de origen y destino
      _addMarker(
        _origen,
        "Origen",
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      _addMarker(
        _destino,
        "Destino",
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      // Obtener la ruta
      await _fetchRoute();
      
    } catch (e) {
      print("Error obteniendo ruta: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Método para obtener la ruta desde la API de Google Directions
  Future<void> _fetchRoute() async {
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_origen.latitude},${_origen.longitude}'
        '&destination=${_destino.latitude},${_destino.longitude}'
        '&mode=driving'
        '&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          // Decodificar los puntos del polyline
          List<LatLng> polylineCoordinates = [];
          
          // Obtener los puntos codificados
          String points = data['routes'][0]['overview_polyline']['points'];
          polylineCoordinates = _decodePolyline(points);

          // Crear un polyline con los puntos decodificados
          Polyline polyline = Polyline(
            polylineId: PolylineId('route'),
            color: Colors.blue,
            points: polylineCoordinates,
            width: 5,
          );

          _polylines.add(polyline);

          // Ajustar la cámara para mostrar la ruta completa
          if (_mapController != null && polylineCoordinates.isNotEmpty) {
            LatLngBounds bounds = _getBounds(polylineCoordinates);
            _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 50),
            );
          }
        } else {
          throw Exception('Error en la respuesta de Directions API: ${data['status']}');
        }
      } else {
        throw Exception('Error en la solicitud HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print("Error obteniendo ruta: $e");
      rethrow;
    }
  }

  // Función para decodificar los puntos codificados del polyline
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      poly.add(LatLng(latitude, longitude));
    }
    return poly;
  }

  // Función para obtener los límites del mapa basados en la ruta
  LatLngBounds _getBounds(List<LatLng> polylineCoordinates) {
    double minLat = polylineCoordinates.first.latitude;
    double maxLat = polylineCoordinates.first.latitude;
    double minLng = polylineCoordinates.first.longitude;
    double maxLng = polylineCoordinates.first.longitude;

    for (var point in polylineCoordinates) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}