import 'package:atma_kitchen_mobile/auth_service/customer_service.dart';
import 'package:atma_kitchen_mobile/config/api_config.dart';
import 'package:atma_kitchen_mobile/model/saldo_model.dart';
import 'package:flutter/material.dart';

class SaldoView extends StatefulWidget {
  const SaldoView({super.key});

  @override
  State<SaldoView> createState() => _SaldoViewState();
}

class _SaldoViewState extends State<SaldoView> {
  SaldoInfoModel? _saldoInfo;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _bankController = TextEditingController();
  final _noRekController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSaldo();
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _bankController.dispose();
    _noRekController.dispose();
    super.dispose();
  }

  Future<void> _loadSaldo() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final info = await CustomerService.getSaldoInfo();
      if (!mounted) return;
      setState(() {
        _saldoInfo = info;
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

  Future<void> _submitPenarikan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final msg = await CustomerService.requestPenarikanSaldo(
        jumlahPenarikan: int.parse(_jumlahController.text.trim()),
        bank: _bankController.text.trim(),
        noRek: _noRekController.text.trim(),
      );

      if (!mounted) return;
      _jumlahController.clear();
      _bankController.clear();
      _noRekController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.green.shade700),
      );
      _loadSaldo();
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

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'selesai':
        return Colors.green;
      case 'failed':
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saldo & Penarikan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSaldo,
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
                        onPressed: _loadSaldo,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: colorScheme.primary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Saldo Tersedia',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    ApiConfig.formatRupiah(_saldoInfo?.saldo ?? 0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Poin Loyalitas: ${_saldoInfo?.jumlahPoin ?? 0} poin',
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.account_balance_wallet,
                                size: 48,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Ajukan Penarikan Saldo',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _jumlahController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Jumlah Penarikan (min. Rp 10.000)',
                                      prefixIcon: Icon(Icons.money),
                                    ),
                                    validator: (v) {
                                      final n = int.tryParse(v?.trim() ?? '');
                                      if (n == null || n < 10000) {
                                        return 'Minimal penarikan Rp 10.000';
                                      }
                                      if (n > (_saldoInfo?.saldo ?? 0)) {
                                        return 'Melebihi saldo tersedia';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _bankController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama Bank (mis. BCA, Mandiri, BRI)',
                                      prefixIcon: Icon(Icons.account_balance),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().isEmpty)
                                            ? 'Nama bank wajib diisi'
                                            : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _noRekController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      labelText: 'Nomor Rekening',
                                      prefixIcon: Icon(Icons.credit_card),
                                    ),
                                    validator: (v) =>
                                        (v == null || v.trim().length < 6)
                                            ? 'Nomor rekening tidak valid'
                                            : null,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed:
                                        _isSubmitting ? null : _submitPenarikan,
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          )
                                        : const Text('Ajukan Penarikan'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'Riwayat Pengajuan Penarikan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_saldoInfo == null ||
                            _saldoInfo!.riwayatPenarikan.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Center(
                                child: Text('Belum ada riwayat penarikan saldo'),
                              ),
                            ),
                          )
                        else
                          ..._saldoInfo!.riwayatPenarikan.map(
                            (p) => Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(
                                  ApiConfig.formatRupiah(p.jumlahPenarikan),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${p.bank} - ${p.noRek}'),
                                trailing: Chip(
                                  label: Text(
                                    p.status.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                  backgroundColor: _statusColor(p.status),
                                ),
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
