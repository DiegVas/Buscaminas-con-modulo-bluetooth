import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
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
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  void _startBackgroundMusic() async {
    await _backgroundMusicPlayer.setReleaseMode(
      ReleaseMode.loop,
    ); // Configurar en bucle
    await _backgroundMusicPlayer.setVolume(
      0.3,
    ); // Volumen más bajo para el fondo
    await _backgroundMusicPlayer.play(AssetSource('sounds/title_music.mp3'));
    setState(() => _isMusicPlaying = true);
  }

  @override
  void initState() {
    super.initState();
    _startBackgroundMusic();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _backgroundMusicPlayer.stop();
    _backgroundMusicPlayer.dispose();
    super.dispose();
  }

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
        // ! Verifica si el dispositivo ya está conectado
        final result = await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          builder: (context) => BluetoothDeviceList(),
        );

        if (result != null && result is BluetoothDevice) {
          try {
            if (!context.mounted) return;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder:
                  (context) => AlertDialog(content: waitingConnection(result)),
            );

            // Intenta conectar con reintentos automáticos
            await bluetoothProvider
                .connectWithRetry(result, maxRetries: 3)
                .timeout(
                  Duration(seconds: 10),
                  onTimeout:
                      () =>
                          throw TimeoutException(
                            'La conexión tardó demasiado tiempo',
                          ),
                );

            // Cierra el diálogo de conexión
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();

            // Navega a la siguiente pantalla
            _backgroundMusicPlayer.pause();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BoardScreen()),
            ).then((_) {
              _startBackgroundMusic();
            });
          } catch (e) {
            // Cierra el diálogo de conexión si está abierto
            if (!context.mounted) return;
            Navigator.of(context, rootNavigator: true).pop();

            // Muestra un mensaje de error específico
            await showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: Text('Error de conexión'),
                    content: Container(
                      margin: const EdgeInsets.all(10),
                      child: Text(
                        'No se pudo conectar al dispositivo: ${e.toString()}\n\nVerifica que el dispositivo esté encendido y dentro del alcance.',
                      ),
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

Widget waitingConnection(dynamic result) {
  return Container(
    margin: const EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: Colors.yellow),
        SizedBox(height: 30),
        Text('Estableciendo conexión con:'),
        Text("${result.name}", style: TextStyle(fontSize: 20)),
      ],
    ),
  );
}
