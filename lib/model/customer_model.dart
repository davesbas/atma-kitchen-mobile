class CustomerModel {
  final int idCustomer;
  final String nama;
  final String tanggalLahir;
  final String email;
  final int jumlahPoin;
  final String noTelp;
  final int saldo;

  CustomerModel({
    required this.idCustomer,
    required this.nama,
    required this.email,
    required this.tanggalLahir,
    required this.jumlahPoin,
    required this.noTelp,
    required this.saldo,
  });

  factory CustomerModel.empty() => CustomerModel(
        idCustomer: 0,
        nama: '',
        email: '',
        tanggalLahir: '',
        jumlahPoin: 0,
        noTelp: '',
        saldo: 0,
      );

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    final cred = json['user_credential'] is Map<String, dynamic>
        ? json['user_credential'] as Map<String, dynamic>
        : <String, dynamic>{};

    return CustomerModel(
      idCustomer: _toInt(json['id_customer']),
      nama: (json['nama'] ?? '').toString(),
      email: (cred['email'] ?? json['email'] ?? '').toString(),
      tanggalLahir: (json['tanggal_lahir'] ?? '').toString(),
      jumlahPoin: _toInt(json['jumlah_poin']),
      noTelp: (json['no_telp'] ?? '').toString(),
      saldo: _toInt(json['saldo']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id_customer': idCustomer,
        'nama': nama,
        'email': email,
        'tanggal_lahir': tanggalLahir,
        'jumlah_poin': jumlahPoin,
        'no_telp': noTelp,
        'saldo': saldo,
      };

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }
}
