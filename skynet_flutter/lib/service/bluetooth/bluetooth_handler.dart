import 'dart:async';
import 'dart:convert'; // For UTF-8 decoding
import 'dart:typed_data'; // For Uint8List
import 'package:bluetooth_classic/bluetooth_classic.dart';
import 'package:skynet/enum/device_configuration.dart';

class BluetoothHandler {
  // Singleton pattern
  static final BluetoothHandler _instance = BluetoothHandler._internal();
  factory BluetoothHandler() => _instance;
  final BluetoothClassic _bluetooth = BluetoothClassic();

  bool _isConnected = false;
  bool _isAuthenticated = true;
  bool _isSending = false;

  Uint8List _lastReceivedData = Uint8List(0);
  String _lastReceivedText = "";

  // StreamControllers for broadcasting data and status changes
  final StreamController<Uint8List> _dataStreamController =
  StreamController<Uint8List>.broadcast();
  final StreamController<String> _textStreamController =
  StreamController<String>.broadcast();
  final StreamController<bool> _connectionStatusController =
  StreamController<bool>.broadcast(); // Connection status stream

  BluetoothHandler._internal();

  /// Streams for listening to real-time received data and connection status
  Stream<Uint8List> get onDataReceived => _dataStreamController.stream;
  Stream<String> get onTextReceived => _textStreamController.stream;
  Stream<bool> get onConnectionStatusChanged => _connectionStatusController.stream;

  /// Getters for connection status and last received data
  bool get isConnected => _isConnected;
  bool get isAuthenticated => _isAuthenticated;
  bool get isSending => _isSending;

  set isAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  Uint8List get lastReceivedData => _lastReceivedData;
  String get lastReceivedText => _lastReceivedText;

  /// Initialize Bluetooth permissions
  Future<void> initBluetooth() async {
    await _bluetooth.initPermissions();
  }

  /// Connect to a Bluetooth device
  Future<void> connect(String macAddress) async {
    if (_isConnected) return;
    try {
      await _bluetooth.connect(macAddress, DeviceConfiguration.serialUUID.key);
      _isConnected = true;
      _connectionStatusController.add(true); // Notify listeners

      // Listen for incoming data
      _bluetooth.onDeviceDataReceived().listen((event) {
        _lastReceivedData = event;
        _dataStreamController.add(event);

        try {
          String decodedMessage = utf8.decode(event, allowMalformed: true).trim();
          _lastReceivedText = decodedMessage;
          _textStreamController.add(decodedMessage);
        } catch (e) {
          String asciiMessage = String.fromCharCodes(event).trim();
          _lastReceivedText = asciiMessage;
          _textStreamController.add(asciiMessage);
        }
      });

      // Start monitoring connection by sending test messages
      _monitorConnectionStatus();

    } catch (e) {
      print("Bluetooth Connection Error: $e");
      _isConnected = false;
      _connectionStatusController.add(false); // Notify listeners
    }
  }

  /// Monitor connection status by sending a test message
  void _monitorConnectionStatus() {
    Timer.periodic(Duration(seconds: 5), (timer) async {
      if (!_isConnected) {
        timer.cancel();
        return;
      }

      try {
        //await _bluetooth.write("ping"); // Send a test message
      } catch (e) {
        print("Device Disconnected: $e");
        _handleDisconnection();
        timer.cancel();
      }
    });
  }

  /// Handles unexpected disconnection
  void _handleDisconnection() {
    if (_isConnected) {
      _isConnected = false;
      _connectionStatusController.add(false); // Notify listeners
      print("Device Disconnected!");
    }
  }

  /// Send data to the connected Bluetooth device
  Future<void> sendData(Object data) async {
    if (!_isConnected) {
      print("No Bluetooth device connected.");
      return;
    }

    while (_isSending) {
      print("Waiting for previous message to be sent...");
      await Future.delayed(Duration(milliseconds: 100));
    }

    _isSending = true;
    String message = jsonEncode(data);
    print("Sent data: $message");

    try {
      await _bluetooth.write(message);
    } catch (e) {
      print("Failed to send data. Device might be disconnected.");
      _handleDisconnection();
      return;
    }

    Future.delayed(Duration(seconds: 3), () {
      _isSending = false;
      print("Ready to send next message.");
    });
  }

  /// Function to receive and process messages from the Bluetooth stream
  void receiveMessage(Function(String message) onMessageReceived) {
    onTextReceived.listen((String text) {
      onMessageReceived(text);
    });
  }

  /// Disconnect from Bluetooth
  Future<void> disconnect() async {
    if (!_isConnected) return;
    await _bluetooth.disconnect();
    _handleDisconnection();
  }
}
