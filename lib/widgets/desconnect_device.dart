import 'package:flutter/material.dart';

class DesconectDevice extends StatelessWidget {
  const DesconectDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Dispositivo Bluetooth desconectado',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: Text(
        'Se ha perdido la conexión con el dispositivo Bluetooth.',
        style: TextStyle(color: Colors.black),
      ),
      backgroundColor: Colors.yellow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Cierra el diálogo
          },
          child: Text(
            'Aceptar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
