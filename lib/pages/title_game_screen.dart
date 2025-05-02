import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';
import 'package:proyect_orga/pages/board_screen.dart';
import 'package:proyect_orga/pages/bluetooth_divice.dart';
import 'package:proyect_orga/widgets/bluetooth_of.dart';

class TitleGameScreen extends StatefulWidget {
  const TitleGameScreen({super.key});

  @override
  State<TitleGameScreen> createState() => _TitleGameScreenState();
}

class _TitleGameScreenState extends State<TitleGameScreen> {
  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    void startConnection() async {
      if (!bluetoothProvider.bluetoothState) {
        await showDialog(
          context: context,
          builder: (context) => const BluetoothOffDialog(),
        );
      } else {
        final result = await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (context) {
            return BluetoothDeviceList();
          },
        );
        if (result != null && result is BluetoothDevice) {
          try {
            // Muestra un indicador de carga
            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(
                    title: Text('Conectando...'),
                    content: Row(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(width: 20),
                        Text('Estableciendo conexión con ${result.name}'),
                      ],
                    ),
                  ),
            );

            // Intenta conectar con reintentos automáticos
            await bluetoothProvider
                .connectWithRetry(result, maxRetries: 3)
                .timeout(
                  Duration(seconds: 15),
                  onTimeout:
                      () =>
                          throw TimeoutException(
                            'La conexión tardó demasiado tiempo',
                          ),
                );

            // Cierra el diálogo de conexión
            Navigator.of(context, rootNavigator: true).pop();

            // Navega a la siguiente pantalla
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BoardScreen()),
            );
          } catch (e) {
            // Cierra el diálogo de conexión si está abierto
            Navigator.of(context, rootNavigator: true).pop();

            // Muestra un mensaje de error específico
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Error de conexión'),
                    content: Text(
                      'No se pudo conectar al dispositivo: ${e.toString()}\n\nVerifica que el dispositivo esté encendido y dentro del alcance.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('OK'),
                      ),
                      TextButton(
                        onPressed: () => startConnection(),
                        child: Text('Reintentar'),
                      ),
                    ],
                  ),
            );
          }
        }
      }
    }

    return Container(
      color: Colors.white,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 275,
            child: RotatedBox(
              quarterTurns: 3,

              child: Text(
                'BUSCA\nMINAS',
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 150,
                  color: Colors.black,
                  fontFamily: "PCTL4800",
                  decoration: TextDecoration.none,
                  height: 0.8,
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),

          ElevatedButton(
            onPressed: startConnection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 252, 238, 44),
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'Connect Bluetooth',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
