import 'package:atma_kitchen_mobile/config/api_config.dart';

class Produk {
  final int idProduk;
  final int? idPenitip;
  final String nama;
  final String gambar;
  final int harga;
  final int kuotaProduksi;
  final int stok;
  final String status;
  final String deskripsi;

  Produk({
    required this.idProduk,
    this.idPenitip,
    required this.nama,
    required this.gambar,
    required this.harga,
    required this.kuotaProduksi,
    required this.stok,
    this.status = '',
    this.deskripsi = '',
  });

  // Backwards-compatible getters
  int get id_produk => idProduk;
  int get kuota_produksi => kuotaProduksi;

  int get availableStock => idPenitip == null ? kuotaProduksi : stok;
  String get availabilityLabel =>
      idPenitip == null ? 'Kuota Hari Ini: $kuotaProduksi' : 'Stok: $stok';

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      idProduk: _toInt(json['id_produk']),
      idPenitip: json['id_penitip'] == null ? null : _toInt(json['id_penitip']),
      gambar: ApiConfig.imageUrl(json['gambar']?.toString()),
      nama: (json['nama'] ?? '').toString(),
      harga: _toInt(json['harga']),
      kuotaProduksi: _toInt(json['kuota_produksi']),
      stok: _toInt(json['stok']),
      status: (json['status'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': idProduk,
      'id_penitip': idPenitip,
      'gambar': gambar,
      'nama': nama,
      'harga': harga,
      'kuota_produksi': kuotaProduksi,
      'stok': stok,
      'status': status,
      'deskripsi': deskripsi,
    };
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
