import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ActiveTimeChart extends StatelessWidget {
  final List<Map<String, dynamic>> deviceTypeActiveTimeInHours;

  ActiveTimeChart({required this.deviceTypeActiveTimeInHours});

  @override
  Widget build(BuildContext context) {
    if (deviceTypeActiveTimeInHours.isEmpty ||
        deviceTypeActiveTimeInHours.every((data) => data['totalActiveTimeInHours'] == 0.0)) {
      return Center(child: Text('No active time data available.'));
    }

    // Calculate the maximum Y value dynamically based on the data
    double maxY = deviceTypeActiveTimeInHours
        .map((data) => data['totalActiveTimeInHours'] as double)
        .reduce((value, element) => value > element ? value : element);

    List<String> deviceNames =
    deviceTypeActiveTimeInHours.map((data) => data['deviceType'] as String).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: maxY + 1,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(fontSize: 12),
                  );
                },
                reservedSize: 40,
              ),
            ),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < deviceNames.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.0), // Add top padding
                      child: Transform.rotate(
                        angle: -pi / 2, // 90 degrees rotation
                        child: Text(
                          deviceNames[value.toInt()],
                          style: TextStyle(fontSize: 12),
                          textAlign: TextAlign.center, // Center-align text
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
                },
                reservedSize: 100, // Increase reserved space for vertical labels
              ),
            ),
          ),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(deviceTypeActiveTimeInHours.length, (index) {
            return BarChartGroupData(
              x: index, // Ensure x is indexed correctly
              barRods: [
                BarChartRodData(
                  toY: deviceTypeActiveTimeInHours[index]['totalActiveTimeInHours'],
                  color: _getDeviceTypeColor(index), // Assign fixed colors per device type
                  width: 18,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Function to get consistent colors per device type
  Color _getDeviceTypeColor(int index) {
    List<Color> predefinedColors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.cyan
    ];
    return predefinedColors[index % predefinedColors.length]; // Cycle through colors
  }
}
