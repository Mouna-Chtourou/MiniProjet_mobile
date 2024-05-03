import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:student_isi_app/api/firebase_api.dart';
import 'package:student_isi_app/firebase_options.dart';
import 'package:student_isi_app/student_auth/home.dart';
import 'package:student_isi_app/student_auth/login.dart';
import 'package:student_isi_app/student_auth/signup.dart';
import 'package:student_isi_app/welcome_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseApi().initNotifications();

  runApp(MyApp());
}
const grey =  Color(0xFFF0F0F0);

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ISI App',
      theme: ThemeData(
          primaryColor: Color(0xFF0101FE).withOpacity(0.5),
          scaffoldBackgroundColor: Colors.white,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0,
              foregroundColor: Colors.white,
              backgroundColor: Color(0xFF0101FE).withOpacity(0.8),
              shape: const StadiumBorder(),
              maximumSize: const Size(double.infinity, 56),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: grey,
            prefixIconColor: Color(0xFF048304),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              borderSide: BorderSide.none,
            ),
          )
      ),
        initialRoute: '/',
        routes: {
        '/': (context) => AnimatedSplashScreen(
          duration: 4000,
          splash: Image.asset('assets/logo.png', height: 100, width: 100,),
          nextScreen: WelcomeScreen(),
          splashTransition: SplashTransition.fadeTransition,
          backgroundColor: Colors.white,
        ),
        '/login': (context) => const Login(),
        '/home': (context) => const Home(),
      },
    );
  }
  }

