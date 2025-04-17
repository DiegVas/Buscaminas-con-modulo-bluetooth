import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TitleGameScreen extends StatelessWidget {
  const TitleGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Text(
              'BUSCA\nMINAS',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 180,
                color: Colors.black,
                fontFamily: "PCTL4800",
                decoration: TextDecoration.none,
                height: 0.8,
              ),
            ),
          ),

          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              /*   Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BluetoothConnectionScreen(),
                ),
              );*/
            },
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
