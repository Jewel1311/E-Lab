import 'package:elab/pages/dashboard.dart';
import 'package:elab/pages/home.dart';
import 'package:elab/pages/login.dart';
import 'package:elab/pages/register.dart';
import 'package:elab/splashscreen.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

Future main() async { 
  runApp(const Elab());
}


class Elab extends StatelessWidget {
  const Elab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elab',
      initialRoute: '/',
      routes: {
        '/' :(context) => const SplashScreen(),
        '/home' :(context) => const Home(),
        '/register' :(context) => const Register(),
        '/login' :(context) => const Login(),
        '/dashboard':(context) => const Dashboard()

      },
    );
  }
}