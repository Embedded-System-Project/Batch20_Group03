import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skynet/screens/auth/signin.screen.dart'; // Import your SignInScreen

class SettingsFragment extends StatefulWidget {
  const SettingsFragment({super.key});

  @override
  State<SettingsFragment> createState() => _SettingsFragmentState();
}

class _SettingsFragmentState extends State<SettingsFragment> {
  Future<void> _logout() async {
    // Show confirmation dialog
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );

    // If the user confirms, clear SharedPreferences and navigate to login page
    if (confirmLogout == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();  // Clear all saved data from SharedPreferences

        // Navigate to the SignIn screen and remove the settings fragment from the navigation stack
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignInScreen()), // Your SignInScreen widget
              (route) => false,  // This removes all previous routes
        );
      } catch (e) {
        // Handle any errors while clearing SharedPreferences
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error logging out: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 6, 26, 94),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {
              // Handle notification icon press
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,  // Trigger logout when pressed
          ),
        ],
        elevation: 4.0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _logout,  // Trigger logout when button is pressed
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent, // Red color for logout button
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                textStyle: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              child: const Text('Logout', style: TextStyle(color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }
}
