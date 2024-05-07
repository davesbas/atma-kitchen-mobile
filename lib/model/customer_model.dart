import 'dart:convert';

class CustomerModel {
  final int idCustomer;
  final String nama;
  final String tanggalLahir;
  final String email;
  final int jumlahPoin;
  final String noTelp;

  CustomerModel({
    required this.idCustomer,
    required this.nama,
    required this.email,
    required this.tanggalLahir,
    required this.jumlahPoin,
    required this.noTelp,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
        idCustomer: json['id_customer'],
        nama: json['nama'],
        email: json['user_credential']['email'],
        tanggalLahir: json['tanggal_lahir'],
        jumlahPoin: json['jumlah_poin'],
        noTelp: json['no_telp'],
      );

  Map<String, dynamic> toJson() => {
        'id_customer': idCustomer,
        'nama': nama,
        'email': email,
        'tanggal_lahir': tanggalLahir,
        'jumlah_poin': jumlahPoin,
        'no_telp': noTelp,
      };
}
