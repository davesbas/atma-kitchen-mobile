import 'package:http/http.dart' as http;

void markAttendance(int idKaryawan) async {
  String apiUrl = 'http://10.0.2.2:8000/api/absensi/store';

  try {
    // Make a POST request with the employee ID
    var response = await http.post(
      Uri.parse(apiUrl),
      body: {'id_karyawan': idKaryawan.toString()},
    );

    if (response.statusCode == 200) {
      print('Attendance marked successfully.');
    } else {
      print('Failed to mark attendance. Error: ${response.statusCode}');
    }
  } catch (e) {
    print('Error marking attendance: $e');
  }
}
