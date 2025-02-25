import 'package:flutter/material.dart';
import 'package:skynet/utils/firebase/db_service.dart';

class SchedulerCreationScreen extends StatefulWidget {
  const SchedulerCreationScreen({super.key});

  @override
  _SchedulerCreationScreenState createState() =>
      _SchedulerCreationScreenState();
}

class _SchedulerCreationScreenState extends State<SchedulerCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  String schedulerName = '';
  String? selectedRoom;
  String? selectedDeviceCategory;
  String? selectedDevice;
  DateTime? turnOnTime;
  DateTime? turnOffTime;

  List<String> rooms = [];
  Map<String, List<String>> deviceCategoriesByRoom = {}; // Store categories by room
  List<String> deviceNames = []; // Store device names for the selected category

  // Repetition options
  String? repetitionType = 'None'; // Options: None, Daily, Weekly, Custom
  List<String> customDays = []; // Store custom days if Weekly/Custom repetition

  // List to store selected devices
  List<Map<String, String>> selectedDevices = [];

  @override
  void initState() {
    super.initState();
    _loadRoomsAndDeviceCategories();
  }

  // Fetch rooms and device categories from Firebase
  Future<void> _loadRoomsAndDeviceCategories() async {
    final dbService = DbService();
    final roomsData = await dbService.getAvailableRooms();
    setState(() {
      rooms = roomsData.keys.toList();
    });
  }

  // Fetch device categories based on selected room
  Future<void> _loadDeviceCategoriesForRoom(String room) async {
    final dbService = DbService();
    final deviceCategories = await dbService.getDeviceCategoriesByRoom(room); // Fetch categories for the selected room
    setState(() {
      deviceCategoriesByRoom[room] = deviceCategories; // Store categories for selected room
      selectedDeviceCategory = null;  // Reset device category when room changes
      selectedDevice = null;  // Reset selected device when category changes
      deviceNames = [];  // Reset device names when room changes
    });
  }

  // Fetch device names for a specific category in a room
  Future<void> _loadDevicesForCategory(String room, String category) async {
    final dbService = DbService();
    final deviceNames = await dbService.getDeviceNamesByCategory(room, category); // Fetch device names
    setState(() {
      this.deviceNames = deviceNames; // Store the device names
      selectedDevice = null; // Reset selected device when category changes
    });
  }

  // Add selected device to the list
  void _addDevice() {
    if (selectedDevice != null && selectedRoom != null) {
      // Check if the device is already in the selectedDevices list
      bool isDeviceAdded = selectedDevices.any((device) => device['device'] == selectedDevice && device['room'] == selectedRoom);

      if (isDeviceAdded) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Device is already added to this room!'),
            backgroundColor: Colors.red, // Set the background color to red
          ),
        );
      } else {
        setState(() {
          selectedDevices.add({
            'device': selectedDevice!,
            'room': selectedRoom!,
          });
          selectedDevice = null; // Reset selected device after adding
        });
      }
    }
  }

  // Remove device from the list
  void _removeDevice(int index) {
    setState(() {
      selectedDevices.removeAt(index);
    });
  }

  // Validate times
  String? _validateTimes() {
    if (turnOnTime == null) {
      return 'Turn-on time is required';
    }
    if (turnOffTime == null) {
      return 'Turn-off time is required';
    }
    if (turnOffTime!.isBefore(turnOnTime!)) {
      return 'Turn-off time must be after turn-on time';
    }
    return null;
  }

  // Function to save the scheduler
  void _saveScheduler() {
    final dbService = DbService();

    // to be implement  ******************************

    print('Scheduler Name: $schedulerName');
    print('Selected Room: $selectedRoom');
    print('Selected Device Category: $selectedDeviceCategory');
    print('Selected Device: $selectedDevice');
    print('Repetition Type: $repetitionType');
    if (repetitionType == 'Custom') {
      print('Custom Days: $customDays');
    }
    print('Turn On Time: ${turnOnTime?.hour}:${turnOnTime?.minute}');
    print('Turn Off Time: ${turnOffTime?.hour}:${turnOffTime?.minute}');

    print('Selected Devices:');
    for (var device in selectedDevices) {
      print('- Device: ${device['device']} (Room: ${device['room']})');
    }

    // You can save or send the data to a database here.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Scheduler", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: true,
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scheduler name input
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Scheduler Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name for the scheduler';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    schedulerName = value ?? '';
                  },
                ),

                // Room selection (optional)
                DropdownButtonFormField<String>(
                  value: selectedRoom,
                  decoration: const InputDecoration(labelText: 'Select Room'),
                  items: rooms.map((room) {
                    return DropdownMenuItem<String>(value: room, child: Text(room));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedRoom = value;
                      selectedDeviceCategory = null; // Reset device category when room changes
                      selectedDevice = null;         // Reset selected device when room changes
                      deviceNames = [];  // Reset device names when room changes
                    });
                    if (value != null) {
                      _loadDeviceCategoriesForRoom(value); // Load device categories for selected room
                    }
                  },
                ),

                // Device Category selection (optional)
                if (selectedRoom != null && deviceCategoriesByRoom[selectedRoom] != null)
                  DropdownButtonFormField<String>(
                    value: selectedDeviceCategory,
                    decoration: const InputDecoration(labelText: 'Select Device Category'),
                    items: deviceCategoriesByRoom[selectedRoom]!.map((category) {
                      return DropdownMenuItem<String>(value: category, child: Text(category));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDeviceCategory = value;
                        selectedDevice = null;  // Reset selected device when category changes
                        deviceNames = [];       // Reset device names when category changes
                      });
                      if (value != null && selectedRoom != null) {
                        _loadDevicesForCategory(selectedRoom!, value); // Load devices for selected category
                      }
                    },
                  ),

                // Product name selection (optional)
                if (deviceNames.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedDevice,
                    decoration: const InputDecoration(labelText: 'Select Product Name'),
                    items: deviceNames.map((device) {
                      return DropdownMenuItem<String>(value: device, child: Text(device));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedDevice = value;
                      });
                    },
                  ),

                // Add device button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: _addDevice,
                    child: const Text('Add Device'),
                  ),
                ),

                // Repetition selection
                DropdownButtonFormField<String>(
                  value: repetitionType,
                  decoration: const InputDecoration(labelText: 'Repetition Type'),
                  items: const [
                    DropdownMenuItem(value: 'None', child: Text('None')),
                    DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                    DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      repetitionType = value;
                      customDays = [];  // Reset custom days when repetition changes
                    });
                  },
                ),

                // Custom days selection (only when "Custom" is selected)
                if (repetitionType == 'Custom')
                  Wrap(
                    children: List.generate(7, (index) {
                      final day = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][index];
                      return ChoiceChip(
                        label: Text(day),
                        selected: customDays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              customDays.add(day);
                            } else {
                              customDays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),

                // Turn on time picker
                ListTile(
                  title: const Text('Set Turn On Time'),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(turnOnTime ?? DateTime.now()),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          turnOnTime = DateTime.now().copyWith(
                            hour: selectedTime.hour,
                            minute: selectedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                ),
                if (turnOnTime != null)
                  Text('Selected Turn On Time: ${turnOnTime!.hour}:${turnOnTime!.minute}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                // Turn off time picker
                ListTile(
                  title: const Text('Set Turn Off Time'),
                  trailing: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: () async {
                      final selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(turnOffTime ?? DateTime.now().add(const Duration(hours: 1))),
                      );
                      if (selectedTime != null) {
                        setState(() {
                          turnOffTime = DateTime.now().copyWith(
                            hour: selectedTime.hour,
                            minute: selectedTime.minute,
                          );
                        });
                      }
                    },
                  ),
                ),
                if (turnOffTime != null)
                  Text('Selected Turn Off Time: ${turnOffTime!.hour}:${turnOffTime!.minute}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                // Device list display
                if (selectedDevices.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Selected Devices:', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...selectedDevices.map((device) {
                        return ListTile(
                          title: Text('${device['device']} (Room: ${device['room']})'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeDevice(selectedDevices.indexOf(device)),
                          ),
                        );
                      }).toList(),
                    ],
                  ),

                // Save button
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate() && _validateTimes() == null && selectedDevices.isNotEmpty) {
                        _formKey.currentState!.save();
                        _saveScheduler(); // Call the save function
                      } else {
                        if (selectedDevices.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please add at least one device'),
                              backgroundColor: Colors.red, // Set the background color to red
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Save Scheduler'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
