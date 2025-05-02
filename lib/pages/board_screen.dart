import 'dart:async';

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
  StreamSubscription? _dataSubscription;

  bool _isProcessing = false;

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

    _dataSubscription = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    ).dataReceivedStream.listen((data) {
      print(data);
      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" + data);
      // Actualizar UI con los datos recibidos
    });
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
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

      // Simular tiempo de procesamiento
      Future.delayed(const Duration(milliseconds: 1000), () {
        // Cerrar el diálogo de carga
        Navigator.of(context, rootNavigator: true).pop();

        setState(() {
          pressButtons.add(index);
          _isProcessing = false;
        });
      });
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
