// import 'package:flutter/material.dart';
//
//
// class SocketSelectorWidget extends StatefulWidget {
//   final bool isDeviceSelected;
//   const SocketSelectorWidget({Key? key, required this.isDeviceSelected})
//       : super(key: key);
//
//   @override
//   _SocketSelectorWidgetState createState() => _SocketSelectorWidgetState();
// }
//
// class _SocketSelectorWidgetState extends State<SocketSelectorWidget> {
//   late List<Map<String, dynamic>> _socketBoxes;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize 8 socket boxes. For demonstration, mark index 3 as already selected (status = 2).
//     _socketBoxes = List.generate(8, (index) {
//       return {
//         "id": index,
//         "status": index == 3 ? 2 : 0, // 2: already selected/disabled, 0: not selected
//       };
//     });
//   }
//
//   // Return a color based on the socket's status.
//   Color getColor(int status) {
//     if (status == 2) {
//       return Colors.grey; // Already selected (disabled)
//     } else if (status == 1) {
//       return Colors.blueAccent; // Selected: default color
//     } else {
//       return Colors.blueAccent.withOpacity(0.2); // Not selected: default color at 0.2 opacity
//     }
//   }
//
//   // Toggle selection: only one can be selected at a time.
//   void toggleSelection(int index) {
//     if (_socketBoxes[index]["status"] == 2) return; // Disabled, do nothing
//     setState(() {
//       // Deselect all currently selected boxes
//       for (int i = 0; i < _socketBoxes.length; i++) {
//         if (_socketBoxes[i]["status"] == 1) {
//           _socketBoxes[i]["status"] = 0;
//         }
//       }
//       // Select the tapped box
//       _socketBoxes[index]["status"] = 1;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!widget.isDeviceSelected) return SizedBox.shrink();
//     return Padding(
//       padding: const EdgeInsets.all(16.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Select the socket",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//           ),
//           SizedBox(height: 10),
//           GridView.builder(
//             shrinkWrap: true,
//             physics: NeverScrollableScrollPhysics(),
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 4, // 4 boxes per row
//               crossAxisSpacing: 10,
//               mainAxisSpacing: 10,
//               childAspectRatio: 1,
//             ),
//             itemCount: _socketBoxes.length,
//             itemBuilder: (context, index) {
//               int status = _socketBoxes[index]["status"];
//               return GestureDetector(
//                 onTap: () => toggleSelection(index),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: getColor(status),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   alignment: Alignment.center,
//                   child: Text(
//                     "Socket: ${_socketBoxes[index]['id'] + 1}",
//                     style: TextStyle(
//                         color: Colors.white, fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
