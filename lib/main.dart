import 'package:elab/pages/home.dart';
import 'package:elab/pages/login.dart';
import 'package:elab/pages/register.dart';
import 'package:flutter/material.dart';

void main(){
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
        '/' :(context) => const Home(),
        '/register' :(context) => const Register(),
        '/login' :(context) => const Login()

      },
    );
  }
}