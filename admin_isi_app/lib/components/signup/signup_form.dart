import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/admin_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:namer_app/admin_auth/pages/login.dart';
import 'package:namer_app/admin_auth/widgets/form_container_widget.dart';
import 'package:namer_app/global/toast.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../components/already_have_an_account_acheck.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpForm> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  TextEditingController _usernameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isSigningUp = false;
  File? _imageFile;

  Future<void> _pickImage() async {
    final  pickedFile = await ImagePicker().getImage(source: ImageSource.gallery);;
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);;
        });
      }
    }


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.grey[300],
              backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
              child: _imageFile == null ? Icon(Icons.add_a_photo, size: 30, color: Color(0xFF048304)) : null,
            ),
          ),
          SizedBox(height: 20),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: "Username",
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: "Email",
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email';
              } else if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Password",
              prefixIcon: Icon(Icons.lock),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          SizedBox(
            width : 200,
            child: ElevatedButton(
            onPressed: isSigningUp ? null : _signUp,
            child: isSigningUp
                ? CircularProgressIndicator(color: Colors.white)
                : Text("SIGN UP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF0101FE).withOpacity(0.8),
              shape: StadiumBorder(),
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
          ),
          SizedBox(height: 16),
          AlreadyHaveAnAccountCheck(
            login: false,
            press: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()),
              );
            },
            textColor: Color(0xFF048304),
          ),
        ],
      ),
    );
  }


  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    try {
      User? user = await _auth.signUpWithEmailAndPassword(email, password);

      if (user != null) {
        // Upload image to Firebase Storage
        String? imageUrl;
        if (_imageFile != null) {
          final ref = firebase_storage.FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child(user.uid + '.jpg');
          await ref.putFile(_imageFile!);
          imageUrl = await ref.getDownloadURL();
        }

        // Update user profile
        await user.updateDisplayName(username);
        await user.updatePhotoURL(imageUrl);

        showToast(message: "User successfully created");
        Navigator.pushNamed(context, "/");
      }
    } catch (e) {
      showToast(message: "Error occurred: $e");
    } finally {
      setState(() {
        isSigningUp = false;
      });
    }
  }

}
