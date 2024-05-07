import 'dart:convert';
import 'package:atma_kitchen_mobile/model/karyawan_model.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class EmployeeService {
  static Future<KaryawanModel> getEmployeeInfo() async {
    String apiURL =
        'http://10.0.2.2:8000/api/karyawan/'; // Note the change to localhost
    try {
      String uid = sharedPrefs.getString("id_employee") as String;
      String token = sharedPrefs.getString("token") as String;
      var apiResult = await http.get(Uri.parse(apiURL + uid),
          headers: Map.from({"Authorization": "Bearer " + token}));

      if (apiResult.statusCode == 200) {
        var responseData = json.decode(apiResult.body);
        return KaryawanModel.fromJson(responseData["data"]);
      } else {
        return KaryawanModel.fromJson({});
      }
    } catch (e) {
      print(e); // Optionally log the error
      return KaryawanModel.fromJson({});
    }
  }
}
