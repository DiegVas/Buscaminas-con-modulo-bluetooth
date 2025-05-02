import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';

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

  bool _isProcessing = false;
  String _pendingResponse = '';

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
      if (!isConnected) {
        desconectConection();
      }
    });

    // Suscripción para escuchar los datos recibidos del Bluetooth
    _dataSubscription = bluetoothProvider.dataReceivedStream.listen((data) {
      if (_pendingResponse.isNotEmpty) {
        handleBluetoothResponse(data);
      }
    });
  }

  void handleBluetoothResponse(String response) {
    if (response == "1") {
      // Reproducir sonido de explosión para bomba
      _audioPlayer.play(AssetSource('sounds/explosion.mp3'));
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 500), () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return GameOverDialog();
            },
          );
        });
      }

      // Añadir casilla a pressButtons usando el índice de _pendingResponse
      int casilla = int.parse(_pendingResponse) - 1;
      setState(() {
        pressButtons.add(casilla);
      });

      // Esperar el comando "reinicio" para reiniciar el tablero
      _dataSubscription.onData((data) {
        if (data == "reinicio") {
          if (mounted) {
            Navigator.of(
              context,
              rootNavigator: true,
            ).pop(); // Cerrar el diálogo
            setState(() {
              pressButtons.clear(); // Limpiar los botones presionados
              _isProcessing = false; // Desactivar el estado de procesamiento
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Tablero reiniciado con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      });
    } else if (response == "0") {
      // Reproducir sonido para casilla vacía
      print("SAFE");
      _audioPlayer.play(AssetSource('sounds/empty.mp3'));

      // Añadir casilla a pressButtons usando el índice de _pendingResponse
      int casilla = int.parse(_pendingResponse) - 1;
      setState(() {
        pressButtons.add(casilla);
      });
    }

    setState(() {
      _pendingResponse = '';
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    _dataSubscription.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bluetoothProvider = Provider.of<BluetoothProvider>(context);

    void pressTarget(int index) {
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
        builder: (BuildContext context) {
          return ProcessElement(index: index);
        },
      );

      // Enviar dato al Arduino
      bluetoothProvider.sendData('${index + 1}');

      // Esperar respuesta con un timeout por seguridad
      // ...existing code...
      // Esperar respuesta con un timeout por seguridad
      Future.delayed(const Duration(seconds: 5), () {
        if (_pendingResponse.isNotEmpty) {
          // Si no recibimos respuesta en 5 segundos, cerramos el diálogo
          if (mounted) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              // Eliminamos esta línea para no marcar la casilla como presionada
              // pressButtons.add(index);
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
        } else {
          // Si ya recibimos respuesta, cerramos el diálogo
          if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop();
            setState(() {
              pressButtons.add(index);
              _isProcessing = false;
            });
          }
        }
      });
      // ...existing code...
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
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
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            bluetoothProvider.disconnect();
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
          margin: const EdgeInsets.symmetric(vertical: 114, horizontal: 16),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                    childAspectRatio: 1,
                  ),
                  itemCount: 16,
                  itemBuilder: (context, index) {
                    return GestureDetector(
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
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
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

                      // Activar bandera de procesamiento
                      setState(() {
                        _isProcessing = true;
                      });

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
                      Future.delayed(const Duration(milliseconds: 1500), () {
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
                          const SnackBar(
                            content: Text('¡Tablero reiniciado con éxito!'),
                            duration: Duration(seconds: 1),
                            backgroundColor: Colors.green,
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow,
                      shape: const CircleBorder(), // Forma circular
                      padding: const EdgeInsets.all(
                        20,
                      ), // Ajusta el tamaño del botón
                    ),
                    child: const Icon(
                      Icons.replay_rounded,
                      color: Colors.black,
                    ),
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

class DesconectDevice extends StatelessWidget {
  const DesconectDevice({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Dispositivo Bluetooth desconectado',
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      content: const Text(
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
          child: const Text(
            'Aceptar',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class ReloadBoard extends StatelessWidget {
  const ReloadBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.yellow, width: 2),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
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

class ProcessElement extends StatelessWidget {
  final int index;
  const ProcessElement({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.yellow, width: 2),
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

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.red, width: 2),
      ),
      title: const Text(
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
          const Icon(Icons.dangerous, color: Colors.red, size: 50),
          const SizedBox(height: 20),
          const Text(
            '¡Has encontrado una bomba!',
            style: TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Cierra el diálogo

              // Obtener el proveedor de Bluetooth para reiniciar el tablero
              final bluetoothProvider = Provider.of<BluetoothProvider>(
                context,
                listen: false,
              );

              // Enviar comando de reinicio al Arduino
              bluetoothProvider.sendData('reinicio');

              // Buscar el contexto de la pantalla principal y reiniciar el tablero
              final boardState =
                  context.findAncestorStateOfType<_BoardScreenState>();
              if (boardState != null) {
                boardState.setState(() {
                  boardState.pressButtons.clear();
                });
              }
            },
            child: const Text(
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
