// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';
import 'package:proyect_orga/pages/title_game_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BluetoothProvider(),
      child: const MinesweeperApp(),
    ),
  );
}

class MinesweeperApp extends StatelessWidget {
  const MinesweeperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minesweeper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        fontFamily: 'Montserrat',
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1A1B41),
      ),
      home: Scaffold(body: SafeArea(child: TitleGameScreen())),
    );
  }
}
