import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skynet/enum/auth_status.dart';
import 'package:skynet/model/auth_data.model.dart';
import 'package:skynet/screens/auth/signin.screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/screens/startup/init_bluetooth_connection.dart';
import 'package:skynet/service/schedulers/hartbeat_scheduler.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final sharedPreferencesService = SharedPreferencesService();
    try {
      await Firebase.initializeApp();
      // await startHartBeatScheduler();
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Check if the user is verified
        bool isVerified = await checkUserVerificationStatus(user);

        if (isVerified) {
          if (await sharedPreferencesService.isNewDevice()) {
            return InitBluetooth();
          } else {
            return const HomePage();
          }

        } else {
          return SignInScreen();
        }
      } else {
        return SignInScreen();
      }
    } catch (e) {
      // Handle any errors in the Future
      return Center(
        child: Text('Error: $e'),
      );
    }
  }

  Future<bool> checkUserVerificationStatus(User user) async {
    final sharedPreferencesService = SharedPreferencesService();
    try {
      LoginData? loginData = await sharedPreferencesService.getLoginData();
      if (loginData != null) {
        if (loginData.userID == user.uid) {
          return loginData.status == AuthStatus.active.name;
        }
      }
      return false;
    } catch (e) {
      // Handle errors when checking user verification status
      print('Error checking user verification status: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData && snapshot.data != null) {
            return snapshot.data!;
          } else if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            );
          } else {
            return const Scaffold(
              body: Center(
                child: Text('No initial screen available'),
              ),
            );
          }
        },
      ),
    );
  }
}
