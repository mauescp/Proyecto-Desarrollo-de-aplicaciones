import 'package:flutter/material.dart';
import '../services/bluetooth_manager.dart';
import '../l10n/app_localizations.dart';

class BluetoothStatusWidget extends StatelessWidget {
  final BluetoothManager bluetoothManager;

  BluetoothStatusWidget({required this.bluetoothManager});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: bluetoothManager.dataStream,
      builder: (context, snapshot) {
        bool isConnected = bluetoothManager.isConnected;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isConnected ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bluetooth,
                size: 16,
                color: isConnected ? Colors.green : Colors.red,
              ),
              SizedBox(width: 4),
              Text(
                isConnected 
                    ? AppLocalizations.of(context).translate("connected")
                    : AppLocalizations.of(context).translate("disconnected"),
                style: TextStyle(
                  color: isConnected ? Colors.green : Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}