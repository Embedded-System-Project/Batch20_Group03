import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skynet/screens/auth/signin.screen.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/screens/startup/init_bluetooth_connection.dart';
import 'package:skynet/service/auth/auth_service.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

class UnverifiedScreen extends StatefulWidget {
  const UnverifiedScreen({super.key});

  @override
  _UnverifiedScreenState createState() => _UnverifiedScreenState();
}

class _UnverifiedScreenState extends State<UnverifiedScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = true;
  Timer? timer;
  Timer? countdownTimer;
  int countdown = 0;

  final _auth = AuthService();

  @override
  void initState() {
    super.initState();
    checkEmailVerified();
    timer = Timer.periodic(Duration(seconds: 3), (_) => checkEmailVerified());
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    if(FirebaseAuth.instance.currentUser == null) {
      SharedPreferencesService sharedPreferencesService = SharedPreferencesService();
      log(sharedPreferencesService.getLoginData().toString());

      return;
    }
    if(FirebaseAuth.instance.currentUser==null){
      SharedPreferencesService sharedPreferencesService = SharedPreferencesService();
      await sharedPreferencesService.removeLoginData();
      return;
    }
    await FirebaseAuth.instance.currentUser?.reload();
    final isVerified = await _auth.checkEmailVerification();
    setState(() {
      isEmailVerified = isVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => InitBluetooth()));
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      setState(() {
        canResendEmail = false;
        countdown = 30; // Reset countdown to 30 seconds
      });
      startCountdown();
    } catch (e) {
      // Handle error
    }
  }

  void startCountdown() {
    countdownTimer?.cancel(); // Cancel any existing timer
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (countdown > 0) {
          countdown--;
        } else {
          canResendEmail = true;
          timer.cancel(); // Stop the timer when countdown is 0
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'A verification email has been sent to your email.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              child: Text('Resend Verification Email'),
            ),
            if (!canResendEmail) // Show countdown message only when button is disabled
              Text('You can resend the email in $countdown seconds.'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
