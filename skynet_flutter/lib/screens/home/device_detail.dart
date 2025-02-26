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
  bool _isSnackBarVisible = false;

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
                          // contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          contentPadding: const EdgeInsets.only(left: 20, right: 0, top: 10, bottom: 10),
                          title: Text(device['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text("Current Status: ${device['status'] ? 'On' : 'Off'}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Switch to toggle device status
                              Switch(
                                value: device['status'] ?? false,
                                onChanged: BluetoothHandler().isConnected
                                    ? (bool value) {
                                  setState(() {
                                    device['status'] = value;
                                  });
                                  _updateDeviceStatus(device, value);
                                }
                                    : (value) {
                                  _showErrorSnackBar('Bluetooth is not connected. Please connect the device first.');
                                },
                              ),
                              // Popup Menu Button for Edit and Delete options, moved to the right side
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (String value) {
                                  if (value == 'edit') {
                                    // Handle Edit option
                                    _showEditDialog(device);
                                  } else if (value == 'delete') {
                                    // Handle Delete option
                                    _showDeleteConfirmationDialog(device);
                                  }
                                },
                                itemBuilder: (BuildContext context) {
                                  return [
                                    const PopupMenuItem<String>(
                                      value: 'edit',
                                      child: Text('Edit'),
                                    ),
                                    const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ];
                                },
                              ),
                            ],
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

  // Show Snackbar for Bluetooth error
  void _showErrorSnackBar(String message) {
    if (_isSnackBarVisible) return;
    _isSnackBarVisible = true;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );

    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isSnackBarVisible = false;
      });
    });
  }

  // Function to update device status in the database
  void _updateDeviceStatus(Map<String, dynamic> device, bool status) async {
    final dbService = DbService();
    final roomName = widget.roomName;
    final deviceCategory = widget.deviceType;

    await dbService.updateDeviceStatus(roomName, deviceCategory, device['name'], status, DateTime.now().toIso8601String());
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      return;
    }
    int socketID = device['socket'] + 1;
    final data = {
      "action": "ctrl",
      "socket": socketID,
      "user": userId,
      "status": status ? 1 : 0
    };
    BluetoothHandler().sendData(data);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device status updated to: ${status ? 'On' : 'Off'}')),
    );
  }

  // Show Edit dialog (You can expand this with actual edit functionality)
  void _showEditDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Device"),
          content: const Text("Edit the device details here."),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                // Implement edit functionality here
                Navigator.of(context).pop(); // Close the dialog after editing
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // Show delete confirmation dialog
  void _showDeleteConfirmationDialog(Map<String, dynamic> device) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Device"),
          content: const Text("Are you sure you want to delete this device?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteDevice(device);
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _deleteDevice(Map<String, dynamic> device) async {
    final dbService = DbService();
    final roomName = widget.roomName;
    final deviceCategory = widget.deviceType;

    // Delete the device from the database
    await dbService.deleteDevice(roomName, deviceCategory, device['name']);

    // Send Bluetooth message with status 0 (to indicate the device is off)
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      return;
    }
    int socketID = device['socket'] + 1; // Adjust socketID based on your logic
    final data = {
      "action": "ctrl",
      "socket": socketID,
      "user": userId,
      "status": 0, // Setting status to 0 to indicate "Off"
    };

    await BluetoothHandler().sendData(data);

    // Refresh the device list after deletion
    setState(() {
      _deviceList = _fetchDevices(); // Fetch updated list after deletion
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Device "${device['name']}" deleted successfully.')),
    );
  }

}
