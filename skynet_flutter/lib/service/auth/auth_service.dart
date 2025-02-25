import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:skynet/enum/auth_status.dart';
import 'package:skynet/model/auth_data.model.dart';
import 'package:skynet/screens/home/home.dart';
import 'package:skynet/screens/startup/init_bluetooth_connection.dart';
import 'package:skynet/utils/bluetooth/bluetooth_provider.dart';
import 'package:skynet/utils/firebase/db_service.dart';
import 'package:skynet/utils/shared_preferences/shared_preferences_service.dart';

import '../../screens/auth/unverified.screen.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _sharedPreferencesService = SharedPreferencesService();
  final _dbService = DbService();
  final BluetoothProvider _bluetoothProvider = BluetoothProvider();


  Future<User?> signInWithEmailAndPassword(
      BuildContext context, String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;
      if (user != null) {
        String name = await _dbService.getUserName(user.uid);
        LoginData loginData = LoginData(
          name: name,
          userID: user.uid,
          status: user.emailVerified
              ? AuthStatus.active.name
              : AuthStatus.unverified.name,
          loggedInDateTime: DateTime.now(),
        );
        await _sharedPreferencesService.saveLoginData(loginData);
        
        if (user.emailVerified) {
          if (await _sharedPreferencesService.isNewDevice()) {
            await _bluetoothProvider.checkBluetoothPermissions();
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => InitBluetooth()));
          } else {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
          }
        } else {
          await user.sendEmailVerification();
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => UnverifiedScreen()));
        }
      }
      return cred.user;
    } catch (e) {
      log("Error occured in signin with email and password: $e");
    }
    return null;
  }

  Future<User?> signUpWithEmailAndPassword(
      BuildContext context, String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = cred.user;
      if (user != null) {
        await user.sendEmailVerification();
        LoginData loginData = LoginData(
          name: name,
          userID: user.uid,
          status: AuthStatus.unverified.name,
          loggedInDateTime: DateTime.now(),
        );

        final uid = user.uid;
        log("Saving login data: $uid");
        await _sharedPreferencesService.saveLoginData(loginData);
        await _dbService.saveSignUpData(email, name, uid);
        await _bluetoothProvider.checkBluetoothPermissions();
        await _dbService.createDefaultRooms(uid);
        Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => UnverifiedScreen()));
      }
      return user;
    } catch (e) {
      log("Error occured in signup with email and password: $e");
    }
    return null;
  }

  Future<bool> checkEmailVerification() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        String name = await _dbService.getUserName(user.uid);
        LoginData loginData = LoginData(
          name: name,
          userID: user.uid,
          status: AuthStatus.active.name,
          loggedInDateTime: DateTime.now(),
        );
        await _sharedPreferencesService.saveLoginData(loginData);
        return true;
      }
    } else {
      log("No user is currently signed in.");
    }
    return false;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      log("Error occured in signout: $e");
    }
  }
}
