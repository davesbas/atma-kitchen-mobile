import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/model/karyawan_model.dart'; // Pastikan import model karyawan sesuai dengan struktur Anda
import 'package:atma_kitchen_mobile/auth_service/karyawan_service.dart'; // Pastikan import service employee sesuai dengan struktur Anda

class AttendanceManagementPage extends StatefulWidget {
  @override
  _AttendanceViewPageState createState() => _AttendanceViewPageState();
}

class _AttendanceViewPageState extends State<AttendanceManagementPage> {
  List<KaryawanModel> _employees = []; // List untuk menyimpan data karyawan

  @override
  void initState() {
    super.initState();
    _loadEmployees(); // Memuat data karyawan saat halaman dimuat
  }

  // Fungsi untuk memuat data karyawan dari service
  Future<void> _loadEmployees() async {
    try {
      KaryawanModel employee = await EmployeeService.getEmployeeInfo();
      setState(() {
        _employees.add(employee);
      });
    } catch (e) {
      // Tangani kesalahan saat memuat data
      print("Error loading employees: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance View'),
      ),
      body: _employees.isNotEmpty
          ? ListView.builder(
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title:
                      Text(_employees[index].nama), // Menampilkan nama karyawan
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Tambahkan fungsi untuk tombol absen di sini
                      // Contoh: _absen(_employees[index].id_karyawan);
                    },
                    child: Text('Absen'),
                  ),
                );
              },
            )
          : Center(
              child:
                  CircularProgressIndicator(), // Indikator loading jika data belum dimuat
            ),
    );
  }
}
