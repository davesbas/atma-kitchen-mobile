import 'package:atma_kitchen_mobile/utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:atma_kitchen_mobile/view/dashboardView.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sharedPrefs = await SharedPreferences.getInstance();
  runApp(MaterialApp(
    home: AtmaKitchenPage(),
  ));
}

void showToast(BuildContext context, String msg, Color bg, IconData icons) {
  FToast fToast = FToast();
  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: bg,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icons, color: Colors.white),
        const SizedBox(
          width: 12.0,
        ),
        Text(
          msg,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: const Duration(seconds: 2),
  );
}
