import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key, required this.onRestart});
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.red, width: 2),
      ),
      title: Text(
        '¡GAME OVER!',
        style: TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.dangerous, color: Colors.red, size: 50),
          SizedBox(height: 20),
          Text(
            '¡Has encontrado una bomba!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            onPressed: () {
              // Obtener el proveedor de Bluetooth para reiniciar el tablero
              final bluetoothProvider = Provider.of<BluetoothProvider>(
                context,
                listen: false,
              );

              // Enviar comando de reinicio al Arduino
              bluetoothProvider.sendData('reinicio');

              onRestart();

              Navigator.of(context).pop(); // Cierra el diálogo
            },
            child: Text(
              'Reiniciar juego',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
