import 'package:flutter/material.dart';

List<Map<String, dynamic>> room_data_list = [
  {
    "name": "Living Room",
    "icon": Icons.tv, // Icon for the room
    "devices": [
      {"name": "TV", "status": false, "icon": Icons.tv, "bluetoothEnabled": true},
      {"name": "Lighting", "status": true, "icon": Icons.lightbulb, "bluetoothEnabled": true},
      {"name": "Air Conditioner", "status": false, "icon": Icons.ac_unit, "bluetoothEnabled": true},
      {"name": "Curtains", "status": false, "icon": Icons.window, "bluetoothEnabled": true},
      {"name": "Sound System", "status": true, "icon": Icons.speaker, "bluetoothEnabled": true},
    ],
  },
  {
    "name": "Bedroom",
    "icon": Icons.bed, // Icon for the room
    "devices": [
      {"name": "TV", "status": false, "icon": Icons.tv, "bluetoothEnabled": true},
      {"name": "Bedside Lamps", "status": true, "icon": Icons.light, "bluetoothEnabled": true},
      {"name": "Air Conditioner", "status": true, "icon": Icons.ac_unit, "bluetoothEnabled": true},
      {"name": "Smart Curtains", "status": false, "icon": Icons.window, "bluetoothEnabled": true},
      {"name": "Air Purifier", "status": false, "icon": Icons.air, "bluetoothEnabled": true},
    ],
  },
  {
    "name": "Kitchen",
    "icon": Icons.kitchen, // Icon for the room
    "devices": [
      {"name": "Smart Refrigerator", "status": true, "icon": Icons.kitchen, "bluetoothEnabled": true},
      {"name": "Oven", "status": false, "icon": Icons.microwave, "bluetoothEnabled": true},
      {"name": "Dishwasher", "status": false, "icon": Icons.wash, "bluetoothEnabled": true},
      {"name": "Exhaust Fan", "status": true, "icon": Icons.wind_power, "bluetoothEnabled": true},
      {"name": "Coffee Machine", "status": false, "icon": Icons.coffee, "bluetoothEnabled": true},
    ],
  },
  {
    "name": "Bathroom",
    "icon": Icons.bathtub, // Icon for the room
    "devices": [
      {"name": "Lighting", "status": true, "icon": Icons.lightbulb, "bluetoothEnabled": true},
      {"name": "Exhaust Fan", "status": true, "icon": Icons.wind_power, "bluetoothEnabled": true},
      {"name": "Water Heater", "status": false, "icon": Icons.hot_tub, "bluetoothEnabled": true},
      {"name": "Smart Mirror", "status": false, "icon": Icons.smart_display, "bluetoothEnabled": true},
    ],
  },
  {
    "name": "Garden",
    "icon": Icons.grass, // Icon for the room
    "devices": [
      {"name": "Gate", "status": false, "icon": Icons.door_sliding, "bluetoothEnabled": true},
      {"name": "Outdoor Lights", "status": true, "icon": Icons.lightbulb, "bluetoothEnabled": true},
      {"name": "Sprinkler System", "status": false, "icon": Icons.grass, "bluetoothEnabled": true},
      {"name": "Cameras", "status": true, "icon": Icons.camera_alt, "bluetoothEnabled": true},
    ],
  },
  {
    "name": "Other",
    "icon": Icons.devices, // Icon for other devices
    "devices": [
      {"name": "Smart Lock", "status": false, "icon": Icons.lock, "bluetoothEnabled": true},
      {"name": "Smart Thermostat", "status": true, "icon": Icons.thermostat, "bluetoothEnabled": true},
      {"name": "Security Camera", "status": true, "icon": Icons.camera_alt, "bluetoothEnabled": true},
      {"name": "Smart Light", "status": false, "icon": Icons.lightbulb, "bluetoothEnabled": true},
    ],
  }
];



Map<String, Map<String, List<Map<String, dynamic>>>> transformDataset() {
  Map<String, Map<String, List<Map<String, dynamic>>>> newDataset = {};

  // Iterate over the room data
  for (var room in room_data_list) {
    String roomName = room['name']; // Get the room name
    List<Map<String, dynamic>> devices = room['devices']; // Get devices for the room

    // Initialize an empty map to categorize devices
    Map<String, List<Map<String, dynamic>>> categorizedDevices = {};

    // Group devices by category (use device name as category)
    for (var device in devices) {
      String deviceName = device['name']; // Get the device name

      // Use the device name directly as the category
      String category = deviceName;

      // If category doesn't exist, initialize it
      if (!categorizedDevices.containsKey(category)) {
        categorizedDevices[category] = [];
      }

      // Add the device under the correct category
      // categorizedDevices[category]!.add({
      //   'name': device['name'],
      //   'status': device['status'],
      //   'icon': device['icon'],
      // });
    }

    // Add the room to the new dataset with categorized devices
    newDataset[roomName] = categorizedDevices;
  }

  return newDataset;
}
