import 'package:flutter/material.dart';

class AnalysisFragment extends StatefulWidget {
  const AnalysisFragment({super.key});

  @override
  State<AnalysisFragment> createState() => _AnalysisFragmentState();
}

class _AnalysisFragmentState extends State<AnalysisFragment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add new Device", style: TextStyle(color: Colors.white)),
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
      body: Container(),
    );
  }
}
