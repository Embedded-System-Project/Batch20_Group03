class LoginData {
  final String name;
  final String userID;
  final String status;
  final DateTime loggedInDateTime;

  LoginData({
    required this.name,
    required this.userID,
    required this.status,
    required this.loggedInDateTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'userID': userID,
      'status': status,
      'loggedInDateTime': loggedInDateTime.toIso8601String(),
    };
  }

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      name: json['name'],
      userID: json['userID'],
      status: json['status'],
      loggedInDateTime: DateTime.parse(json['loggedInDateTime']),
    );
  }
}
