import 'package:flutter/material.dart';

class ProcessElement extends StatelessWidget {
  final int index;
  const ProcessElement({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.yellow, width: 2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            strokeWidth: 3,
          ),
          const SizedBox(height: 20),
          Text(
            'Procesando casilla ${index + 1}...',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
