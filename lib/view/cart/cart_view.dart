import 'package:atma_kitchen_mobile/auth_service/customer_service.dart';
import 'package:atma_kitchen_mobile/client/cart_client.dart';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/cart_model.dart';
import 'package:atma_kitchen_mobile/view/cart/checkout_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  CartModel _cart = CartModel.empty();
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _error;

  String _selectedJenis = 'Pickup';
  int? _selectedAlamatId;
  String _selectedTglAmbil =
      DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1)));

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  void _syncSelectionFromCart(CartModel cart) {
    _cart = cart;
    if (cart.tglAmbil != null && cart.tglAmbil!.isNotEmpty) {
      _selectedTglAmbil = cart.tglAmbil!;
    }
    if (cart.pengiriman != null) {
      _selectedJenis = cart.pengiriman!.jenis == 'Delivery' ? 'Delivery' : 'Pickup';
      _selectedAlamatId = cart.pengiriman!.idAlamat;
    }
    if (_selectedJenis == 'Delivery' &&
        _selectedAlamatId == null &&
        cart.alamatList.isNotEmpty) {
      _selectedAlamatId = cart.alamatList.first.idAlamat;
    }
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final cart = await CartClient.fetchCart();
      if (!mounted) return;
      setState(() {
        _syncSelectionFromCart(cart);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _updateQty(CartItemModel item, int newQty) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await CartClient.updateItem(item.idProduk, newQty);
      if (!mounted) return;
      setState(() => _syncSelectionFromCart(updated));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _saveDelivery({
    required String tglAmbil,
    required String jenis,
    int? idAlamat,
  }) async {
    if (jenis == 'Delivery' && idAlamat == null) {
      setState(() {
        _selectedTglAmbil = tglAmbil;
        _selectedJenis = jenis;
      });
      return;
    }

    setState(() => _isUpdating = true);
    try {
      final updated = await CartClient.updateDelivery(
        tglAmbil: tglAmbil,
        jenis: jenis,
        idAlamat: jenis == 'Delivery' ? idAlamat : null,
      );
      if (!mounted) return;
      setState(() => _syncSelectionFromCart(updated));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _pickTglAmbil() async {
    final now = DateTime.now();
    final initial = DateTime.tryParse(_selectedTglAmbil) ?? now.add(const Duration(days: 1));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
    );
    if (picked != null) {
      final formatted = DateFormat('yyyy-MM-dd').format(picked);
      await _saveDelivery(
        tglAmbil: formatted,
        jenis: _selectedJenis,
        idAlamat: _selectedAlamatId,
      );
    }
  }

  Future<void> _showAddAddressDialog() async {
    final jalanCtrl = TextEditingController();
    final kelCtrl = TextEditingController();
    final kecCtrl = TextEditingController();
    final jarakCtrl = TextEditingController(text: '5');
    final formKey = GlobalKey<FormState>();

    final created = await showDialog<AlamatModel>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Alamat Pengiriman'),
        content: SizedBox(
          width: 400,
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: jalanCtrl,
                    decoration: const InputDecoration(labelText: 'Nama Jalan / Alamat'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: kelCtrl,
                    decoration: const InputDecoration(labelText: 'Kelurahan'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: kecCtrl,
                    decoration: const InputDecoration(labelText: 'Kecamatan'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: jarakCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Perkiraan Jarak (km)',
                      helperText: 'Ongkir Rp 2.000 / km',
                    ),
                    validator: (v) {
                      final n = int.tryParse(v ?? '');
                      if (n == null || n < 1 || n > 50) return 'Masukkan 1 - 50 km';
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                final alamat = await CustomerService.addAddress(
                  namaJalan: jalanCtrl.text.trim(),
                  kelurahan: kelCtrl.text.trim(),
                  kecamatan: kecCtrl.text.trim(),
                  jarak: int.parse(jarakCtrl.text.trim()),
                );
                if (ctx.mounted) Navigator.pop(ctx, alamat);
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                  );
                }
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (created != null) {
      await _saveDelivery(
        tglAmbil: _selectedTglAmbil,
        jenis: 'Delivery',
        idAlamat: created.idAlamat,
      );
    }
  }

  Future<void> _goToCheckout() async {
    if (_cart.items.isEmpty) return;
    if (_selectedJenis == 'Delivery' && _selectedAlamatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih atau tambahkan alamat pengiriman dahulu'),
        ),
      );
      return;
    }

    await _saveDelivery(
      tglAmbil: _selectedTglAmbil,
      jenis: _selectedJenis,
      idAlamat: _selectedAlamatId,
    );

    if (!mounted) return;
    final checkedOut = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutView(
          initialCart: _cart,
          tglAmbil: _selectedTglAmbil,
          jenisPengiriman: _selectedJenis,
          idAlamat: _selectedAlamatId,
        ),
      ),
    );

    if (checkedOut == true && mounted) {
      Navigator.pop(context, true);
    } else {
      _loadCart();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: _loadCart,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _cart.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.shopping_cart_outlined,
                              size: 72, color: Colors.grey),
                          const SizedBox(height: 12),
                          const Text(
                            'Keranjang Anda masih kosong',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Lihat Menu'),
                          ),
                        ],
                      ),
                    )
                  : Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (_isUpdating) const LinearProgressIndicator(),
                            const SizedBox(height: 8),
                            const Text(
                              'Daftar Item',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ..._cart.items.map((item) {
                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      width: 58,
                                      height: 58,
                                      child: item.produk.gambar.isEmpty
                                          ? Container(
                                              color: Colors.brown.shade50,
                                              child: const Icon(Icons.cake),
                                            )
                                          : Image.network(
                                              item.produk.gambar,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                color: Colors.brown.shade50,
                                                child: const Icon(Icons.cake),
                                              ),
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    item.produk.nama,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(ApiConfig.formatRupiah(item.produk.harga)),
                                      Text(
                                        'Subtotal: ${ApiConfig.formatRupiah(item.lineTotal)}',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.remove_circle_outline),
                                        onPressed: _isUpdating
                                            ? null
                                            : () => _updateQty(item, item.jumlah - 1),
                                      ),
                                      Text(
                                        '${item.jumlah}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline),
                                        onPressed: _isUpdating
                                            ? null
                                            : () => _updateQty(item, item.jumlah + 1),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        onPressed: _isUpdating
                                            ? null
                                            : () => _updateQty(item, 0),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Jadwal & Pengiriman',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.calendar_month),
                                      title: const Text('Tanggal Ambil / Kirim'),
                                      subtitle: Text(_selectedTglAmbil),
                                      trailing: OutlinedButton(
                                        onPressed: _pickTglAmbil,
                                        child: const Text('Ubah'),
                                      ),
                                    ),
                                    const Divider(),
                                    const Text('Metode Penerimaan:'),
                                    const SizedBox(height: 8),
                                    SegmentedButton<String>(
                                      segments: const [
                                        ButtonSegment(
                                          value: 'Pickup',
                                          label: Text('Ambil di Toko (Pickup)'),
                                          icon: Icon(Icons.store),
                                        ),
                                        ButtonSegment(
                                          value: 'Delivery',
                                          label: Text('Kurir (Delivery)'),
                                          icon: Icon(Icons.local_shipping),
                                        ),
                                      ],
                                      selected: {_selectedJenis},
                                      onSelectionChanged: (set) {
                                        final next = set.first;
                                        int? addrId = _selectedAlamatId;
                                        if (next == 'Delivery' &&
                                            addrId == null &&
                                            _cart.alamatList.isNotEmpty) {
                                          addrId = _cart.alamatList.first.idAlamat;
                                        }
                                        _saveDelivery(
                                          tglAmbil: _selectedTglAmbil,
                                          jenis: next,
                                          idAlamat: addrId,
                                        );
                                      },
                                    ),
                                    if (_selectedJenis == 'Delivery') ...[
                                      const SizedBox(height: 14),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Pilih Alamat:',
                                            style: TextStyle(fontWeight: FontWeight.w600),
                                          ),
                                          TextButton.icon(
                                            onPressed: _showAddAddressDialog,
                                            icon: const Icon(Icons.add_location_alt,
                                                size: 18),
                                            label: const Text('Tambah Alamat'),
                                          ),
                                        ],
                                      ),
                                      if (_cart.alamatList.isEmpty)
                                        const Text(
                                          'Belum ada alamat tersimpan. Klik "Tambah Alamat".',
                                          style: TextStyle(color: Colors.red),
                                        )
                                      else
                                        DropdownButtonFormField<int>(
                                          value: _cart.alamatList.any(
                                                  (a) => a.idAlamat == _selectedAlamatId)
                                              ? _selectedAlamatId
                                              : _cart.alamatList.first.idAlamat,
                                          isExpanded: true,
                                          items: _cart.alamatList
                                              .map(
                                                (a) => DropdownMenuItem<int>(
                                                  value: a.idAlamat,
                                                  child: Text(
                                                    '${a.fullAddress} — Ongkir ${ApiConfig.formatRupiah(a.estimatedOngkir)}',
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                          onChanged: (val) {
                                            if (val != null) {
                                              _saveDelivery(
                                                tglAmbil: _selectedTglAmbil,
                                                jenis: 'Delivery',
                                                idAlamat: val,
                                              );
                                            }
                                          },
                                        ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    _SummaryRow('Total Harga Item',
                                        ApiConfig.formatRupiah(_cart.totalItemPrice)),
                                    _SummaryRow('Pajak (11%)',
                                        ApiConfig.formatRupiah(_cart.taxes)),
                                    _SummaryRow('Ongkir',
                                        ApiConfig.formatRupiah(_cart.ongkir)),
                                    const Divider(height: 24),
                                    _SummaryRow(
                                      'Estimasi Total',
                                      ApiConfig.formatRupiah(_cart.subtotal),
                                      bold: true,
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _isUpdating ? null : _goToCheckout,
                                        icon: const Icon(Icons.payment),
                                        label: const Text('Lanjut ke Checkout'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
