// room_section.dart
import 'package:flutter/material.dart';
import 'package:skynet/data/room_data.dart';

class RoomSection extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onRoomSelected;

  const RoomSection({
    Key? key,
    required this.selectedIndex,
    required this.onRoomSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = room_data_list;
    return SizedBox(
      height: 100, // Adjust the height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final room = data[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () {
              onRoomSelected(index);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blueAccent
                          : Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      room['icon'],
                      size: 32,
                      color: isSelected ? Colors.white : Colors.blueAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room['name'],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.blueAccent
                          : const Color.fromARGB(255, 6, 26, 94),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
