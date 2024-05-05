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

  LoginModel({
    required this.idUserCredentials,
    required this.idCustomer,
    required this.idKaryawan,
    required this.email,
    required this.password,
    required this.token,
    required this.userName,
    required this.userPoints,
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
      };

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    // Parsing nested user details which could either be from Customer or Karyawan
    var userDetail = json['user_detail'] ?? {};
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
      idUserCredentials: json['id_user_credentials'],
      idCustomer: json['id_customer'],
      idKaryawan: json['id_karyawan'],
      email: json['email'],
      password: json['password'],
      token: json['token'],
      userName: userName,
      userPoints: userPoints,
    );
  }

  String toRawJson() => json.encode(toJson());
}