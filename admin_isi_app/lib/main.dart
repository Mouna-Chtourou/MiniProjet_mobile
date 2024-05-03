import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:namer_app/admin_auth/pages/home.dart';
import 'package:namer_app/admin_auth/pages/login.dart';
import 'package:namer_app/admin_auth/pages/signup.dart';
import 'package:namer_app/firebase_options.dart';
import 'package:namer_app/pages/Forms.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;
  Widget initialRoute = (user != null) ? Home() : Login();

  runApp(MyApp(initialRoute: initialRoute));
}
const grey =  Color(0xFFF0F0F0);

class MyApp extends StatelessWidget {
  final Widget initialRoute;

  MyApp({required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dialogBackgroundColor: Color(0xFFF5FFFF),
        primaryColor: Color(0xFF0101FE).withOpacity(0.5),
          scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
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
          ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          elevation: 2.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          backgroundColor: Color(0xFF048304),
          foregroundColor: Colors.white,
        ),
        bottomAppBarTheme: BottomAppBarTheme(
          color: Colors.white,
        ),
      ),
      title: 'ISI App',
      initialRoute: '/',
      routes: {
        '/': (context) =>  AnimatedSplashScreen(
          splash: Image.asset('assets/logo.png'),
          nextScreen: initialRoute,
          splashTransition: SplashTransition.fadeTransition,
          duration: 3000,
        ),
        '/login': (context) => Login(),
        '/signUp': (context) => SignUp(),
        '/home': (context) => Home(),
        '/form': (context) => FormBuilder()
      },
    );
  }
}
