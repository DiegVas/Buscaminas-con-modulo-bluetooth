import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothProvider extends ChangeNotifier {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  bool _bluetoothState = false; // Estado del Bluetooth
  bool _isConnected = false; // Estado de la conexión Bluetooth
  BluetoothConnection? _connection; // Conexión Bluetooth
  List<BluetoothDevice> _devices = []; // Lista de dispositivos Bluetooth
  BluetoothDevice? _selectedDevice; // Dispositivo seleccionado

  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  bool get bluetoothState => _bluetoothState;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;

  final StreamController<String> _dataReceivedController =
      StreamController<String>.broadcast();
  Stream<String> get dataReceivedStream => _dataReceivedController.stream;
  String _lastReceivedData = '';
  String get lastReceivedData => _lastReceivedData;

  void setSelectedDevice(BluetoothDevice device) {
    _selectedDevice = device;
    notifyListeners();
  }

  BluetoothProvider() {
    _initializeBluetooth();
  }

  set bluetoothState(bool value) {
    _bluetoothState = value;
    if (value) connectBluetooth();
    notifyListeners();
  }

  void connectBluetooth() async {
    await _bluetooth.requestEnable();
    notifyListeners();
  }

  void _initializeBluetooth() async {
    await _requestPermissions();
    _bluetooth.state.then((state) {
      _bluetoothState = state.isEnabled;
      notifyListeners();
    });
    _bluetooth.onStateChanged().listen((state) {
      _bluetoothState = state == BluetoothState.STATE_ON;
      notifyListeners();
    });
  }

  Future<void> _requestPermissions() async {
    await Permission.location.request();
    await Permission.bluetooth.request();
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.bluetoothAdvertise.request();
    await Permission.bluetoothScan.request();
  }

  Future<void> getBondedDevices() async {
    try {
      _devices = await _bluetooth.getBondedDevices();
      notifyListeners();
    } catch (e) {
      debugPrint("Error al obtener dispositivos emparejados: $e");
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      _connection = await BluetoothConnection.toAddress(device.address);
      _isConnected = true;
      _selectedDevice = device;
      _connectionStateController.add(true); // Emitir evento de conexión
      notifyListeners();

      print("Conectado a: ${device.name}");

      // Y modificar la parte de escucha:
      _connection?.input?.listen(
        (data) {
          final receivedData = String.fromCharCodes(data);
          _lastReceivedData = receivedData;
          _dataReceivedController.add(
            receivedData,
          ); // Emitir datos a los widgets
          debugPrint("Datos recibidos: $receivedData");
          print("Conectado a: ${device.name}");
          print("Datos recibidos: $receivedData");
        },
        onDone: () {
          _isConnected = false;
          _connectionStateController.add(false); // Emitir evento de desconexión
          notifyListeners();
        },
        onError: (error) {
          debugPrint("Error en la conexión: $error");
          disconnect();
          throw error; // Propagar el error
        },
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint("Error al conectar al dispositivo: $e");
      // Importante: propagar la excepción para que pueda ser manejada
      // por el código que llamó a este método
      throw e;
    }
  }

  void disconnect() {
    if (_connection != null) {
      try {
        _connection?.close();
      } catch (e) {
        debugPrint("Error al desconectar: $e");
      }
      _connection = null;
      _isConnected = false;
      _selectedDevice = null;
      _connectionStateController.add(false); // Emitir evento de desconexión
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _connectionStateController.close();
    super.dispose();
  }

  void sendData(String data) {
    if (_connection?.isConnected ?? false) {
      //print("Conectado a: ${_selectedDevice?.name}");
      _connection?.output.add(ascii.encode(data));
    }
  }

  Future<void> connectWithRetry(
    BluetoothDevice device, {
    int maxRetries = 3,
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        attempts++;
        await connectToDevice(device);
        return; // Conexión exitosa, salir del método
      } catch (e) {
        debugPrint("Intento $attempts fallido: $e");

        if (attempts >= maxRetries) {
          // Si se alcanzó el número máximo de intentos, propagar el error
          throw Exception(
            "No se pudo conectar después de $maxRetries intentos: $e",
          );
        }

        // Esperar antes de reintentar
        await Future.delayed(Duration(seconds: 2));
      }
    }
  }
}
