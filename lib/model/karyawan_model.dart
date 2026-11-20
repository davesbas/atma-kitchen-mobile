class KaryawanModel {
  final int idKaryawan;
  final int idJabatan;
  final String nama;
  final String tglBergabung;
  final int gaji;
  final int bonus;
  final String jabatanNama;

  KaryawanModel({
    required this.idKaryawan,
    required this.idJabatan,
    required this.nama,
    required this.tglBergabung,
    required this.gaji,
    required this.bonus,
    this.jabatanNama = '',
  });

  factory KaryawanModel.empty() => KaryawanModel(
        idKaryawan: 0,
        idJabatan: 0,
        nama: '',
        tglBergabung: '',
        gaji: 0,
        bonus: 0,
      );

  factory KaryawanModel.fromJson(Map<String, dynamic> json) {
    final jabatan = json['jabatan'] is Map<String, dynamic>
        ? json['jabatan'] as Map<String, dynamic>
        : <String, dynamic>{};

    return KaryawanModel(
      idKaryawan: _toInt(json['id_karyawan']),
      idJabatan: _toInt(json['id_jabatan']),
      nama: (json['nama'] ?? '').toString(),
      tglBergabung: (json['tgl_bergabung'] ?? '').toString(),
      gaji: _toInt(json['gaji']),
      bonus: _toInt(json['bonus']),
      jabatanNama: (jabatan['nama'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_karyawan': idKaryawan,
        'id_jabatan': idJabatan,
        'nama': nama,
        'tgl_bergabung': tglBergabung,
        'gaji': gaji,
        'bonus': bonus,
        'jabatan_nama': jabatanNama,
      };

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
