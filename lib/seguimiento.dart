import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'widgets/language_switch_button.dart';
import 'providers/tracking_provider.dart';

class SeguimientoScreen extends StatefulWidget {
  @override
  _SeguimientoScreenState createState() => _SeguimientoScreenState();
}

class _SeguimientoScreenState extends State<SeguimientoScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializamos el provider al cargar la pantalla
    Future.microtask(() => 
      Provider.of<TrackingProvider>(context, listen: false).initLocation()
    );
  }
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("tracking")),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          LanguageSwitchButton(),
        ],
      ),
      body: Consumer<TrackingProvider>(
        builder: (context, trackingProvider, child) {
          return trackingProvider.isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(
                        target: trackingProvider.currentPosition != null
                            ? LatLng(
                                trackingProvider.currentPosition!.latitude, 
                                trackingProvider.currentPosition!.longitude
                              )
                            : trackingProvider.origen,
                        zoom: 15,
                      ),
                      onMapCreated: (GoogleMapController controller) {
                        trackingProvider.setMapController(controller);
                      },
                      markers: trackingProvider.markers,
                      polylines: trackingProvider.polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      zoomControlsEnabled: true,
                      compassEnabled: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          "Seguimiento de Ruta Terrestre",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Visualiza la ruta terrestre para el seguimiento de embarques en tiempo real.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            try {
                              trackingProvider.getRoute();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error al obtener la ruta: $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            child: Text(
                              "Mostrar Ruta de Seguimiento",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
        },
      ),
    );
  }
}