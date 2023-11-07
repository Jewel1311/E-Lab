import 'package:elab/pages/labs.dart';
import 'package:elab/pages/profile.dart';
import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {

  final supabase = Supabase.instance.client;

  int _selectedIndex = 0;

  void _onItemTapped( int index) {
    setState(() {
    _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: ElabColors.primaryColor,
        title: const Text('Welcome to E-lab'),
      ),

      body:  IndexedStack(
        index: _selectedIndex,
        children:const [
          Labs(),
          Center(child: Text('Bookings')),
          Center(child: Text('Results')),
          Profile(),
        ],
        ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'Results'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        iconSize: 25,
        showUnselectedLabels: true,
        selectedItemColor: ElabColors.primaryColor,
        unselectedItemColor: ElabColors.secondaryColor,
        
      )
    );
  }
}