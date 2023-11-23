import 'package:elab/style/colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool emailValidationError = false;
  bool credentialError = false;
  bool isLoading = false;
  String userId = "";

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void onLogin() {    
    if ([emailController.text, passwordController.text].any((text) => text.isEmpty)) { 

        Fluttertoast.showToast(
          msg: "All Fields are required",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );
    }else{
        setState(() {
          emailValidationError = false;
          credentialError = false;
        });
        // email validation
        if(! EmailValidator.validate(emailController.text.trim())){
          setState(() {
            emailValidationError = true;
          });
        }
        else{
          loginUser();
        }
    }
  }

  Future loginUser() async {
    setState(() {
      isLoading = true;
    });
      final supabase = Supabase.instance.client;
      try{
        await supabase.auth.signInWithPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        final profile = await supabase.from('profile').select('id').match({'user_id':
        supabase.auth.currentUser!.id});
        if(profile.length < 1){
          await Supabase.instance.client.auth.signOut();
          throw Exception();
        }
        await OneSignal.shared.getDeviceState().then((deviceState) {
            userId = deviceState!.userId.toString(); // Use this ID to identify the user
        });
        await supabase.from('profile').upsert({'id':profile[0]['id'],'onesignaluserid':userId});
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }catch(e){
        setState(() {
            credentialError = true;
            isLoading = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLoading? null :
      AppBar(
        elevation: 0,
         iconTheme: const IconThemeData(
          color: ElabColors.greyColor,
        ),
        backgroundColor: Colors.white,
      ),
      body: isLoading? loadingView() : loginView(context),
    );
  }

  //loading view
  Center loadingView() => const Center(child: SpinKitThreeBounce(color: ElabColors.primaryColor,));

  //login 
  SingleChildScrollView loginView(BuildContext context) {
    return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Log In", style: TextStyle(
              fontFamily: GoogleFonts.hammersmithOne().fontFamily, 
              fontSize: 22,
              fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 5),
            Text('Welcome back !',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 146, 146, 146), fontFamily: GoogleFonts.poppins().fontFamily)
            ),
            const SizedBox(height: 20),
            if (credentialError)
               Text(
                'Invalid Credentials',
                style: TextStyle(color: Colors.red, fontSize: 18, fontFamily: GoogleFonts.poppins().fontFamily),   
              ),
            const SizedBox(height: 20),
            emailField(),
            const SizedBox(height: 20),
            passwordField(),
            const SizedBox(height: 30),
      
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (){
                  onLogin();
                }, 
                style:  ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                  padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),   
                child: Text('Log In', 
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily
                )
                )
                ),
            ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: GoogleFonts.poppins().fontFamily,
                    color: ElabColors.greyColor
                  ),),
                  GestureDetector(
                    onTap:() {
                      Navigator.pushNamed(context, '/register');
                    },
                    child:Text(' Sign Up', style: 
                    TextStyle(color:ElabColors.primaryColor, fontSize: 15, fontFamily: GoogleFonts.poppins().fontFamily),)
                  ),
                ],
              )
      
          ],
        ),
      )
    );
  }

  Column emailField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
            TextField(
                controller: emailController,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.alternate_email_rounded, color:Colors.black,size: 20, ),
                ),     
              ),
              // show email validation error
               if (emailValidationError)
                 Text(
                'Enter a valid email',
                style: TextStyle(color: Colors.red,
                fontSize: 16,fontFamily: GoogleFonts.poppins().fontFamily),   
              )
          
            ],
          );
  }

  Column passwordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.key, color:Colors.black , size: 20,),            
                ),     
              ),
            
              ],
            );
    }
  
}
