import 'package:flutter/material.dart';
import 'package:skynet/model/auth_data.model.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class DeviceCard extends StatelessWidget {
  final String room;
  final Map<String, dynamic> device;
  final bool isSelected; // Track selection state

  const DeviceCard({
    Key? key,
    required this.room,
    required this.device,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _sharedPreferencesService = SharedPreferencesService();
    final _dbService = DbService();
    _dbService.getAllSocketIds();

    return FutureBuilder<LoginData?>(
      future: _sharedPreferencesService.getLoginData(),
      builder: (context, loginDataSnapshot) {
        if (loginDataSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!loginDataSnapshot.hasData) {
          return const Center(child: Text('Login data not found'));
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _dbService.getDeviceByCategory( room, device['name']),
          builder: (context, devicesSnapshot) {
            int totalDevices = 0;
            int connectedDevices = 0;
            if (devicesSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (devicesSnapshot.hasData && devicesSnapshot.data!.isNotEmpty) {
              final devices = devicesSnapshot.data!;
              totalDevices = devices.length;
              connectedDevices =
                  devices.where((d) => d['status'] == true).length;

            }


            return Card(
              color: isSelected
                  ? Colors.blueAccent // Selected color
                  : Colors.lightBlue, // Non-selected color
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      device['icon'],
                      size: 32,
                      color:  Colors.white
                    ),
                    const SizedBox(height: 10),
                    Text(
                      device['name'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      totalDevices == 0
                          ? 'No Devices Found'
                          : "$totalDevices devices connected-",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),

                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
