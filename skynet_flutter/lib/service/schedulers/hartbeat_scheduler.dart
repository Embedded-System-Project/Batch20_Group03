import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:skynet/service/bluetooth/bluetooth_handler.dart';

Timer? _timer;

void startHartBeatScheduler() {
  if (_timer != null && _timer!.isActive) {
    return; // Prevent duplicate timers
  }

  _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    if (BluetoothHandler().isConnected && BluetoothHandler().isAuthenticated) {
      const data = {
        "action":"heartbeat",

      };
        // await BluetoothHandler().sendData(data);
    }
  });
}

void stopHartBeatScheduler() {
  _timer?.cancel();
}
