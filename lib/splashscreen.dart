import 'dart:async';

import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState(){
    super.initState();
    _navigateToCorrectScreen();
    
  }

  Future _navigateToCorrectScreen() async {
    await Future.delayed(const Duration(seconds: 2));

    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.biotech_rounded ,size: 60) ,
              Text('E-Lab',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
              ),
            ],
          ),
          SizedBox(height: 10),
          CircularProgressIndicator.adaptive( backgroundColor: ElabColors.secondaryColor,)
        ]
       )
    );
  }
}