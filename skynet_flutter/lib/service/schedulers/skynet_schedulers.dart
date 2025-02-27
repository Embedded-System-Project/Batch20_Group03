// import 'dart:async';
// import 'dart:developer';
// import 'package:skynet/service/bluetooth/bluetooth_handler.dart';
// import 'package:skynet/utils/firebase/db_service.dart';
// import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';
//
// class SchedulerService {
//   final DbService _dbService = DbService();
//   final BluetoothHandler _bluetoothHandler = BluetoothHandler();
//
//   Future<void> checkAndTriggerSchedulers() async {
//     final prefsService = SharedPreferencesService();
//     final userId = await prefsService.getUserId();
//
//     if (userId == null) {
//       log("User ID not found in SharedPreferences.");
//       return;
//     }
//
//     List<Map<String, dynamic>> schedulers = await _dbService.getUserSchedulers(userId);
//     DateTime now = DateTime.now();
//
//     for (var scheduler in schedulers) {
//       if (!scheduler['status']) continue; // Skip inactive schedules
//
//       DateTime scheduledTime = DateTime.parse(scheduler['time']);
//       if (now.isAfter(scheduledTime) && !_isAlreadyTriggered(scheduler['id'])) {
//         log("Triggering scheduler: ${scheduler['id']}");
//         _triggerDevice(scheduler);
//         _markAsTriggered(scheduler['id']);
//       }
//     }
//   }
//
//   void _triggerDevice(Map<String, dynamic> scheduler) async {
//     try {
//       String room = scheduler['room'];
//       String category = scheduler['category'];
//       String deviceName = scheduler['deviceName'];
//       bool status = scheduler['status'];
//       String timestamp = DateTime.now().toString();
//
//       await _dbService.updateDeviceStatus(room, category, deviceName, status, timestamp);
//       int socketId = await _dbService.getSocketId(room,category,deviceName) ?? 0;
//       _bluetoothHandler.sendData(deviceName);
//       log("Scheduler executed successfully for device: $deviceName");
//     } catch (e) {
//       log("Error executing scheduler: $e");
//     }
//   }
//
//   bool _isAlreadyTriggered(String schedulerId) {
//     // Implement logic to check if this scheduler has already been triggered recently
//     return false;
//   }
//
//   void _markAsTriggered(String schedulerId) {
//     // Implement logic to mark scheduler as triggered to avoid multiple executions
//   }
// }
