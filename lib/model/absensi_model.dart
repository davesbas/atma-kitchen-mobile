class AbsensiModel {
  final int idAbsensi;
  final int idKaryawan;
  final String tanggal;
  final String namaKaryawan;
  final String jabatan;

  AbsensiModel({
    required this.idAbsensi,
    required this.idKaryawan,
    required this.tanggal,
    required this.namaKaryawan,
    required this.jabatan,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    final karyawan = json['karyawan'] is Map<String, dynamic>
        ? json['karyawan'] as Map<String, dynamic>
        : <String, dynamic>{};
    final jabatanMap = karyawan['jabatan'] is Map<String, dynamic>
        ? karyawan['jabatan'] as Map<String, dynamic>
        : <String, dynamic>{};

    return AbsensiModel(
      idAbsensi: _toInt(json['id_absensi']),
      idKaryawan: _toInt(json['id_karyawan']),
      tanggal: (json['tanggal'] ?? '').toString(),
      namaKaryawan: (karyawan['nama'] ?? 'Karyawan #${json['id_karyawan']}').toString(),
      jabatan: (jabatanMap['nama'] ?? '-').toString(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
