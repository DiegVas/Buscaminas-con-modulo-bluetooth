import 'package:flutter/material.dart';

class ReloadBoard extends StatelessWidget {
  const ReloadBoard({super.key});

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
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.yellow),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text('Reiniciando tablero...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}
