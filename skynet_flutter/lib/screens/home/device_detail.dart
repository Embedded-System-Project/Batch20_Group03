import 'package:flutter/material.dart';
import 'package:skynet/service/bluetooth/bluetooth_handler.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final String roomName;
  final String deviceType;

  const DeviceDetailScreen({
    super.key,
    required this.roomName,
    required this.deviceType,
  });

  @override
  _DeviceDetailScreenState createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen> {
  late Future<List<Map<String, dynamic>>> _deviceList;

  @override
  void initState() {
    super.initState();
    _deviceList = _fetchDevices();
  }

  Future<List<Map<String, dynamic>>> _fetchDevices() async {
    final dbService = DbService();
    try {
      final devices = await dbService.getDeviceByCategory(widget.roomName, widget.deviceType);
      return devices ?? [];
    } catch (e) {
      print("Error occurred while fetching devices: $e");
      return [];
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.roomName, style: const TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification icon press
            },
          ),
        ],
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _deviceList,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Failed to load devices: ${snapshot.error}"));
            }

            final devices = snapshot.data ?? [];

            if (devices.isEmpty) {
              return const Center(child: Text("No devices available"));
            }

            return Column(
              children: [
                // ListView of devices
                Expanded(
                  child: ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      final device = devices[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          title: Text(device['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("Current Status: ${device['status'] ? 'On' : 'Off'}"),
                          trailing: Switch(
                            value: device['status'] ?? false,
                            onChanged: (bool value) {
                              setState(() {
                                device['status'] = value;
                              });
                              _updateDeviceStatus(device, value);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Function to update device status in the database
  void _updateDeviceStatus(Map<String, dynamic> device, bool status) async {
    final dbService = DbService();
    final roomName = widget.roomName;
    final deviceCategory = widget.deviceType;

    // Updating the device status and appending the timestamp
    await dbService.updateDeviceStatus(roomName, deviceCategory, device['name'], status, DateTime.now().toIso8601String());
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      return;
    }
    print("socket${device["socket"]}");
    final data = {
      "action":"ctrl",
      "socket":device['socket']+1,
      "user": userId,
      "status": status?1:0
    };

    BluetoothHandler().sendData(data);
    // Optionally, show a Snackbar or other feedback to the user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device status updated to: ${status ? 'On' : 'Off'}')),
    );
  }
}
