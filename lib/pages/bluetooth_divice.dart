import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:provider/provider.dart';
import 'package:proyect_orga/Provider/bluetooth_provider.dart';

class BluetoothDeviceList extends StatelessWidget {
  const BluetoothDeviceList({super.key});

  @override
  Widget build(BuildContext context) {
    final divicesList = Provider.of<BluetoothProvider>(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            "Dispositivos Bluetooth",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        Expanded(
          child:
              divicesList.devices.isEmpty
                  ? _buildEmptyState(divicesList.getBondedDevices)
                  : _buildDeviceList(context),
        ),
      ],
    );
  }

  Widget _buildEmptyState(void Function() searchDevices) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bluetooth_searching, size: 64, color: Color(0xFFFFD700)),
          SizedBox(height: 16),
          TextButton(
            onPressed: searchDevices,
            child: Text(
              "Buscar dispositivos",
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList(BuildContext context) {
    final devices = Provider.of<BluetoothProvider>(context).devices;
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: Duration(milliseconds: 300 + (index * 100)),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: DeviceItem(device: device),
        );
      },
    );
  }
}

class DeviceItem extends StatelessWidget {
  final BluetoothDevice device;

  const DeviceItem({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final bool isConnected = device.isConnected;

    return InkWell(
      onTap: () async => Navigator.pop(context, device),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isConnected ? Color(0xFFFFD700) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isConnected ? Icons.bluetooth_connected : Icons.bluetooth,
                    color: isConnected ? Colors.black : Colors.grey.shade700,
                    size: 28,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name ?? 'Dispositivo desconocido',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color:
                            device.isConnected
                                ? Colors.yellow.shade700
                                : Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      device.address,
                      style: TextStyle(
                        color:
                            device.isConnected ? Colors.black : Colors.black38,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 300),
                child:
                    isConnected
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Conectado',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        )
                        : Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
