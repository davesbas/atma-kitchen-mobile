import 'package:atma_kitchen_mobile/client/order_client.dart';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/order_model.dart';
import 'package:flutter/material.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({String? search}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final orders = await OrderClient.fetchOrders(search: search);
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  Future<void> _confirmReceived(OrderModel order) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan Diterima'),
        content: Text(
          'Apakah Anda yakin pesanan #${order.idTransaksi} sudah diterima dengan baik?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Sudah Diterima'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      final msg = await OrderClient.confirmOrderSelesai(order.idTransaksi);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700),
      );
      _loadOrders(search: _searchController.text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s == 'selesai') return Colors.green;
    if (s == 'dibatalkan' || s == 'ditolak') return Colors.red;
    if (s.contains('kirim') || s == 'diproses' || s == 'siap diambil') {
      return Colors.blue;
    }
    return Colors.orange;
  }

  void _showOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Detail Pesanan #${order.idTransaksi}'),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Status: ${order.status.toUpperCase()}'),
                Text('Tanggal Transaksi: ${order.tglTransaksi}'),
                Text('Tanggal Ambil/Kirim: ${order.tglAmbil}'),
                Text('Pembayaran: ${order.jenisPembayaran}'),
                if (order.pengiriman != null) ...[
                  Text('Pengiriman: ${order.pengiriman!.jenis}'),
                  if (order.pengiriman!.alamat != null)
                    Text('Alamat: ${order.pengiriman!.alamat!.fullAddress}'),
                ],
                if (order.fotoBukti != null && order.fotoBukti!.isNotEmpty)
                  Text('Catatan/Bukti Bayar: ${order.fotoBukti}'),
                const Divider(height: 20),
                const Text(
                  'Item Pesanan:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                ...order.items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('- ${item.produk.nama} x${item.jumlah}'),
                        ),
                        Text(ApiConfig.formatRupiah(item.lineTotal)),
                      ],
                    ),
                  ),
                ),
                if (order.poinUsedValue > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Potongan Poin: -${ApiConfig.formatRupiah(order.poinUsedValue)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
                const Divider(height: 20),
                Text(
                  'Total: ${ApiConfig.formatRupiah(order.totalHarga)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          if (order.canConfirmReceived)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmReceived(order);
              },
              child: const Text('Konfirmasi Diterima'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadOrders(search: _searchController.text),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama produk...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: () =>
                          _loadOrders(search: _searchController.text),
                    ),
                  ),
                  onSubmitted: (v) => _loadOrders(search: v),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(_error!),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _loadOrders(),
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : _orders.isEmpty
                            ? const Center(
                                child: Text('Belum ada riwayat pesanan'),
                              )
                            : RefreshIndicator(
                                onRefresh: () =>
                                    _loadOrders(search: _searchController.text),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  itemCount: _orders.length,
                                  itemBuilder: (context, index) {
                                    final order = _orders[index];
                                    final itemPreview = order.items
                                        .map((e) =>
                                            '${e.produk.nama} (x${e.jumlah})')
                                        .join(', ');

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(14),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Pesanan #${order.idTransaksi}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                Chip(
                                                  label: Text(
                                                    order.status.toUpperCase(),
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      _statusColor(order.status),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              itemPreview.isEmpty
                                                  ? 'Tidak ada detail item'
                                                  : itemPreview,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              'Ambil/Kirim: ${order.tglAmbil}  •  ${order.jenisPembayaran}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.black54,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  ApiConfig.formatRupiah(
                                                      order.totalHarga),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                  ),
                                                ),
                                                Wrap(
                                                  spacing: 8,
                                                  children: [
                                                    OutlinedButton(
                                                      onPressed: () =>
                                                          _showOrderDetails(
                                                              order),
                                                      child:
                                                          const Text('Detail'),
                                                    ),
                                                    if (order
                                                        .canConfirmReceived)
                                                      ElevatedButton(
                                                        onPressed: () =>
                                                            _confirmReceived(
                                                                order),
                                                        child: const Text(
                                                          'Pesanan Diterima',
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
