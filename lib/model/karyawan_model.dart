import 'dart:convert';

class KaryawanModel {
  final int idKaryawan;
  final int idJabatan;
  final String nama;
  final String tglBergabung;
  final int gaji;
  final int bonus;

  KaryawanModel({
    required this.idKaryawan,
    required this.idJabatan,
    required this.nama,
    required this.tglBergabung,
    required this.gaji,
    required this.bonus,
  });

  factory KaryawanModel.fromJson(Map<String, dynamic> json) => KaryawanModel(
        idKaryawan: json['id_karyawan'],
        idJabatan: json['id_jabatan'],
        nama: json['nama'],
        tglBergabung: json['tgl_bergabung'],
        gaji: json['gaji'],
        bonus: json['bonus'],
      );

  Map<String, dynamic> toJson() => {
        'id_karyawan': idKaryawan,
        'id_jabatan': idJabatan,
        'nama': nama,
        'tgl_bergabung': tglBergabung,
        'gaji': gaji,
        'bonus': bonus,
      };
}
