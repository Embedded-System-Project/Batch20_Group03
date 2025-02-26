import 'package:flutter/material.dart';
import 'package:skynet/data/room_data.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/service/bluetooth/bluetooth_handler.dart';
import 'package:skynet/widgets/device_card.dart';
import 'package:skynet/widgets/room_section.dart';
import '../../../utils/firebase/db_service.dart';
import '../../../utils/shared_preferences/shared_preferences_service.dart';

class AddFragment extends StatefulWidget {
  @override
  _AddFragmentState createState() => _AddFragmentState();
}

class _AddFragmentState extends State<AddFragment> {
  late List<Map<String, dynamic>> _roomDataList;
  int _selectedRoomIndex = 0;
  String _selectedDevice = "";
  bool _isDeviceSelected = false;
  late List<Map<String, dynamic>> _socketBoxes;
  bool _testConnection = false; // Track the switch state
  int? _selectedSocketIndex; // Track the selected socket index
  TextEditingController _deviceNameController = TextEditingController();

  final DbService _dbService = DbService();

  @override
  void initState() {
    super.initState();
    _roomDataList = List.from(room_data_list);
    _socketBoxes = List.generate(8, (index) {
      return {
        "id": index,
        "status": 0, // For example, index 3 is blocked (status 2)
      };
    });
    // After generating the socket boxes, fetch the selected socket IDs from Firebase
    _fetchSelectedSockets();
  }

  Future<void> _fetchSelectedSockets() async {
    // Get user ID from SharedPreferences
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      return;
    }
    // Call your function that returns the list of socket IDs from Firebase
    List<int> selectedSocketIds = await _dbService.getAllSocketIds();
    // Update _socketBoxes based on the fetched IDs.
    // Here, if a socket's id is in the list, mark its status as 1.
    setState(() {
      for (var i = 0; i < _socketBoxes.length; i++) {
        if (selectedSocketIds.contains(_socketBoxes[i]["id"])) {
          _socketBoxes[i]["status"] = 2;
          // Optionally, set _selectedSocketIndex to the first found socket.
          _selectedSocketIndex ??= _socketBoxes[i]["id"];
        }
      }
    });
  }

  void _onDeviceSelected(String room, Map<String, dynamic> device) {
    String deviceType = device['name'] ?? 'Unknown';
    setState(() {
      _selectedDevice = "$room - $deviceType";
      _isDeviceSelected = true;
    });
  }

  Widget socketSelector() {
    Color getColor(int status) {
      if (status == 2) return Colors.grey;
      return status == 1 ? Colors.blueAccent : Colors.blueAccent.withOpacity(0.2);
    }

    void toggleSelection(int index) {
      // Do not allow selecting a socket that is blocked (status 2)
      if (_socketBoxes[index]["status"] == 2) return;
      setState(() {
        // Clear any previous selection (if single selection is desired)
        for (var box in _socketBoxes) {
          if (box["status"] == 1) box["status"] = 0;
        }
        _socketBoxes[index]["status"] = 1;
        _selectedSocketIndex = index;
      });
    }

    return _isDeviceSelected
        ? Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Select the socket",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: _socketBoxes.length,
            itemBuilder: (context, index) {
              int status = _socketBoxes[index]["status"];
              return GestureDetector(
                onTap: () => toggleSelection(index),
                child: Container(
                  decoration: BoxDecoration(
                    color: getColor(status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Socket: ${_socketBoxes[index]['id'] + 1}",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    )
        : SizedBox.shrink();
  }

  void _onTickTapped() {
    print("Device selected: $_selectedDevice");
  }

  Future<void> _onSaveButtonPressed() async {
    // Validate that the device name is not empty.
    if (_deviceNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device name cannot be empty'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Get room name from the selected room
    String roomName = _roomDataList[_selectedRoomIndex]['name'];

    // Derive device category from _selectedDevice if available; otherwise, default to "Other"
    String deviceCategory = "Other";
    if (_selectedDevice.isNotEmpty && _selectedDevice.contains(' - ')) {
      List<String> parts = _selectedDevice.split(' - ');
      if (parts.length > 1) {
        deviceCategory = parts[1];
      }
    }

    String deviceName = _deviceNameController.text;
    int socketId = _selectedSocketIndex != null ? _selectedSocketIndex! : -1;

    // Get user ID from SharedPreferences
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      print("User ID not found in SharedPreferences.");
      return;
    }

    // Save the new device to Firebase using your DbService.
    // Note: adjust addNewDevice signature as needed to include socketId.
    await _dbService.addNewDevice(roomName, deviceCategory, deviceName, socketId);


    final data = {
      "action":"ctrl",
      "socket":socketId,
      "user": userId,
      "status": 0
    };

    await BluetoothHandler().sendData(data);
    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device saved successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    // Reset the state after saving
    setState(() {
      _selectedDevice = "";
      _isDeviceSelected = false;
      _selectedRoomIndex = 0;
      _selectedSocketIndex = null;
      _testConnection = false;
      _deviceNameController.clear();
      // Reset all socket statuses
      _socketBoxes = List.generate(8, (index) => {"id": index, "status": index == 3 ? 2 : 0});
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
    print("Device saved and state reset.");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Device", style: TextStyle(color: Colors.white)),
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RoomSection(
                selectedIndex: _selectedRoomIndex,
                onRoomSelected: (index) {
                  setState(() {
                    _selectedRoomIndex = index;
                    _selectedDevice = "";
                    _isDeviceSelected = false;
                    _selectedSocketIndex = null;

                    // Reset socket statuses (except for blocked ones)
                    _socketBoxes = List.generate(8, (i) => {"id": i, "status": 0});
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _deviceNameController,
                decoration: InputDecoration(
                  labelText: 'Enter Device Name',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                style: TextStyle(fontSize: 16),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: _roomDataList[_selectedRoomIndex]['devices'].length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final device = _roomDataList[_selectedRoomIndex]['devices'][index];
                  return GestureDetector(
                    onTap: () => _onDeviceSelected(
                      _roomDataList[_selectedRoomIndex]['name'],
                      device,
                    ),
                    child: DeviceCard(
                      key: ValueKey(_roomDataList[_selectedRoomIndex]['name'] +
                          " - " +
                          device["name"]),
                      isSelected: _selectedDevice ==
                          (_roomDataList[_selectedRoomIndex]['name'] + " - " + device["name"]),
                      room: _roomDataList[_selectedRoomIndex]['name'],
                      device: device,
                    ),
                  );
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
            socketSelector(),
            if (_selectedSocketIndex != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Test Connection switch and label in a left-aligned Column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Switch(
                              value: _testConnection,
                              onChanged: (bool value) {
                                setState(() {
                                  _testConnection = value;
                                });
                              },
                              activeColor: Colors.blueAccent,
                              inactiveTrackColor: Colors.blueAccent.withOpacity(0.2),
                            ),
                            Text("Test Connection", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                    // Save button on the right side
                    ElevatedButton(
                      onPressed: _onSaveButtonPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text("Save", style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
