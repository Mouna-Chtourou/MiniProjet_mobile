// admin_auth/pages/login.dart
import 'package:flutter/material.dart';
import 'package:namer_app/components/background.dart';
import '../../components/login/login_form.dart';
import '../../components/login/login_screen_top_image.dart';

class Login extends StatelessWidget {
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 40),
              Text("Admin Login", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
              LoginScreenTopImage(),
              LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}
