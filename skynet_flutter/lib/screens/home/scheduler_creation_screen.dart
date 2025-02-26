import 'package:flutter/material.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:collection/collection.dart';

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
    if (selectedDevice != null && selectedRoom != null && selectedDeviceCategory != null) {
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
          // Add the device along with its category and room
          selectedDevices.add({
            'device': selectedDevice!,
            'room': selectedRoom!,
            'deviceCategory': selectedDeviceCategory!, // Ensure device category is added
          });
          selectedDevice = null; // Reset selected device after adding
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select both a device and a device category.'),
          backgroundColor: Colors.red, // Set the background color to red
        ),
      );
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
  Future<void> _saveScheduler() async{
    final dbService = DbService();

    // Print the scheduler data for debugging
    print('Scheduler Name: $schedulerName');
    print('Repetition Type: $repetitionType');
    if (repetitionType == 'Custom') {
      print('Custom Days: $customDays');
    }

    // Ensure that turnOnTime and turnOffTime are not null
    final turnOnTimeStr = turnOnTime != null ? '${turnOnTime?.hour}:${turnOnTime?.minute}' : '';
    final turnOffTimeStr = turnOffTime != null ? '${turnOffTime?.hour}:${turnOffTime?.minute}' : '';

    print('Turn On Time: $turnOnTimeStr');
    print('Turn Off Time: $turnOffTimeStr');

    // Display the data for all selected devices
    print('Selected Devices:');
    selectedDevices.forEach((device) {
      print('- Device: ${device['device']} (Room: ${device['room']})');
    });

    // Structure the data for saving
    final schedulerData = {
      'schedulerName': schedulerName,
      'repetitionType': repetitionType,
      'customDays': customDays,
      'turnOnTime': turnOnTimeStr,
      'turnOffTime': turnOffTimeStr,
      'rooms': groupBy(selectedDevices, (device) => device['room']).map((room, devices) {
        return MapEntry(room, devices.map((device) {
          print(device);
          return {
            'deviceCategory': device['deviceCategory'],  // This should no longer be null
            'device': device['device'],
          };
        }).toList());
      }),
    };
    print(schedulerData);
    // Call the DB service to save the scheduler data
     dbService.saveSchedulerData(schedulerData: schedulerData);

    // You can add any further logic or feedback for the user here (e.g., showing a confirmation message).
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a Schedule", style: TextStyle(color: Colors.white)),
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
                    onPressed: () async{
                      if (_formKey.currentState!.validate() && _validateTimes() == null && selectedDevices.isNotEmpty) {
                        _formKey.currentState!.save();
                        await _saveScheduler(); // Call the save function
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
