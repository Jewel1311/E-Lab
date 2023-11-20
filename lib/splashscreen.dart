import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
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
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    await Supabase.initialize(
    url: dotenv.env['URL']!,
    anonKey: dotenv.env['PUBLIC_KEY']!,
    );


    OneSignal.shared.setAppId(dotenv.env['APP_ID']!);
   

    final supabase = Supabase.instance.client;

    if (supabase.auth.currentUser != null) {
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);

    } else {
      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);

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
              Icon(Icons.biotech_rounded ,size: 60, color:ElabColors.secondaryColor) ,
              Text('E-Lab',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: ElabColors.secondaryColor
              ),
              ),
            ],
          ),
          SizedBox(height: 10),
          SpinKitFadingCube(color: ElabColors.primaryColor,)
        ]
       )
    );
  }
}