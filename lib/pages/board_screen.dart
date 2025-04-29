import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  // Set para guardar las posiciones de los botones presionados
  final Set<int> pressButtons = {};

  // Método para manejar cuando se presiona una tarjeta

  // Método para simular desconexión Bluetooth
  void desconectConection() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Dispositivo Bluetooth desconectado',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: const Text(
              'Se ha perdido la conexión con el dispositivo Bluetooth.',
              style: TextStyle(color: Colors.black),
            ),
            backgroundColor: Colors.yellow,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el diálogo
                  Navigator.pop(context); // Regresa a la pantalla anterior
                },
                child: const Text(
                  'Aceptar',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  void initState() {
    super.initState();

    final bluetoothProvider = Provider.of<BluetoothProvider>(
      context,
      listen: false,
    );
    bluetoothProvider.connectionStateStream.listen((isConnected) {
      if (!isConnected) {
        desconectConection(); // Mostrar diálogo de desconexión
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    void pressTarget(int index) {
      final bluetoothProvider = Provider.of<BluetoothProvider>(
        context,
        listen: false,
      );

      setState(() {
        // Si ya estaba presionado, lo quitamos del set, sino lo agregamos
        if (!pressButtons.contains(index)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Tarjeta en posición: Fila ${index ~/ 3}, Columna ${index % 3}',
              ),
              duration: const Duration(seconds: 1),
              backgroundColor: Colors.yellow,
            ),
          );
          pressButtons.add(index);
          bluetoothProvider.sendData('${index}${index}');
        }
        //pressButtons.remove(index);
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
          onPressed: () => Navigator.pop(context),
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
            ],
          ),
        ),
      ),
    );
  }
}
