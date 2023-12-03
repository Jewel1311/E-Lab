import 'package:elab/pages/labs.dart';
import 'package:elab/pages/profile.dart';
import 'package:elab/pages/showbookings.dart';
import 'package:elab/pages/viewresults.dart';
import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Welcome to E-lab',
          style: TextStyle(fontFamily: GoogleFonts.hammersmithOne().fontFamily,color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),

      body:  IndexedStack(
        index: _selectedIndex,
        children:const [
          Labs(),
          ShowBookings(),
          ViewResults(),
          Profile(),
        ],
        ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(8,8,8,10),
        child: ClipRRect(
            borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
            bottomLeft:Radius.circular(15.0),
            bottomRight:Radius.circular(15.0),
          ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
      
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.mail_outline),
              label: 'Results'
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          backgroundColor: ElabColors.greyColor2,
          onTap: _onItemTapped,
          iconSize: 25,
          showUnselectedLabels: true,
          selectedItemColor: ElabColors.primaryColor,
          unselectedItemColor: ElabColors.secondaryColor,
          
          
        )
          ),
      )
    );
  }
}