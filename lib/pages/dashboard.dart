import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async{      
            await supabase.auth.signOut();
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
          child: const Text('Sign out'),
        ),
      ),
    );
  }
}