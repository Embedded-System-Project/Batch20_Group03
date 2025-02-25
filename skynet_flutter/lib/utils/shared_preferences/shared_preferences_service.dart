import 'package:shared_preferences/shared_preferences.dart';
import 'package:skynet/model/auth_data.model.dart';

class SharedPreferencesService {

  static const String _keyLogin_UserId = 'login-userId';
  static const String _keyLogin_name = 'login-name';
  static const String _keyLogin_status = 'login-status';
  static const String _keyLogin_loggedTime = 'login-loggedTime';

  static const String _keyIsNewDevice = 'is-new-device';
  static const String _skyNetAddress = "skynet_address";


  Future<void> saveLoginData(LoginData loginData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLogin_UserId, loginData.userID);
    await prefs.setString(_keyLogin_name, loginData.name);
    await prefs.setString(_keyLogin_status, loginData.status);
    await prefs.setString(_keyLogin_loggedTime, loginData.loggedInDateTime.toIso8601String());
  }


Future<LoginData?> getLoginData() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(_keyLogin_UserId);
  final name = prefs.getString(_keyLogin_name);
  final status = prefs.getString(_keyLogin_status);
  final loggedTime = prefs.getString(_keyLogin_loggedTime);

  if (userId == null || status == null || loggedTime == null) {
    return null;
  }

  return LoginData(
    name: name ?? '',
    userID: userId,
    status: status,
    loggedInDateTime: DateTime.parse(loggedTime),
  );
}

  Future<String?> getUserId() async {
    final loginData = await getLoginData();
    return loginData?.userID;
  }

  Future<void> removeLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLogin_UserId);
    await prefs.remove(_keyLogin_name);
    await prefs.remove(_keyLogin_status);
    await prefs.remove(_keyLogin_loggedTime);
  }

  Future<void> saveIsNewDevice(bool isNewDevice, {String address = ""}) async {

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsNewDevice, isNewDevice);
    await prefs.setString(_skyNetAddress, address);


  }

  Future<bool> isNewDevice() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsNewDevice) ?? true;
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLogin_name) ?? '';
  }

  Future<String> getMacAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_skyNetAddress) ?? '';
  }
}