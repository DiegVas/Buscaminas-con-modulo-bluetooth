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
  List<BluetoothDevice> _devices = [
    BluetoothDevice(
      name: "Dispositivo 1",
      address: "00:11:22:33:44:55",
      isConnected: true,
    ),
    BluetoothDevice(name: "Dispositivo 2", address: "66:77:88:99:AA:BB"),
    BluetoothDevice(name: "Dispositivo 3", address: "CC:DD:EE:FF:00:11"),
  ]; // Lista de dispositivos Bluetooth
  BluetoothDevice? _selectedDevice; // Dispositivo seleccionado

  final StreamController<bool> _connectionStateController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStateStream => _connectionStateController.stream;

  bool get bluetoothState => _bluetoothState;
  bool get isConnected => _isConnected;
  List<BluetoothDevice> get devices => _devices;
  BluetoothDevice? get selectedDevice => _selectedDevice;

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

      // Escuchar el estado de la conexión
      _connection?.input?.listen(null).onDone(() {
        _isConnected = false;
        _selectedDevice = null;
        _connectionStateController.add(false); // Emitir evento de desconexión
        notifyListeners();
      });
    } catch (e) {
      debugPrint("Error al conectar al dispositivo: $e");
    }
  }

  void disconnect() {
    if (_connection != null) {
      _connection?.close();
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
      _connection?.output.add(ascii.encode(data));
    }
  }

  void receiveData() {
    _connection?.input?.listen((event) {
      final receivedData = String.fromCharCodes(event);
      debugPrint("Datos recibidos: $receivedData");
      // Aquí puedes manejar los datos recibidos
    });
  }
}
