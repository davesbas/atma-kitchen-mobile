import 'package:atma_kitchen_mobile/model/produk.dart';

class AlamatModel {
  final int idAlamat;
  final int idCustomer;
  final String namaJalan;
  final String kecamatan;
  final String kelurahan;
  final int jarak;

  AlamatModel({
    required this.idAlamat,
    required this.idCustomer,
    required this.namaJalan,
    required this.kecamatan,
    required this.kelurahan,
    required this.jarak,
  });

  String get fullAddress => '$namaJalan, $kelurahan, $kecamatan ($jarak km)';
  int get estimatedOngkir => jarak * 2000;

  factory AlamatModel.fromJson(Map<String, dynamic> json) => AlamatModel(
        idAlamat: _toInt(json['id_alamat']),
        idCustomer: _toInt(json['id_customer']),
        namaJalan: (json['nama_jalan'] ?? '').toString(),
        kecamatan: (json['kecamatan'] ?? '').toString(),
        kelurahan: (json['kelurahan'] ?? '').toString(),
        jarak: _toInt(json['jarak']),
      );

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class PengirimanModel {
  final int idTransaksi;
  final int? idAlamat;
  final String jenis;
  final String? statusPengiriman;
  final AlamatModel? alamat;

  PengirimanModel({
    required this.idTransaksi,
    this.idAlamat,
    required this.jenis,
    this.statusPengiriman,
    this.alamat,
  });

  factory PengirimanModel.fromJson(Map<String, dynamic> json) {
    return PengirimanModel(
      idTransaksi: _toInt(json['id_transaksi']),
      idAlamat: json['id_alamat'] == null ? null : _toInt(json['id_alamat']),
      jenis: (json['jenis'] ?? 'Pickup').toString(),
      statusPengiriman: json['status_pengiriman']?.toString(),
      alamat: json['alamat'] is Map<String, dynamic>
          ? AlamatModel.fromJson(json['alamat'] as Map<String, dynamic>)
          : null,
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class CartItemModel {
  final int idDetailTransaksi;
  final int idProduk;
  final int jumlah;
  final String satuan;
  final Produk produk;

  CartItemModel({
    required this.idDetailTransaksi,
    required this.idProduk,
    required this.jumlah,
    required this.satuan,
    required this.produk,
  });

  int get lineTotal => produk.harga * jumlah;

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final produkMap = json['produk'] is Map<String, dynamic>
        ? json['produk'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CartItemModel(
      idDetailTransaksi: _toInt(json['id_detail_transaksi']),
      idProduk: _toInt(json['id_produk']),
      jumlah: _toInt(json['jumlah']),
      satuan: (json['satuan'] ?? 'pcs').toString(),
      produk: Produk.fromJson(produkMap),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}

class CartModel {
  final int idTransaksi;
  final String? tglAmbil;
  final int poinUsedValue;
  final bool usePoin;
  final List<CartItemModel> items;
  final PengirimanModel? pengiriman;
  final List<AlamatModel> alamatList;
  final int cartCount;
  final int totalItemPrice;
  final int taxes;
  final int ongkir;
  final int subtotal;
  final int customerPoin;
  final int customerSaldo;

  CartModel({
    required this.idTransaksi,
    this.tglAmbil,
    required this.poinUsedValue,
    required this.usePoin,
    required this.items,
    this.pengiriman,
    required this.alamatList,
    required this.cartCount,
    required this.totalItemPrice,
    required this.taxes,
    required this.ongkir,
    required this.subtotal,
    required this.customerPoin,
    required this.customerSaldo,
  });

  factory CartModel.empty() => CartModel(
        idTransaksi: 0,
        poinUsedValue: 0,
        usePoin: false,
        items: const [],
        alamatList: const [],
        cartCount: 0,
        totalItemPrice: 0,
        taxes: 0,
        ongkir: 0,
        subtotal: 0,
        customerPoin: 0,
        customerSaldo: 0,
      );

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List<dynamic>? ?? []);
    final rawAlamat = (json['alamat_list'] as List<dynamic>? ?? []);

    return CartModel(
      idTransaksi: _toInt(json['id_transaksi']),
      tglAmbil: json['tgl_ambil']?.toString(),
      poinUsedValue: _toInt(json['poin_used_value']),
      usePoin: json['use_poin'] == true,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList(),
      pengiriman: json['pengiriman'] is Map<String, dynamic>
          ? PengirimanModel.fromJson(json['pengiriman'] as Map<String, dynamic>)
          : null,
      alamatList: rawAlamat
          .whereType<Map<String, dynamic>>()
          .map(AlamatModel.fromJson)
          .toList(),
      cartCount: _toInt(json['cart_count']),
      totalItemPrice: _toInt(json['total_item_price']),
      taxes: _toInt(json['taxes']),
      ongkir: _toInt(json['ongkir']),
      subtotal: _toInt(json['subtotal']),
      customerPoin: _toInt(json['customer_poin']),
      customerSaldo: _toInt(json['customer_saldo']),
    );
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
