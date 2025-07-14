import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'inventario.dart';
import 'almacenamiento.dart';
import 'seguimiento.dart';
import 'reportes.dart';
import 'settings_screen.dart';
import 'sensores_screen.dart';
import 'l10n/app_localizations.dart';
import 'providers/language_provider.dart';
import 'providers/productos_provider.dart';
import 'widgets/language_switch_button.dart';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      try {
        Provider.of<ProductosProvider>(context, listen: false).cargarProductos();
      } catch (e) {
        print('Error al cargar productos: \$e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isEnglish = languageProvider.isEnglish();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.translate("home")),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [
          LanguageSwitchButton(),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
                image: DecorationImage(
                  image: AssetImage('assets/images/logo.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Text(
                '',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 5,
                      offset: Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.language, color: Colors.indigo),
              title: Row(
                children: [
                  Text(localizations.translate("language") + ": "),
                  Text(
                    isEnglish ? "English" : "Español",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              trailing: Switch(
                value: isEnglish,
                activeColor: Colors.indigo,
                onChanged: (value) {
                  final newLanguage = value ? 'en' : 'es';
                  languageProvider.changeLanguage(newLanguage);
                },
              ),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.inventory, color: Colors.indigo),
              title: Text(localizations.translate("inventory")),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => InventarioScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.storage, color: Colors.indigo),
              title: Text(localizations.translate("storage")),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlmacenamientoScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.sensors, color: Colors.indigo),
              title: Text(localizations.translate("sensors")),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SensoresScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on, color: Colors.indigo),
              title: Text(localizations.translate("tracking")),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SeguimientoScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.indigo),
              title: Text(localizations.translate("reports")),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ReportesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.indigo),
              title: Text(localizations.translate("settings")),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text(localizations.translate("logout")),
              onTap: () {
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: DashboardBody(),
    );
  }
}

class DashboardBody extends StatelessWidget {
  final Random random = Random();

  List<double> getRandomData() {
    return List.generate(7, (_) => random.nextDouble() * 100);
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final productosProvider = Provider.of<ProductosProvider>(context);

    final humedadActual = (random.nextDouble() * 100).toStringAsFixed(1);
    final temperaturaActual = (15 + random.nextDouble() * 15).toStringAsFixed(1);
    final luzActual = (random.nextDouble() * 100).toStringAsFixed(1);

    return RefreshIndicator(
      onRefresh: () async {
        await productosProvider.cargarProductos();
      },
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'RIM LOGISTIC',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  Text(
                    localizations.translate("app_title").split(' - ')[1],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _buildSummaryCard(
              context,
              localizations.translate("inventory_summary"),
              Icons.inventory,
              Colors.blue,
              [
                _buildStatItem(context, localizations.translate("total_products"), productosProvider.productos.length.toString()),
                _buildStatItem(context, localizations.translate("total_items"), productosProvider.productos.fold(0, (sum, p) => sum + p.cantidad).toString()),
                _buildStatItem(context, localizations.translate("storage_locations"), productosProvider.productos.map((p) => p.ubicacion).toSet().length.toString()),
              ],
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => InventarioScreen()));
              },
            ),
            SizedBox(height: 16),
            _buildSummaryCard(
              context,
              localizations.translate("sensor_readings"),
              Icons.sensors,
              Colors.green,
              [
                _buildStatItem(context, localizations.translate("humidity"), "$humedadActual%"),
                _buildStatItem(context, localizations.translate("temperature"), "$temperaturaActual°C"),
                _buildStatItem(context, localizations.translate("light_level"), "$luzActual%"),
              ],
              () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SensoresScreen()));
              },
            ),
            SizedBox(height: 16),
            _buildRecentActivitiesCard(context),
            SizedBox(height: 16),
            Text(
              localizations.translate("quick_access"),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[800],
              ),
            ),
            SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildQuickAccessButton(context, localizations.translate("add_product"), Icons.add_circle_outline, Colors.indigo, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => InventarioScreen()));
                }),
                _buildQuickAccessButton(context, localizations.translate("check_sensors"), Icons.sensors, Colors.green, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SensoresScreen()));
                }),
                _buildQuickAccessButton(context, localizations.translate("view_reports"), Icons.bar_chart, Colors.amber[700]!, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ReportesScreen()));
                }),
                _buildQuickAccessButton(context, localizations.translate("tracking"), Icons.location_on, Colors.red, () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SeguimientoScreen()));
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String title, IconData icon, Color color, List<Widget> stats, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 24),
                  SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Divider(height: 24),
              ...stats,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.black54)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(BuildContext context, String description, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(width: 8),
          Expanded(child: Text(description)),
          Text(time, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecentActivitiesCard(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final activities = [
      {
        'description': localizations.translate("product_added_activity"),
        'time': '10:30',
        'icon': Icons.add_circle,
        'color': Colors.green,
      },
      {
        'description': localizations.translate("product_updated_activity"),
        'time': '09:15',
        'icon': Icons.edit,
        'color': Colors.blue,
      },
      {
        'description': localizations.translate("sensor_alert_activity"),
        'time': '08:45',
        'icon': Icons.warning,
        'color': Colors.orange,
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: Colors.indigo, size: 24),
                SizedBox(width: 8),
                Text(
                  localizations.translate("recent_activities"),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ],
            ),
            Divider(height: 24),
            ...activities.map((activity) => _buildActivityItem(
              context,
              activity['description'] as String,
              activity['time'] as String,
              activity['icon'] as IconData,
              activity['color'] as Color,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAccessButton(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white, fontSize: 21)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}