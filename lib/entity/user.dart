import 'dart:convert';

class User {
  final int? id;
  final String? email;
  String? password;
  final String? telephone;
  final String? bornDate;
  int? poin;

  User({
    this.id,
    this.email,
    this.password,
    this.telephone,
    this.bornDate,
    this.poin,
  });

  // Define the idCustomer getter
  int? get idCustomer => id; // Assuming the id represents the id of the customer
  int? get idKaryawan => id;

  factory User.fromRawJson(String str) => User.fromJson(json.decode(str));

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id_user_credentials'],
        email: json['email'],
        password: json['password'],
        telephone: json['telephone'],
        bornDate: json['born_date'],
        poin: json['point'],
      );

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'telephone': telephone,
        'born_date': bornDate,
        'point': poin,
      };
}
