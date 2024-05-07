import 'dart:convert';
import 'package:atma_kitchen_mobile/model/customer_model.dart';
import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:http/http.dart' as http;

class CustomerService {
  static Future<CustomerModel> getUserInfo() async {
    String apiURL = 'http://10.0.2.2:8000/api/customer/';
    try {
      String uid = sharedPrefs.getString("id_customer") as String;
      String token = sharedPrefs.getString("token") as String;
      var apiResult = await http.get(Uri.parse(apiURL + uid),
          headers: Map.from({"Authorization": "Bearer " + token}));

      if (apiResult.statusCode == 200) {
        var responseData = json.decode(apiResult.body);
        return CustomerModel.fromJson(responseData["data"][0]);
      } else {
        return CustomerModel.fromJson({});
      }
    } catch (e) {
      return CustomerModel.fromJson({});
    }
  }
}
