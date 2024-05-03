import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/admin_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:namer_app/admin_auth/pages/signup.dart';
import 'package:namer_app/global/toast.dart';

import '../already_have_an_account_acheck.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FirebaseAuthService _auth = FirebaseAuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSigning = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: Icon(Icons.email, color: Color(0xFF048304)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              filled: true,
              fillColor: Colors.grey[200],
              prefixIcon: Icon(Icons.lock, color: Color(0xFF048304)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
          SizedBox(height: 20),
      SizedBox(
        width: 200,
        child: ElevatedButton(
            onPressed: _isSigning ? null : _signIn,
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF0101FE).withOpacity(0.8),
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(vertical: 15),
            ),
            child: _isSigning
                ? CircularProgressIndicator(color: Colors.white)
                : Text("LOGIN".toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold)),
          ),
      ),
          SizedBox(height: 20),
          AlreadyHaveAnAccountCheck(
            login: true,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SignUp()),
              );
            },
            textColor: Color(0xFF048304),
          ),
        ],
      ),
    );
  }


  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      User? user = await _auth.signInWithEmailAndPassword(email, password);
      if (user != null) {
        showToast(message: "User is successfully signed in");
        Navigator.pushNamed(context, "/home");
      } else {
        showToast(message: "Missing credentials");
      }
    } catch (e) {
      // Handle sign-in errors
      print("Error signing in: $e");
      showToast(message: "Error signing in");
    } finally {
      setState(() {
        _isSigning = false;
      });
    }
  }
}
