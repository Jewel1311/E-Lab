import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return  Center(
        child: ElevatedButton(
          onPressed: () async{      
            await Supabase.instance.client.auth.signOut();
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
          child: const Text('Sign out'),
        ),
      ); 
  }
}