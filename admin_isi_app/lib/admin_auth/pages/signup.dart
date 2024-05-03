import 'package:flutter/material.dart';
import '../../components/background.dart';
import '../../components/signup/sign_up_top_image.dart';
import '../../components/signup/signup_form.dart'; // Adjust path if necessary

class SignUp extends StatelessWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(
                  "Admin Sign Up",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                ),
              ),
              SignUpScreenTopImage(),
              SignUpForm(),
            ],
          ),
        ),
      ),
    );
  }
}
