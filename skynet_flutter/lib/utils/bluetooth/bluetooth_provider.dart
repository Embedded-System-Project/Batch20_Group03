import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:bluetooth_classic/models/device.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothProvider {
  // Singleton instance
  static final BluetoothProvider _instance =
      BluetoothProvider._privateConstructor();

  // Private constructor
  BluetoothProvider._privateConstructor() {
    _initialize();
  }

  factory BluetoothProvider() => _instance;

  final BluetoothClassic _bluetoothClassicPlugin = BluetoothClassic();

  String _platformVersion = 'Unknown';
  List<Device> _pairedDevices = [];
  List<Device> _discoveredDevices = [];
  bool _isScanning = false;
  int _deviceStatus = Device.disconnected;
  // Uint8List _receivedData = Uint8List(0);

  // Stream controllers for events
  final StreamController<int> _deviceStatusController =
      StreamController<int>.broadcast();
  final StreamController<Device> _deviceDiscoveryController =
      StreamController<Device>.broadcast();
  // final StreamController<Uint8List> _dataReceivedController =
  //     StreamController<Uint8List>.broadcast();

  // Stream subscription for device discovery
  StreamSubscription<Device>? _deviceDiscoverySubscription;

  Stream<int> get deviceStatusStream => _deviceStatusController.stream;
  Stream<Device> get deviceDiscoveryStream => _deviceDiscoveryController.stream;
  // Stream<Uint8List> get dataReceivedStream => _dataReceivedController.stream;

  bool _isRequestingPermissions = false;

  void _initialize() {
    _bluetoothClassicPlugin.onDeviceStatusChanged().listen((status) {
      _deviceStatus = status;
      _deviceStatusController.add(status);
    });

    // _bluetoothClassicPlugin.onDeviceDataReceived().listen((data) {
    //   _receivedData = Uint8List.fromList([..._receivedData, ...data]);
    //   _dataReceivedController.add(data);
    // });
  }

  Future<void> checkAndEnableBluetooth() async {
    await checkBluetoothPermissions();
    log("Bluetooth is enabled and permissions are granted.");
  }

  Future<void> checkBluetoothPermissions() async {
    if (_isRequestingPermissions) {
      log("Permission request already in progress. Please wait.");
      while (_isRequestingPermissions) {
        await Future.delayed(Duration(milliseconds: 100));
      }
      return;
    }

    try {
      _isRequestingPermissions = true;

      Map<Permission, PermissionStatus> statuses = await [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ].request();

      if (statuses.values.any((status) => status.isDenied)) {
        throw Exception(
            "Some permissions are denied. Please grant Bluetooth and location permissions.");
      }

      if (statuses.values.any((status) => status.isPermanentlyDenied)) {
        throw Exception(
            "Bluetooth permissions are permanently denied. Please enable them in app settings.");
      }

      await _bluetoothClassicPlugin.initPermissions();
      log("Bluetooth permissions are granted.");
    } catch (e) {
      log("Failed to request permissions: $e");
      throw Exception("Failed to request Bluetooth permissions.");
    } finally {
      _isRequestingPermissions = false;
    }
  }

  Future<bool> isBluetoothEnabled() async {
    bool isEnabled = await _bluetoothClassicPlugin.initPermissions();
    log("Bluetooth is ${isEnabled ? 'enabled' : 'disabled'}.");
    return isEnabled;
  }

  Future<String> getPlatformVersion() async {
    try {
      _platformVersion =
          await _bluetoothClassicPlugin.getPlatformVersion() ?? 'Unknown';
    } catch (e) {
      log("Failed to get platform version: $e");
      _platformVersion = 'Failed to get platform version';
    }
    return _platformVersion;
  }

  Future<List<Device>> getPairedDevices() async {
    try {
      await checkBluetoothPermissions();
      _pairedDevices = await _bluetoothClassicPlugin.getPairedDevices();
    } catch (e) {
      log("Failed to get paired devices: $e");
      throw Exception("Failed to fetch paired devices.");
    }
    return _pairedDevices;
  }

  Future<void> startScanningWithListner() async {
    log("Is scanning: $_isScanning");
    if (_isScanning) return;

    _isScanning = true;

    try {
      await checkBluetoothPermissions();

      if (_deviceDiscoverySubscription != null) {
        await _deviceDiscoverySubscription!.cancel();
        _deviceDiscoverySubscription = null;
      }

      await _bluetoothClassicPlugin.startScan();
      log("Bluetooth scanning started...");

      _deviceDiscoverySubscription =
          _bluetoothClassicPlugin.onDeviceDiscovered().listen(
        (device) {
          log("Device discovered: ${device.name}, ${device.address}");
          if (!_discoveredDevices.contains(device)) {
            _discoveredDevices.add(device);
            _deviceDiscoveryController.add(device);
          }
        },
        onError: (error) {
          log("Error during device discovery: $error");
        },
      );
    } catch (e) {
      log("Error while scanning: $e");
      throw Exception("Error while scanning for devices.");
    }
  }

Future<void> startScanning() async {
  log("Scanning for new devices...");

  // If a listener already exists, just start the scan
  if (_deviceDiscoverySubscription == null) {
    // First-time scan: create a new stream and listener
    try {
      await startScanningWithListner();
      log("Bluetooth scan started to discover new devices.");
    } catch (e) {
      log("Error while scanning for new devices: $e");
      throw Exception("Failed to start scanning for new devices.");
    }
  } else {
    // Stream already exists, just start scanning again
    log("Already scanning for devices, restarting scan...");
    try {
      _discoveredDevices.clear();
      await _bluetoothClassicPlugin.startScan();
      log("Bluetooth scanning started.");
    } catch (e) {
      log("Error restarting scan: $e");
      throw Exception("Failed to restart scanning for devices.");
    }
  }
}


  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      log("Stopping Bluetooth scan...");
      await _bluetoothClassicPlugin.stopScan();
      _isScanning = false;
      log("Bluetooth scan stopped.");

      // await _deviceDiscoverySubscription!.cancel();
      // _deviceDiscoverySubscription = null;
    } catch (e) {
      log("Error while stopping scan: $e");
      throw Exception("Error while stopping scan.");
    }
  }

  Future<void> connectToDevice(String address, String uuid) async {
    log("Connecting to device: Address: $address, UUID: $uuid");
    try {
      await checkBluetoothPermissions();
      await _bluetoothClassicPlugin.connect(address, uuid);
      log("Connected to device: $address");
    } catch (e) {
      log("Error connecting to device: $e");
      throw Exception("Failed to connect to the device.");
    }
  }

  Future<void> disconnectDevice() async {
    try {
      await checkBluetoothPermissions();
      await _bluetoothClassicPlugin.disconnect();
      log("Disconnected from device.");
    } catch (e) {
      log("Failed to disconnect from device: $e");
      throw Exception("Failed to disconnect from the device.");
    }
  }

  Future<void> sendData(String data) async {
    try {
      await checkBluetoothPermissions();
      await _bluetoothClassicPlugin.write(data);
      log("Data sent: $data");
    } catch (e) {
      log("Failed to send data: $e");
      throw Exception("Failed to send data.");
    }
  }

  void dispose() {
    _deviceStatusController.close();
    _deviceDiscoveryController.close();
    // _dataReceivedController.close();
    _deviceDiscoverySubscription?.cancel();
  }
}
