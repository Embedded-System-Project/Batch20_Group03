import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/service/bluetooth/bluetooth_handler.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';
import 'package:uuid/uuid.dart';

class InitBluetooth extends StatefulWidget {
  const InitBluetooth({Key? key}) : super(key: key);

  @override
  _InitBluetoothState createState() => _InitBluetoothState();
}

class _InitBluetoothState extends State<InitBluetooth> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = "";
  bool _scannedValidCode = false; // flag to indicate a valid code has been scanned

  // Variable to hold the received Bluetooth message
  String _receivedMessage = "";

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
      controller!.resumeCamera();
    }
  }

  @override
  void initState() {
    super.initState();

    // Subscribe to received Bluetooth messages
    BluetoothHandler().receiveMessage((String message) {
      setState(() {
        // Trim leading and trailing whitespace/newlines
        message = message.trim();

        // Append to the received message if it's less than 4 characters

          _receivedMessage += message;
          const leadingChar = "=";
          _receivedMessage = _receivedMessage.split(leadingChar)[_receivedMessage.split(leadingChar).length-1];

      });

      debugPrint("Updated Received Message: $_receivedMessage");
    });

  }

  Future<void> connect() async {
    await BluetoothHandler().initBluetooth();
    await BluetoothHandler().connect(qrText);
    final prefsService = SharedPreferencesService();
    final userId = await prefsService.getUserId();

    if (userId == null) {
      log("User ID not found in SharedPreferences.");
      return;
    }

    String uuid = Uuid().v4();
    final data = {
      "action": "auth",
      "userId": userId,
      "uuid": uuid
    };

    // Send authentication request over Bluetooth
    await BluetoothHandler().sendAuth(data);

    debugPrint("Waiting for authentication confirmation...");

    // Wait for authentication success message
    while (!_receivedMessage.contains("Auth Successfully")) {
      await Future.delayed(const Duration(milliseconds: 500)); // Check every 500ms
      // print("waiting for confirmation");
    }


    SharedPreferencesService prefService = SharedPreferencesService();
    await prefService.saveIsNewDevice(false, address: qrText);
    BluetoothHandler().isAuthenticated = true;
    debugPrint("Authentication successful!");

    // Navigate to home page after successful authentication
    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connect to SkyNet", style: TextStyle(color: Colors.white)),
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
      body: _scannedValidCode
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Connecting to SkyNet...",
              style: TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Container(
            height: 70,
            color: const Color.fromARGB(255, 6, 26, 94),
            child: const Center(
              child: Text(
                "Scan QR and Connect",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      // For testing purposes, using a fixed code.
      final code = "FC:A8:9A:00:23:2D";
      // Regular expression for matching the QR code with the pattern
      final regex = RegExp(r'^[A-Za-z0-9]{2}(:[A-Za-z0-9]{2}){5}$');
      if (regex.hasMatch(code)) {
        setState(() {
          qrText = code;
          _scannedValidCode = true;
        });
        debugPrint("Valid QR Code: $code");

        // Call the connect method when a valid QR code is scanned
        await connect();
      } else {
        debugPrint("Invalid QR Code scanned: $code");
        // Keep scanning if the pattern doesn't match
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
