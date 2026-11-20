class PenarikanSaldoModel {
  final int idPenarikan;
  final int jumlahPenarikan;
  final String bank;
  final String noRek;
  final String status;

  PenarikanSaldoModel({
    required this.idPenarikan,
    required this.jumlahPenarikan,
    required this.bank,
    required this.noRek,
    required this.status,
  });

  factory PenarikanSaldoModel.fromJson(Map<String, dynamic> json) =>
      PenarikanSaldoModel(
        idPenarikan: _toInt(json['id_penarikan']),
        jumlahPenarikan: _toInt(json['jumlah_penarikan']),
        bank: (json['bank'] ?? '').toString(),
        noRek: (json['no_rek'] ?? '').toString(),
        status: (json['status'] ?? 'pending').toString(),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class SaldoInfoModel {
  final int saldo;
  final int jumlahPoin;
  final List<PenarikanSaldoModel> riwayatPenarikan;

  SaldoInfoModel({
    required this.saldo,
    required this.jumlahPoin,
    required this.riwayatPenarikan,
  });

  factory SaldoInfoModel.fromJson(Map<String, dynamic> json) {
    final list = (json['riwayat_penarikan'] as List<dynamic>? ?? []);
    return SaldoInfoModel(
      saldo: _toInt(json['saldo']),
      jumlahPoin: _toInt(json['jumlah_poin']),
      riwayatPenarikan: list
          .whereType<Map<String, dynamic>>()
          .map(PenarikanSaldoModel.fromJson)
          .toList(),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
