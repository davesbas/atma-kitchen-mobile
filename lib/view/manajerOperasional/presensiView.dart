import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/view/manajerOperasional/absensiView.dart';

void main() {
  runApp(MaterialApp(
    home: AttendanceManagementPage(),
  ));
}

class AttendanceManagementPage extends StatefulWidget {
  @override
  _AttendanceManagementPageState createState() => _AttendanceManagementPageState();
}

class _AttendanceManagementPageState extends State<AttendanceManagementPage> {
List<Employee> employees = [
  Employee(name: 'John Doe', isPresent: true, date: '2024-04-24'),
  Employee(name: 'Jane Smith', isPresent: true, date: '2024-04-25'),
  Employee(name: 'Alice Johnson', isPresent: true, date: '2024-04-16'),
  Employee(name: 'Bob Brown', isPresent: true, date: '2024-04-15'),
];


  List<Employee> dismissedEmployees = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance Management'),
      ),
      body: ListView.builder(
        itemCount: employees.length,
        itemBuilder: (BuildContext context, int index) {
          final Employee employee = employees[index];
          return Dismissible(
            key: Key(employee.name),
            background: Container(
              color: Colors.red,
              child: Center(
                child: Text(
                  'Tidak Masuk',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ),
            onDismissed: (direction) {
              setState(() {
                employees.removeAt(index); // Remove the dismissed employee
                dismissedEmployees.add(employee); // Add dismissed employee to dismissedEmployees list
              });
            },
            child: ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.name),
                  Text('Date: ${DateTime.now().toString().split(' ')[0]}'), // Display current date
                ],
              ),
              trailing: employee.isPresent
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : Icon(Icons.cancel, color: Colors.red),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AbsensiView(dismissedEmployees: dismissedEmployees),
            ),
          );
        },
        child: Icon(Icons.list),
      ),
    );
  }
}


class Employee {
  String name;
  bool isPresent;
  String date;

  Employee({required this.name, required this.isPresent, required this.date});
}