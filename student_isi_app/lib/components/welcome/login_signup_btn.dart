import 'package:flutter/material.dart';

import '../../student_auth/login.dart';
import '../../student_auth/signup.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const Login();
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF0101FE),
            elevation: 0,
          ),
          child: Text(
            "Login".toUpperCase(),
            style: const TextStyle(color: Colors.white),

          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const SignUp();
                },
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFB3B3FF),
            elevation: 0,
          ),
          child: Text(
            "Sign Up".toUpperCase(),
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ],
    );
  }
}
