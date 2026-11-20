import 'package:atma_kitchen_mobile/client/cart_client.dart';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/cart_model.dart';
import 'package:atma_kitchen_mobile/view/history_pemesanan/history_view.dart';
import 'package:flutter/material.dart';

class CheckoutView extends StatefulWidget {
  final CartModel initialCart;
  final String tglAmbil;
  final String jenisPengiriman;
  final int? idAlamat;

  const CheckoutView({
    super.key,
    required this.initialCart,
    required this.tglAmbil,
    required this.jenisPengiriman,
    this.idAlamat,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  late CartModel _cart;
  String _jenisPembayaran = 'Bank Transfer';
  final TextEditingController _buktiController = TextEditingController();
  bool _isUpdating = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _cart = widget.initialCart;
  }

  @override
  void dispose() {
    _buktiController.dispose();
    super.dispose();
  }

  Future<void> _onTogglePoin(bool value) async {
    setState(() => _isUpdating = true);
    try {
      final updated = await CartClient.togglePoin(value);
      if (!mounted) return;
      setState(() => _cart = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _submitCheckout() async {
    if (_jenisPembayaran == 'Saldo' && _cart.customerSaldo < _cart.subtotal) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo Anda tidak mencukupi. Pilih Bank Transfer.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final order = await CartClient.checkout(
        jenisPembayaran: _jenisPembayaran,
        tglAmbil: widget.tglAmbil,
        jenisPengiriman: widget.jenisPengiriman,
        idAlamat: widget.idAlamat,
        usePoin: _cart.usePoin,
        catatanBukti: _buktiController.text.trim(),
      );

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Text('Pesanan Berhasil'),
            ],
          ),
          content: Text(
            'Pesanan #${order.idTransaksi} berhasil dibuat!\n'
            'Total: ${ApiConfig.formatRupiah(order.totalHarga)}\n'
            'Metode: ${order.jenisPembayaran}\n'
            'Status: ${order.status}',
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Lihat Riwayat Pesanan'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final saldoCukup = _cart.customerSaldo >= _cart.subtotal;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Pesanan')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_isUpdating) const LinearProgressIndicator(),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ringkasan Item',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ..._cart.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('${item.produk.nama} x${item.jumlah}'),
                              ),
                              Text(ApiConfig.formatRupiah(item.lineTotal)),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 20),
                      Text('Tanggal Ambil/Kirim: ${widget.tglAmbil}'),
                      Text('Metode Pengiriman: ${widget.jenisPengiriman}'),
                      if (_cart.pengiriman?.alamat != null)
                        Text('Alamat: ${_cart.pengiriman!.alamat!.fullAddress}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: SwitchListTile(
                  title: const Text('Tukar Poin Loyalitas'),
                  subtitle: Text(
                    'Poin tersedia: ${_cart.customerPoin} poin (Senilai ${ApiConfig.formatRupiah(_cart.customerPoin * 100)})',
                  ),
                  value: _cart.usePoin,
                  onChanged: (_cart.customerPoin <= 0 || _isUpdating)
                      ? null
                      : _onTogglePoin,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Metode Pembayaran',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Bank Transfer (BCA 1234-5678-90 a.n. Atma Kitchen)'),
                        subtitle: const Text('Menunggu verifikasi admin'),
                        value: 'Bank Transfer',
                        groupValue: _jenisPembayaran,
                        onChanged: (v) => setState(() => _jenisPembayaran = v!),
                      ),
                      RadioListTile<String>(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'Bayar dengan Saldo (${ApiConfig.formatRupiah(_cart.customerSaldo)})',
                        ),
                        subtitle: Text(
                          saldoCukup
                              ? 'Langsung terverifikasi & diproses'
                              : 'Saldo tidak mencukupi',
                          style: TextStyle(
                            color: saldoCukup ? Colors.green.shade700 : Colors.red,
                          ),
                        ),
                        value: 'Saldo',
                        groupValue: _jenisPembayaran,
                        onChanged: (v) => setState(() => _jenisPembayaran = v!),
                      ),
                      if (_jenisPembayaran == 'Bank Transfer') ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _buktiController,
                          decoration: const InputDecoration(
                            labelText: 'Nomor Referensi / Catatan Transfer (opsional)',
                            hintText: 'Contoh: TRF-BCA-982312',
                            prefixIcon: Icon(Icons.receipt),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _RowLine('Total Harga Item',
                          ApiConfig.formatRupiah(_cart.totalItemPrice)),
                      _RowLine('Pajak (11%)', ApiConfig.formatRupiah(_cart.taxes)),
                      _RowLine('Ongkir', ApiConfig.formatRupiah(_cart.ongkir)),
                      if (_cart.poinUsedValue > 0)
                        _RowLine(
                          'Potongan Poin',
                          '- ${ApiConfig.formatRupiah(_cart.poinUsedValue)}',
                          valueColor: Colors.green.shade700,
                        ),
                      const Divider(height: 24),
                      _RowLine(
                        'Total Bayar',
                        ApiConfig.formatRupiah(_cart.subtotal),
                        bold: true,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting ? null : _submitCheckout,
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: const Text('Konfirmasi & Buat Pesanan'),
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

class _RowLine extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _RowLine(this.label, this.value, {this.bold = false, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 17 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 17 : 14,
              fontWeight: bold ? FontWeight.bold : FontWeight.w500,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
