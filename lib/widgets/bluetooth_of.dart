import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Provider/bluetooth_provider.dart';

class BluetoothOffDialog extends StatelessWidget {
  const BluetoothOffDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bluetooth_set = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bluetooth, size: 50, color: Colors.teal),
            const SizedBox(height: 20),
            const Text(
              'El Bluetooth está apagado. Por favor, actívalo para continuar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Cerrar el cuadro
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 252, 238, 44),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    bluetooth_set.bluetoothState = true;
                    Navigator.pop(context, true);
                  },
                  child: const Text(
                    'Aceptar',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
