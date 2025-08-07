import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/holidays_provider.dart';
import '../l10n/app_localizations.dart';
import 'package:intl/intl.dart';

class HolidaysCard extends StatefulWidget {
  @override
  _HolidaysCardState createState() => _HolidaysCardState();
}

class _HolidaysCardState extends State<HolidaysCard> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
      Provider.of<HolidaysProvider>(context, listen: false).fetchHolidays()
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HolidaysProvider>(
      builder: (context, holidaysProvider, _) {
        if (holidaysProvider.isLoading) {
          return Card(
            elevation: 4,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        if (holidaysProvider.error.isNotEmpty) {
          return Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                holidaysProvider.error,
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.indigo),
                    SizedBox(width: 8),
                    Text(
                      'Próximos días feriados',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Container(
                  height: 200, // Altura fija para la lista
                  child: ListView.builder(
                    itemCount: holidaysProvider.holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidaysProvider.holidays[index];
                      final date = DateFormat('dd/MM/yyyy').format(
                        DateTime.parse(holiday.date)
                      );
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.indigo.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                date,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                holiday.localName,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}