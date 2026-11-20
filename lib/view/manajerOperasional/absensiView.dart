import 'package:atma_kitchen_mobile/auth_service/absensi_service.dart';
import 'package:atma_kitchen_mobile/model/absensi_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AbsensiView extends StatefulWidget {
  const AbsensiView({super.key});

  @override
  State<AbsensiView> createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<AbsensiView> {
  final TextEditingController _dateFilterController = TextEditingController();
  List<AbsensiModel> _records = [];
  DateTime? _selectedDate;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAbsensi();
  }

  @override
  void dispose() {
    _dateFilterController.dispose();
    super.dispose();
  }

  Future<void> _loadAbsensi() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tanggal = _selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
          : null;
      final data = await AbsensiService.fetchAbsensi(tanggal: tanggal);
      if (!mounted) return;
      setState(() {
        _records = data;
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateFilterController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
      _loadAbsensi();
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
      _dateFilterController.clear();
    });
    _loadAbsensi();
  }

  Future<void> _deleteRecord(AbsensiModel record) async {
    try {
      await AbsensiService.deleteAttendance(record.idAbsensi);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Catatan absensi ${record.namaKaryawan} dihapus'),
        ),
      );
      _loadAbsensi();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Karyawan Tidak Masuk'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAbsensi,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _dateFilterController,
                        readOnly: true,
                        onTap: _selectDate,
                        decoration: const InputDecoration(
                          labelText: 'Filter Tanggal (YYYY-MM-DD)',
                          hintText: 'Semua tanggal',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                    ),
                    if (_selectedDate != null) ...[
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: _clearFilter,
                        child: const Text('Semua'),
                      ),
                    ],
                  ],
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
                                  onPressed: _loadAbsensi,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : _records.isEmpty
                            ? const Center(
                                child: Text('Tidak ada data ketidakhadiran'),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                itemCount: _records.length,
                                itemBuilder: (context, index) {
                                  final item = _records[index];
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: Colors.red.shade100,
                                        child: Icon(
                                          Icons.event_busy,
                                          color: Colors.red.shade800,
                                        ),
                                      ),
                                      title: Text(
                                        item.namaKaryawan,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        '${item.jabatan}  •  Tanggal: ${item.tanggal}',
                                      ),
                                      trailing: IconButton(
                                        tooltip: 'Hapus catatan absensi',
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _deleteRecord(item),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
