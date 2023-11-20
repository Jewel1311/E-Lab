import 'package:elab/pages/bookingdetails.dart';
import 'package:elab/pages/confirmbooking.dart';
import 'package:elab/pages/contactinfo.dart';
import 'package:elab/pages/dashboard.dart';
import 'package:elab/pages/home.dart';
import 'package:elab/pages/login.dart';
import 'package:elab/pages/patientdetails.dart';
import 'package:elab/pages/register.dart';
import 'package:elab/pages/tests.dart';
import 'package:elab/pages/timeslot.dart';
import 'package:elab/pages/viewresults.dart';
import 'package:elab/splashscreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future main() async { 
  runApp(const Elab());
}


class Elab extends StatelessWidget {
  const Elab({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.roboto().fontFamily,
      ),
      title: 'Elab',
      
      initialRoute: '/',
      routes: {
        '/' :(context) => const SplashScreen(),
        '/home' :(context) => const Home(),
        '/register' :(context) => const Register(),
        '/login' :(context) => const Login(),
        '/dashboard':(context) => const Dashboard(),
        '/tests' :(context) => const Tests(),
        '/patientdetails' :(context) => const PatientDetails(),
        '/contactinfo' :(context) => const ContactInfo(),
        '/timeslot':(context) => const TimeSlot(),
        '/confirmbooking' :(context) => const ConfirmBooking(),
        '/bookingdetails' :(context) => const BookingDetails(),
        '/viewresults' : (context) => const ViewResults(),
      },
    );
  }
}