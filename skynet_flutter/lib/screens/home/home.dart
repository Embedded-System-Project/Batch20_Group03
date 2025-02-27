import 'package:flutter/material.dart';
import 'package:skynet/screens/home/fragments/add_fragment.dart';
import 'package:skynet/screens/home/fragments/analysis_fragment.dart';
import 'package:skynet/screens/home/fragments/home_fragment.dart';
import 'package:skynet/screens/home/fragments/scheduler_fragment.dart';
import 'package:skynet/screens/home/fragments/settings_fragment.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final screens = [
    HomeFragment(),
    AnalysisFragment(),
    AddFragment(),
    SchedulerFragment(),
    SettingsFragment()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        height: 80,
        elevation: 0,
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics),
            label: 'Analytics',
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: 'Add',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule),
            label: 'Schedules',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

      body: screens[_selectedIndex],
    );
  }
}
