import 'dart:async';

import 'package:skynet/service/bluetooth/bluetooth_handler.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

Timer? _timer;

Future<void> startHartBeatScheduler() async{
  if (_timer != null && _timer!.isActive) {
    return; // Prevent duplicate timers
  }

  _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
    SharedPreferencesService pref = SharedPreferencesService();
    String mac = await pref.getMacAddress();
    if (BluetoothHandler().isConnected && BluetoothHandler().isAuthenticated) {
      const data = {
        "action":"heartbeat",

      };
        // await BluetoothHandler().sendData(data);
    }

    else if(!BluetoothHandler().isConnected && mac.isNotEmpty){
      await BluetoothHandler().initBluetooth();
      await BluetoothHandler().connect(mac);
      print("send connection signal to $mac");
    }
  });
}

void stopHartBeatScheduler() {
  _timer?.cancel();
}
