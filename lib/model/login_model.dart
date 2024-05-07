import 'dart:convert';

class LoginModel {
  final int idUserCredentials;
  final int? idCustomer;
  final int? idKaryawan;
  final String email;
  final String password;
  final String token;
  final String userName;
  final int userPoints;
  final String role; // New property to store the user's role

  LoginModel({
    required this.idUserCredentials,
    this.idCustomer,
    this.idKaryawan,
    required this.email,
    required this.password,
    required this.token,
    required this.userName,
    required this.userPoints,
    required this.role, // Initialize role in the constructor
  });

  factory LoginModel.fromRawJson(String str) =>
      LoginModel.fromJson(json.decode(str));

  Map<String, dynamic> toJson() => {
        'id_user_credentials': idUserCredentials,
        'id_customer': idCustomer,
        'id_karyawan': idKaryawan,
        'email': email,
        'password': password,
        'token': token,
        'user_name': userName,
        'user_points': userPoints,
        'role': role, // Include role in JSON serialization
      };

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    // Parsing nested user details which could either be from Customer or Karyawan
    var userDetail = json['user'] ?? {};
    int userPoints = 0;
    String userName = '';

    if (json['id_customer'] != null) {
      userName = userDetail['nama'] ?? '';
      userPoints = userDetail['jumlah_poin'] ?? 0;
    } else if (json['id_karyawan'] != null) {
      userName = userDetail['nama'] ?? '';
      // Assume Karyawan might also have points or similar attribute if needed
    }

    return LoginModel(
      idUserCredentials: json['id_user_credentials'] ?? 0,
      idCustomer: json['id_customer'],
      idKaryawan: json['id_karyawan'],
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      token: json['token'] ?? '',
      userName: json['nama'] ?? '',
      userPoints: json['jumlah_poin'] ?? 0,
      role: json['role'] ?? '', // Extract role from JSON
    );
  }

  String toRawJson() => json.encode(toJson());
}
