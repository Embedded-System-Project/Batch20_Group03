import 'dart:developer';

import 'package:skynet/data/room_data.dart';
import 'package:skynet/enum/db_collections.dart';
import 'package:skynet/utils/firebase/init_firebase.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class DbService {
  final _dbService = FirebaseService();

  saveSignUpData(String email, String name, String userId) {
    _dbService.create(
        DbCollections.users.key,
        {
          'name': name,
          'userId': userId,
          'email': email,
        },
        userId);
  }

  getUserName(String userId) async {
    final data = await _dbService.read(DbCollections.users.key, userId);
    final name = data["name"];
    return name;
  }

  createDefaultRooms(String userId) {
    final rooms = transformDataset();
    _dbService.create(DbCollections.rooms.key, rooms, userId);
    }


  Future<Map<String, dynamic>> getAvailableRooms() async {
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();

    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return {};
    }

    final data = await _dbService.read(DbCollections.rooms.key, userId);
    if (data == null) return {};

    // Remove the "id" key if it exists.
    data.remove("id");

    return data;
  }



  Future<List<Map<String, dynamic>>> getDeviceByCategory( String room, String category) async {

    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();

    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return [];
    }
  final data = await _dbService.read(DbCollections.rooms.key, userId);
  List<Map<String, dynamic>> devices = List.from(data[room][category]);
  return devices;
}

  Future<List<String>> getDeviceNamesByCategory(String room, String category) async {
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();

    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return [];
    }

    final data = await _dbService.read(DbCollections.rooms.key, userId);
    if (data == null || !data.containsKey(room) || !data[room].containsKey(category)) {
      log("Room or category not found.");
      return [];
    }

    List<Map<String, dynamic>> devices = List.from(data[room][category]);
    // Return a list of device names
    return devices.map((device) => device['name'] as String).toList();
  }


  Future<void> updateDeviceStatus(String roomName, String category, String deviceName, bool status, String timestamp) async {
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();

    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return;
    }

    final data = await _dbService.read(DbCollections.rooms.key, userId);
    if (data == null) return;

    // Locate the device and update its status
    if (data.containsKey(roomName) && data[roomName].containsKey(category)) {
      List<dynamic> devices = List.from(data[roomName][category]);

      for (var device in devices) {
        if (device['name'] == deviceName) {
          device['status'] = status; // Update the status of the device
          // Append status change with timestamp to stat list
          device['stat'].add({
            'timestamp': timestamp,
            'status': status,
          });
          break;
        }
      }

      // Save the updated data back to Firebase
      await _dbService.create(DbCollections.rooms.key, data, userId);
    }
  }




  Future<void> addNewDevice(String roomName, String deviceCategory, String deviceName, int socketId, { bool status = false, }) async {
    try {
      // Get the user ID from SharedPreferences
      final prefsService = SharedPreferencesService();
      final userId = await prefsService.getUserId();
      if (userId == null) {
        log("User ID not found in SharedPreferences.");
        return;
      }

      // Read the current room data from Firebase
      final data = await _dbService.read(DbCollections.rooms.key, userId);
      if (data == null) {
        log("No data found for user $userId");
        return;
      }

      // Check if the room exists in the dataset and the device category is present
      if (data.containsKey(roomName) && data[roomName].containsKey(deviceCategory)) {
        // Get the current list of devices for the given category in the room
        List<dynamic> currentDevices = List.from(data[roomName][deviceCategory]);

        // Create a new device data map
        Map<String, dynamic> newDevice = {
          'name': deviceName,
          'status': status,
          'socket': socketId,
          'stat': [
            {'timestamp': DateTime.now().toString(), 'status': status}
          ]
          // Add any other fields as needed (e.g., icon, bluetoothEnabled)
        };

        // Add the new device to the list
        currentDevices.add(newDevice);

        // Update the category in the room data with the new list of devices
        data[roomName][deviceCategory] = currentDevices;

        // Save the updated data back to Firebase.
        await _dbService.create(DbCollections.rooms.key, data, userId);

        log("Added device '$deviceName' to room '$roomName' under category '$deviceCategory'");
      } else {
        log("Room '$roomName' or category '$deviceCategory' not found.");
      }
    } catch (e) {
      log("Error adding device: $e");
    }
  }


  Future<List<int>> getAllSocketIds() async {
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();
    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return [];
    }

    final data = await _dbService.read(DbCollections.rooms.key, userId);
    if (data == null) return [];

    // Remove the "id" key if it exists.
    data.remove("id");

    List<int> socketIds = [];

    // Iterate over each room in the data.
    data.forEach((roomName, roomContent) {
      if (roomContent is Map) {
        // Iterate over each category in the room.
        roomContent.forEach((category, devices) {
          if (devices is List) {
            // Iterate over each device in the category.
            for (var device in devices) {
              if (device is Map && device.containsKey('socket')) {
                var socketValue = device['socket'];
                if (socketValue is int) {
                  socketIds.add(socketValue);
                }
              }
            }
          }
        });
      }
    });

    return socketIds;
  }


  Future<List<String>> getDeviceCategoriesByRoom(String room) async {
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();

    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return [];
    }

    // Read room data from the database
    final data = await _dbService.read(DbCollections.rooms.key, userId);
    if (data == null || !data.containsKey(room)) {
      log("Room '$room' not found in database.");
      return [];
    }

    // Fetch categories for the selected room
    final roomData = data[room];
    if (roomData is Map) {
      // Return the keys (categories) for the room, ensuring they're of type List<String>
      return List<String>.from(roomData.keys);
    }

    return [];
  }

  Future<void> saveSchedulerData({
    required String schedulerName,
    required String room,
    required String deviceCategory,
    required String? deviceName,
    required String repetitionType,
    required List<String> customDays,
    required String turnOnTime,
    required String turnOffTime,
    required List<String> selectedDevices,
  }) async {
    try {
      final prefsService = SharedPreferencesService();
      final userId = await prefsService.getUserId();
      if (userId == null) {
        log("User ID not found in SharedPreferences.");
        return;
      }

      // Prepare the data to be saved
      final schedulerData = {
        'schedulerName': schedulerName,
        'room': room,
        'deviceCategory': deviceCategory,
        'deviceName': deviceName,
        'repetitionType': repetitionType,
        'customDays': customDays,
        'turnOnTime': turnOnTime,
        'turnOffTime': turnOffTime,
        'selectedDevices': selectedDevices,
        'userId': userId, // You can add user ID here to link the scheduler to a user
      };

      // Save the scheduler data to the database
      await _dbService.create(DbCollections.schedulers.key, schedulerData, userId);

      log("Scheduler data saved successfully.");
    } catch (e) {
      log("Error saving scheduler data: $e");
    }
  }


}
