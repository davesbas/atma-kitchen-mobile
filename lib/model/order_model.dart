import 'package:atma_kitchen_mobile/model/cart_model.dart';

class OrderModel {
  final int idTransaksi;
  final String status;
  final String tglTransaksi;
  final String tglAmbil;
  final int totalHarga;
  final int poinUsedValue;
  final String? fotoBukti;
  final String jenisPembayaran;
  final bool verifikasiPembayaran;
  final PengirimanModel? pengiriman;
  final List<CartItemModel> items;

  OrderModel({
    required this.idTransaksi,
    required this.status,
    required this.tglTransaksi,
    required this.tglAmbil,
    required this.totalHarga,
    required this.poinUsedValue,
    this.fotoBukti,
    required this.jenisPembayaran,
    required this.verifikasiPembayaran,
    this.pengiriman,
    required this.items,
  });

  bool get canConfirmReceived {
    final s = status.toLowerCase();
    return s != 'selesai' && s != 'dibatalkan' && s != 'ditolak';
  }

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawDetails = (json['detail_transaksi'] as List<dynamic>? ?? []);
    final pembayaran = json['pembayaran'] is Map<String, dynamic>
        ? json['pembayaran'] as Map<String, dynamic>
        : <String, dynamic>{};

    return OrderModel(
      idTransaksi: _toInt(json['id_transaksi']),
      status: (json['status'] ?? 'pending').toString(),
      tglTransaksi: (json['tgl_transaksi'] ?? json['created_at'] ?? '').toString(),
      tglAmbil: (json['tgl_ambil'] ?? '-').toString(),
      totalHarga: _toInt(json['total_harga']),
      poinUsedValue: _toInt(json['poin']),
      fotoBukti: json['foto_bukti']?.toString(),
      jenisPembayaran: (pembayaran['jenis_pembayaran'] ?? 'Bank Transfer').toString(),
      verifikasiPembayaran: pembayaran['verifikasi_pembayaran'] == true ||
          pembayaran['verifikasi_pembayaran'] == 1,
      pengiriman: json['pengiriman'] is Map<String, dynamic>
          ? PengirimanModel.fromJson(json['pengiriman'] as Map<String, dynamic>)
          : null,
      items: rawDetails
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
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
