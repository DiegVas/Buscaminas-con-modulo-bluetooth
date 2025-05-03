import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';
import 'package:proyect_orga/widgets/desconnect_device.dart';
import 'package:proyect_orga/widgets/game_over_dialog.dart';
import 'package:proyect_orga/widgets/process_element.dart';
import 'package:proyect_orga/widgets/reload_board.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final Set<int> pressButtons = {};
  late StreamSubscription _connectionSubscription;
  late StreamSubscription _dataSubscription;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundMusicPlayer = AudioPlayer();

  bool _isProcessing = false;
  String _pendingResponse = '';
  bool _isMusicPlaying = false;

  void desconectConection() {
    if (!mounted) return;
    showDialog(context: context, builder: (context) => DesconectDevice());
  }

  @override
  void initState() {
    super.initState();

    final bluetoothProvider = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );

    _connectionSubscription = bluetoothProvider.connectionStateStream.listen((
      isConnected,
    ) {
      if (!isConnected) desconectConection();
      _backgroundMusicPlayer.stop();
      _audioPlayer.stop();
    });

    // Suscripción para escuchar los datos recibidos del Bluetooth
    _dataSubscription = bluetoothProvider.dataReceivedStream.listen((data) {
      if (_pendingResponse.isNotEmpty) handleBluetoothResponse(data);
    });
    _startBackgroundMusic();
  }

  void _startBackgroundMusic() async {
    await _backgroundMusicPlayer.setReleaseMode(
      ReleaseMode.loop,
    ); // Configurar en bucle
    await _backgroundMusicPlayer.setVolume(
      0.3,
    ); // Volumen más bajo para el fondo
    await _backgroundMusicPlayer.play(AssetSource('sounds/music.mp3'));
    setState(() => _isMusicPlaying = true);
  }

  void toggleBackgroundMusic() async {
    if (_isMusicPlaying) {
      await _backgroundMusicPlayer.pause();
    } else {
      await _backgroundMusicPlayer.resume();
    }
    setState(() => _isMusicPlaying = !_isMusicPlaying);
  }

  void handleBluetoothResponse(String response) {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    if (response == "1") {
      // Reproducir sonido de explosión para bomba
      _audioPlayer.play(AssetSource('sounds/explosion.mp3'));
      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return GameOverDialog(
            onRestart: () => setState(() => pressButtons.clear()),
          );
        },
      );

      // Añadir casilla a pressButtons usando el índice de _pendingResponse
      int casilla = int.parse(_pendingResponse) - 1;
      setState(() {
        pressButtons.add(casilla);
        _isProcessing = false;
      });
    } else if (response == "0") {
      // Reproducir sonido para casilla vacía
      _audioPlayer.play(AssetSource('sounds/empty.mp3'));

      // Añadir casilla a pressButtons usando el índice de _pendingResponse
      int casilla = int.parse(_pendingResponse) - 1;
      setState(() {
        pressButtons.add(casilla);
        _isProcessing = false;
      });
    }

    setState(() => _pendingResponse = '');
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _dataSubscription.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    _backgroundMusicPlayer.stop();
    _backgroundMusicPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    void pressTarget(int index) {
      // Enviar dato al Arduino
      bluetoothProvider.sendData('${index + 1}');

      // Verificar si ya estamos procesando una acción
      if (_isProcessing) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Procesando... Por favor espere'),
            duration: Duration(milliseconds: 500),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (pressButtons.contains(index)) return;

      setState(() {
        _isProcessing = true;
        _pendingResponse =
            '${index + 1}'; // Guardar qué casilla estamos esperando
      });

      // Mostrar diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => ProcessElement(index: index),
      );

      // Crear un temporizador cancelable
      Timer? timeoutTimer = Timer(const Duration(seconds: 5), () {
        if (_pendingResponse.isNotEmpty) {
          // Si no recibimos respuesta en 5 segundos, cerramos el diálogo
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              _isProcessing = false;
              _pendingResponse = '';
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No se recibió respuesta del dispositivo'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      });

      // Modificar el manejador de respuesta Bluetooth para cancelar el temporizador
      _dataSubscription.cancel(); // Cancelar la suscripción anterior
      _dataSubscription = bluetoothProvider.dataReceivedStream.listen((data) {
        if (_pendingResponse.isNotEmpty) {
          // Cancelar el temporizador cuando recibimos respuesta
          timeoutTimer?.cancel();
          handleBluetoothResponse(data);
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          'BUSCA MINAS',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w300,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            bluetoothProvider.disconnect();
            _backgroundMusicPlayer.stop();
            _audioPlayer.stop();
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white24, width: 1),
          ),
          margin: EdgeInsets.symmetric(vertical: 114, horizontal: 16),
          padding: EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: 16,
                  itemBuilder:
                      (context, index) => GestureDetector(
                        onTap: () => pressTarget(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                pressButtons.contains(index)
                                    ? Colors.white24
                                    : Colors.yellow,
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Verificar si ya estamos procesando una acción
                      if (_isProcessing) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Procesando... Por favor espere'),
                            duration: Duration(milliseconds: 500),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Activar bandera de procesamiento
                      setState(() => _isProcessing = true);

                      // Mostrar diálogo de reinicio
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return ReloadBoard();
                        },
                      );

                      // Obtener el proveedor Bluetooth
                      final bluetoothProvider = Provider.of<BluetoothProvider>(
                        context,
                        listen: false,
                      );

                      // Enviar comando de reinicio al Arduino
                      bluetoothProvider.sendData('reinicio');

                      // Simular tiempo de procesamiento
                      Future.delayed(Duration(milliseconds: 1500), () {
                        // Cerrar el diálogo de carga
                        Navigator.of(context, rootNavigator: true).pop();

                        setState(() {
                          // Limpiar todos los botones presionados
                          pressButtons.clear();
                          // Desactivar bandera de procesamiento
                          _isProcessing = false;
                        });

                        // Mostrar mensaje de confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡Tablero reiniciado con éxito!'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: CircleBorder(), // Forma circular
                      padding: EdgeInsets.all(20), // Ajusta el tamaño del botón
                    ),
                    child: Icon(Icons.replay_rounded, color: Colors.black),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
