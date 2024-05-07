import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ForgotPasswordView extends StatefulWidget {
  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailController = TextEditingController();

  Future<void> _onPressedForgotPassword() async {
    final String apiUrl = 'http://10.0.2.2:8000/api/customer/forgetPassword/';
    final String email = _emailController.text.trim();

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{'email': email}),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String message = responseData['error'];
      final String email = responseData['data']['email'];

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Forgot Password'),
            content: Text('Email sent to $email. Message: $message'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Failed to send email');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _onPressedForgotPassword,
              child: Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
