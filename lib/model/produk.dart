class Produk {
  int id_produk;
  String nama;
  String gambar;
  int harga, kuota_produksi, stok;

  Produk({
    required this.id_produk,
    required this.nama,
    required this.gambar,
    required this.harga,
    required this.kuota_produksi,
    required this.stok,
  });

  factory Produk.fromJson(Map<String, dynamic> json) {
    return Produk(
      id_produk: json['id_produk'],
      gambar: 'http://10.0.2.2:8000/' + json['gambar'],
      nama: json['nama'],
      harga: json['harga'] as int,
      kuota_produksi: json['kuota_produksi'] ?? 0,
      stok: json['stok'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_produk': id_produk,
      'gambar': gambar,
      'nama': nama,
      'harga': harga,
      'kuota_produksi': kuota_produksi,
      'stok': stok,
    };
  }
}
