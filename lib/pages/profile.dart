import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final supabase = Supabase.instance.client;
  dynamic profile;
  bool isLoading = false;

  final TextEditingController nameController =  TextEditingController(); 
  final TextEditingController phoneController =  TextEditingController(); 
  final TextEditingController cityController =  TextEditingController(); 
  final TextEditingController emailController =  TextEditingController(); 
  
  @override
  void initState() {
    super.initState();
    getProfile();
  }

  Future getProfile() async {
    setState(() {
      isLoading = true;
    });
    profile = await supabase.from('profile').select().match({'user_id':supabase.auth.currentUser!.id});
    nameController.text = profile[0]['name'];
    phoneController.text = profile[0]['phone'];
    cityController.text = profile[0]['city'];
    emailController.text = supabase.auth.currentUser!.email!;
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,):userProfile(),
    ); 
  }

  Column userProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Text("Account Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily
              ),
             ),
             const SizedBox(height: 50,)
          ],
        ),
        const SizedBox(height: 15,),
        const Text("Name"),
        textFields(nameController),
        const SizedBox(height: 15),
        const Text("PhoneNumber"),
        textFields(phoneController),
        const SizedBox(height: 15),
        const Text("City"),
        textFields(cityController),
        const SizedBox(height: 15),
        const Text("Email"),
        textFields(emailController),
        Padding(
          padding: const EdgeInsets.fromLTRB(0,30,0,0),
          child: ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              backgroundColor: const MaterialStatePropertyAll(
                ElabColors.color3,
              ),
              elevation: const MaterialStatePropertyAll(3),
              
            ),
            onPressed: () async {      
            await Supabase.instance.client.auth.signOut();
            // ignore: use_build_context_synchronously
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          },
          child:const Padding(
            padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Log Out ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold
                ),
                ),
                Icon(Icons.logout, color:Colors.black,)
              ],
            ),
          )),
        )
      ],
    );
  }

  TextField textFields(controller) {
    return TextField(
            controller: controller,
            enabled: false,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold
              ),
        );
  }
}


