import 'dart:convert';

class RegisterModel {
  final int status;
  final String message;
  final UserData data;

  const RegisterModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory RegisterModel.fromRawJson(String str) =>
      RegisterModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterModel.fromJson(Map<String, dynamic> json) => RegisterModel(
        status: json['status'],
        message: json['message'],
        data: UserData.fromJson(json['data']),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.toJson(),
      };
}

class UserData {
  final int id;
  final String username;
  final String email;
  final String password;
  final String telephone;
  final String bornDate;
  final int poin;

  UserData({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.telephone,
    required this.bornDate,
    required this.poin,
  });

  factory UserData.fromRawJson(String str) => UserData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserData.fromJson(Map<String, dynamic> json) => UserData(
        id: json['id'],
        username: json['nama'],
        email: json['email'],
        password: json['password'],
        telephone: json['no_telp'],
        bornDate: json['tanggal_lahir'],
        poin: json['jumlah_poin'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nama': username,
        'email': email,
        'password': password,
        'no_telp': telephone,
        'tanggal_lahir': bornDate,
        'jumlah_poin': poin,
        // Add more fields as needed
      };
}
