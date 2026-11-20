import 'package:atma_kitchen_mobile/auth_service/absensi_service.dart';
import 'package:atma_kitchen_mobile/auth_service/karyawan_service.dart';
import 'package:atma_kitchen_mobile/controller/login_controller.dart';
import 'package:atma_kitchen_mobile/model/absensi_model.dart';
import 'package:atma_kitchen_mobile/model/karyawan_model.dart';
import 'package:atma_kitchen_mobile/view/manajerOperasional/absensiView.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AttendanceManagementPage extends StatefulWidget {
  const AttendanceManagementPage({super.key});

  @override
  State<AttendanceManagementPage> createState() =>
      _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
  List<KaryawanModel> _employees = [];
  Map<int, AbsensiModel> _absentByEmployeeId = {};
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = true;
  int? _busyEmployeeId;
  String? _error;

  String get _formattedDate => DateFormat('yyyy-MM-dd').format(_selectedDate);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        EmployeeService.fetchAllEmployees(),
        AbsensiService.fetchAbsensi(tanggal: _formattedDate),
      ]);

      if (!mounted) return;
      final employees = results[0] as List<KaryawanModel>;
      final absensiList = results[1] as List<AbsensiModel>;

      setState(() {
        _employees = employees;
        _absentByEmployeeId = {
          for (final a in absensiList) a.idKaryawan: a,
        };
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
      _loadData();
    }
  }

  Future<void> _toggleAbsence(KaryawanModel employee) async {
    setState(() => _busyEmployeeId = employee.idKaryawan);
    try {
      final existing = _absentByEmployeeId[employee.idKaryawan];
      if (existing != null) {
        await AbsensiService.deleteAttendance(existing.idAbsensi);
        if (!mounted) return;
        setState(() => _absentByEmployeeId.remove(employee.idKaryawan));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status tidak masuk ${employee.nama} pada $_formattedDate dibatalkan',
            ),
          ),
        );
      } else {
        final created = await AbsensiService.markAttendance(
          employee.idKaryawan,
          tanggal: _formattedDate,
        );
        if (!mounted) return;
        setState(() => _absentByEmployeeId[employee.idKaryawan] = created);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${employee.nama} dicatat tidak masuk pada $_formattedDate',
            ),
            backgroundColor: Colors.orange.shade800,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _busyEmployeeId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Karyawan (MO)'),
        actions: [
          IconButton(
            tooltip: 'Daftar Tidak Masuk',
            icon: const Icon(Icons.list_alt),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AbsensiView()),
              );
              _loadData();
            },
          ),
          IconButton(
            tooltip: 'Muat Ulang',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => LoginController.logout(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Column(
            children: [
              Card(
                margin: const EdgeInsets.all(16),
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal Presensi'),
                  subtitle: Text(
                    '$_formattedDate  •  Tidak Masuk: ${_absentByEmployeeId.length} / ${_employees.length}',
                  ),
                  trailing: OutlinedButton(
                    onPressed: _pickDate,
                    child: const Text('Pilih Tanggal'),
                  ),
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
                                  onPressed: _loadData,
                                  child: const Text('Coba Lagi'),
                                ),
                              ],
                            ),
                          )
                        : _employees.isEmpty
                            ? const Center(
                                child: Text('Belum ada data karyawan'),
                              )
                            : RefreshIndicator(
                                onRefresh: _loadData,
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  itemCount: _employees.length,
                                  itemBuilder: (context, index) {
                                    final emp = _employees[index];
                                    final isAbsent = _absentByEmployeeId
                                        .containsKey(emp.idKaryawan);
                                    final isBusy =
                                        _busyEmployeeId == emp.idKaryawan;

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: isAbsent
                                              ? Colors.red.shade100
                                              : Colors.green.shade100,
                                          child: Icon(
                                            isAbsent
                                                ? Icons.person_off
                                                : Icons.person,
                                            color: isAbsent
                                                ? Colors.red.shade800
                                                : Colors.green.shade800,
                                          ),
                                        ),
                                        title: Text(
                                          emp.nama,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${emp.jabatanNama.isEmpty ? 'Karyawan' : emp.jabatanNama}  •  Status: ${isAbsent ? 'Tidak Masuk' : 'Hadir'}',
                                        ),
                                        trailing: isBusy
                                            ? const SizedBox(
                                                width: 24,
                                                height: 24,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                ),
                                              )
                                            : isAbsent
                                                ? OutlinedButton(
                                                    onPressed: () =>
                                                        _toggleAbsence(emp),
                                                    child:
                                                        const Text('Batalkan'),
                                                  )
                                                : ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.red.shade700,
                                                    ),
                                                    onPressed: () =>
                                                        _toggleAbsence(emp),
                                                    child: const Text(
                                                      'Catat Absen',
                                                    ),
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
