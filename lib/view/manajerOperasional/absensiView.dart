import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/view/manajerOperasional/presensiView.dart';

class AbsensiView extends StatefulWidget {
  final List<Employee> dismissedEmployees;

  AbsensiView({required this.dismissedEmployees});

  @override
  _AbsensiViewState createState() => _AbsensiViewState();
}

class _AbsensiViewState extends State<AbsensiView> {
  late List<Employee> filteredEmployees;
  TextEditingController _dateFilterController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Tambahkan variabel untuk menyimpan tanggal yang dipilih

  @override
  void initState() {
    super.initState();
    filteredEmployees = widget.dismissedEmployees;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Tidak Masuk'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _dateFilterController,
                    decoration: InputDecoration(
                      labelText: 'Filter Tanggal (YYYY-MM-DD)',
                    ),
                    readOnly: true,
                    onTap: () => _selectDate(context), // Tampilkan date picker ketika tombol ditekan
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context), // Tampilkan date picker ketika tombol ditekan
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredEmployees.length,
              itemBuilder: (BuildContext context, int index) {
                final Employee employee = filteredEmployees[index];
                return ListTile(
                  title: Text(employee.name),
                  subtitle: Text('Tanggal: ${employee.date}'), // Gunakan tanggal dari data employee
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // Tentukan tanggal awal yang ditampilkan
      firstDate: DateTime(2000), // Batasi tanggal yang dapat dipilih
      lastDate: DateTime(2100), // Batasi tanggal yang dapat dipilih
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
        _dateFilterController.text = _selectedDate.toString().split(' ')[0]; // Update text field dengan tanggal yang dipilih
        filteredEmployees = widget.dismissedEmployees.where((employee) =>
            employee.date == _selectedDate.toString().split(' ')[0]).toList(); // Filter berdasarkan tanggal yang dipilih
      });
    }
  }
}
