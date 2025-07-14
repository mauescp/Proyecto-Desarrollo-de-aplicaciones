import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'dart:async';

import 'l10n/app_localizations.dart';
import 'widgets/language_switch_button.dart';

class ReportesScreen extends StatefulWidget {
  @override
  _ReportesScreenState createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool _isGenerating = false;

  Future<void> _generarReportePDF(String titulo, String contenido, BuildContext context) async {
    if (_isGenerating) return;
    setState(() => _isGenerating = true);
    final localizations = AppLocalizations.of(context);

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              SizedBox(width: 10),
              Text(localizations.translate("generating_report") ?? "Generando reporte..."),
            ],
          ),
          duration: Duration(seconds: 30),
        ),
      );

      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(titulo, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text(contenido),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Text(
                "RIM LOGISTIC - ${localizations.translate("report_generated") ?? "Informe generado el"} ${DateTime.now().toString().split('.')[0]}",
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
            ],
          ),
        ),
      );

      final output = await getApplicationDocumentsDirectory();
      final fileName = "${titulo.replaceAll(" ", "_")}_${DateTime.now().millisecondsSinceEpoch}.pdf";
      final file = File("${output.path}/$fileName");
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.translate("report_generated_success") ?? "Reporte generado con éxito"),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: localizations.translate("open") ?? "Abrir",
            textColor: Colors.white,
            onPressed: () async {
              await OpenFile.open(file.path);
            },
          ),
        ),
      );

      // Eliminar esta línea para evitar que se trabe:
      // await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${localizations.translate("report_error") ?? "Error al generar reporte"}: $e"),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final reportes = [
      {
        'title': localizations.translate("inventory_report") ?? "Informe de inventario",
        'description': localizations.translate("inventory_report_desc") ?? "Resumen de todos los productos en inventario",
        'icon': Icons.inventory,
        'content': localizations.translate("inventory_report_content") ?? "Este informe muestra un resumen detallado de todos los productos actualmente en el inventario, incluyendo cantidades, ubicaciones y fechas de caducidad.",
      },
      {
        'title': localizations.translate("movements_report") ?? "Informe de movimientos",
        'description': localizations.translate("movements_report_desc") ?? "Entradas y salidas de productos",
        'icon': Icons.swap_horiz,
        'content': localizations.translate("movements_report_content") ?? "Este informe muestra todas las entradas y salidas de productos en el sistema, incluyendo fechas, cantidades y responsables.",
      },
      {
        'title': localizations.translate("locations_report") ?? "Informe de ubicaciones",
        'description': localizations.translate("locations_report_desc") ?? "Distribución de productos por ubicación",
        'icon': Icons.place,
        'content': localizations.translate("locations_report_content") ?? "Este informe muestra cómo están distribuidos los productos en las diferentes ubicaciones de almacenamiento.",
      },
      {
        'title': localizations.translate("expiry_report") ?? "Informe de caducidad",
        'description': localizations.translate("expiry_report_desc") ?? "Productos próximos a caducar",
        'icon': Icons.timer,
        'content': localizations.translate("expiry_report_content") ?? "Este informe muestra los productos que están próximos a caducar, ordenados por fecha de caducidad.",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', height: 30),
            SizedBox(width: 10),
            Text(localizations.translate("reports") ?? "Reportes"),
          ],
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        actions: [LanguageSwitchButton()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.translate("available_reports") ?? "Informes disponibles",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.indigo),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: reportes.length,
                  itemBuilder: (context, index) {
                    final reporte = reportes[index];
                    return _buildReportCard(
                      context,
                      reporte['title'] as String,
                      reporte['description'] as String,
                      reporte['icon'] as IconData,
                      reporte['content'] as String,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, String title, String description, IconData icon, String content) {
    final localizations = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [Icon(icon, color: Colors.indigo), SizedBox(width: 10), Expanded(child: Text(title))],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(description, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(content),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(localizations.translate("cancel") ?? "Cancelar"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generarReportePDF(title, content, context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                child: Text(localizations.translate("generate") ?? "Generar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Icon(icon, color: Colors.indigo),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    SizedBox(height: 4),
                    Text(description, style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
              ElevatedButton.icon(
                icon: Icon(Icons.download, color: Colors.white, size: 18),
                label: Text(localizations.translate("generate") ?? "Generar", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _isGenerating ? null : () => _generarReportePDF(title, content, context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
