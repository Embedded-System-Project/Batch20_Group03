import 'package:flutter/material.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:skynet/widgets/room_section.dart';
import 'package:skynet/data/room_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:skynet/widgets/device_card.dart';

class AnalysisFragment extends StatefulWidget {
  const AnalysisFragment({super.key});

  @override
  State<AnalysisFragment> createState() => _AnalysisFragmentState();
}

class _AnalysisFragmentState extends State<AnalysisFragment> {
  int _selectedRoomIndex = 0;
  late List<Map<String, dynamic>> _roomDataList;
  Map<String, double> _activeTimeData = {};
  Map<String, double> _deviceActiveTimeData = {};
  bool _loading = true;
  String _selectedDevice = "";
  String _selectedDeviceType = "";
  bool _isDeviceSelected = false;

  @override
  void initState() {
    super.initState();
    _roomDataList = List.from(room_data_list);
    _fetchActiveTimeData();
  }

  Future<Map<String, dynamic>?> getRoomData(String roomName) async {
    Map<String, dynamic> data = await DbService().getAvailableRooms();
    return data.containsKey(roomName) ? data[roomName] : null;
  }

  Future<void> _fetchActiveTimeData() async {
    setState(() {
      _loading = true;
    });

    String roomName = _roomDataList[_selectedRoomIndex]['name'];
    Map<String, dynamic>? roomData = await getRoomData(roomName);
    Map<String, double> deviceTypeActiveTimeInSeconds = {};
    Map<String, double> deviceActiveTimeInSeconds = {};

    if (roomData != null) {
      roomData.forEach((deviceType, deviceData) {
        deviceTypeActiveTimeInSeconds[deviceType] = 0.0;
        if (deviceData is List) {
          for (var device in deviceData) {
            if (device.containsKey('stat')) {
              double totalActiveTime = 0.0;
              List<Map<String, dynamic>> statusHistory = List.from(device['stat']);

              for (int i = 1; i < statusHistory.length; i++) {
                if (statusHistory[i]['status'] == true) {
                  DateTime startTime = DateTime.parse(statusHistory[i - 1]['timestamp']);
                  DateTime endTime = DateTime.parse(statusHistory[i]['timestamp']);
                  totalActiveTime += endTime.difference(startTime).inSeconds.toDouble();
                }
              }

              if (statusHistory.last['status'] == true) {
                DateTime lastStatusTime = DateTime.parse(statusHistory.last['timestamp']);
                DateTime currentTime = DateTime.now();
                totalActiveTime += currentTime.difference(lastStatusTime).inSeconds.toDouble();
              }

              deviceTypeActiveTimeInSeconds[deviceType] =
                  (deviceTypeActiveTimeInSeconds[deviceType] ?? 0.0) + totalActiveTime;

              if (deviceType == _selectedDeviceType) {
                String deviceName = device['name'] ?? 'Unknown';
                deviceActiveTimeInSeconds[deviceName] = totalActiveTime / 3600; // Convert to hours
              }
            }
          }
        }
      });
    }

    setState(() {
      _loading = false;
      _activeTimeData = deviceTypeActiveTimeInSeconds.map(
            (key, value) => MapEntry(key, value / 3600),
      );
      _deviceActiveTimeData = deviceActiveTimeInSeconds;
    });
  }

  void _onDeviceSelected(String room, Map<String, dynamic> device) {
    String deviceType = device['name'] ?? 'Unknown';
    setState(() {
      _selectedDevice = "$room - $deviceType";
      _selectedDeviceType = deviceType;
      _isDeviceSelected = true;
    });
    _fetchActiveTimeData();
  }

  bool _isNoDataAvailable(Map<String, double> data) {
    return data.values.every((value) => value == 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Analysis", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: RoomSection(
                selectedIndex: _selectedRoomIndex,
                onRoomSelected: (index) {
                  setState(() {
                    _selectedRoomIndex = index;
                    _selectedDevice = "";
                    _isDeviceSelected = false;
                    _selectedDeviceType = "";
                  });
                  _fetchActiveTimeData();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Room Activity Time (${_roomDataList[_selectedRoomIndex]['name']})', // Updated title
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16), // Padding between title and chart
                  _isNoDataAvailable(_activeTimeData)
                      ? Text(
                    'No data available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  )
                      : Center(  // Centering the chart
                    child: SizedBox(
                      height: 300,
                      child: BarChart(
                        BarChartData(
                          borderData: FlBorderData(show: false), // Remove border
                          gridData: FlGridData(show: false), // Hide grid
                          titlesData: FlTitlesData(
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide top titles
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right titles
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (double value, TitleMeta meta) {
                                  String deviceName = _activeTimeData.keys.elementAt(value.toInt());
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(deviceName, style: TextStyle(fontSize: 12)),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          barGroups: _activeTimeData.entries
                              .map(
                                (entry) => BarChartGroupData(
                              x: _activeTimeData.keys.toList().indexOf(entry.key),
                              barRods: [BarChartRodData(toY: entry.value, color: Colors.blueAccent)],
                            ),
                          )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                itemCount: _roomDataList[_selectedRoomIndex]['devices'].length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final device = _roomDataList[_selectedRoomIndex]['devices'][index];
                  return GestureDetector(
                    onTap: () => _onDeviceSelected(_roomDataList[_selectedRoomIndex]['name'], device),
                    child: DeviceCard(
                      key: ValueKey(_roomDataList[_selectedRoomIndex]['name'] + " - " + device["name"]),
                      isSelected: _selectedDevice == (_roomDataList[_selectedRoomIndex]['name'] + " - " + device["name"]),
                      room: _roomDataList[_selectedRoomIndex]['name'],
                      device: device,
                    ),
                  );
                },
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
              ),
            ),
            if (_isDeviceSelected) ...[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device-Specific Activity (${_selectedDeviceType})',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16), // Padding between title and chart
                    _isNoDataAvailable(_deviceActiveTimeData)
                        ? Text(
                      'No data available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )
                        : Center(  // Centering the chart
                      child: SizedBox(
                        height: 300,
                        child: BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false), // Remove border
                            gridData: FlGridData(show: false), // Hide grid
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide top titles
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide right titles
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    String deviceName = _deviceActiveTimeData.keys.elementAt(value.toInt());
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(deviceName, style: TextStyle(fontSize: 12)),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            barGroups: _deviceActiveTimeData.entries
                                .map(
                                  (entry) => BarChartGroupData(
                                x: _deviceActiveTimeData.keys.toList().indexOf(entry.key),
                                barRods: [BarChartRodData(toY: entry.value, color: Colors.blueAccent)],
                              ),
                            )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
