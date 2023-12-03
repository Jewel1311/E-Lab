import 'package:elab/style/colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  bool emailValidationError = false;
  bool passwordValidationError = false;
  bool confirmpasswordError = false;
  bool isLoading = false;
  String userId = "";


  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();



  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
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
      body: isLoading? loadingView():registrationForm(context),
    );
  }
  // check input validations
  void onCreate() {
    if ([emailController.text, nameController.text, phoneController.text, cityController.text, passwordController.text, confirmpasswordController.text].any((text) => text.isEmpty)) { 

        Fluttertoast.showToast(
          msg: "All Fields are required",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
    }else{
        setState(() {
          emailValidationError = false;
          passwordValidationError = false;
          confirmpasswordError = false;
        });
        // email validation
        if(! EmailValidator.validate(emailController.text.trim())){
          setState(() {
            emailValidationError = true;
          });
        }
        //password validation
        if(passwordController.text.trim().length < 6){
          setState(() {
            passwordValidationError = true;
          });
        }
        if(passwordController.text.trim() != confirmpasswordController.text.trim()){
          setState(() {
            confirmpasswordError = true;
          });
        }
        if( emailValidationError == false && passwordValidationError == false && confirmpasswordError == false){
          registerUser();
        }
    }
  }

  Future registerUser() async{
    setState(() {
        isLoading = true;
    });
    final supabase = Supabase.instance.client;
    try{
      try{
       await supabase.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      }catch(e){
        Fluttertoast.showToast(
          msg: "Email already exists",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
        setState(() {
          isLoading = false;
        });
        throw Exception();
      }
      
      await supabase.auth.signInWithPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );


      final Map<String, dynamic> profileData = {
      'name': nameController.text.trim(),
      'phone': phoneController.text.trim(),
      'city': cityController.text.trim(),
      };

      final profile = await supabase
      .from('profile') 
      .upsert([profileData]).select();

      await OneSignal.shared.getDeviceState().then((deviceState) {
            userId = deviceState!.userId.toString(); // Use this ID to identify the user
        });
      await supabase.from('profile').upsert({'id':profile[0]['id'],'onesignaluserid':userId});

      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);

    }catch(e){
      if (supabase.auth.currentUser != null){
        String uid = supabase.auth.currentUser!.id; 
        final supabaseadmin = SupabaseClient(dotenv.env['URL']!, dotenv.env['SERVICE_KEY']!);
        await supabaseadmin.auth.signOut(); // Sign out the user
        await supabaseadmin.auth.admin.deleteUser(uid);

        setState(() {
          isLoading = false;
        });
        
        Fluttertoast.showToast(
          msg: "Unable to create account",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );

      }

    }

   
  }


  //loading view
  Center loadingView() => const Center(child: SpinKitThreeBounce(color: ElabColors.primaryColor,));


  //registration form
  SingleChildScrollView registrationForm(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20,10,20,20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text('Create an account',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: GoogleFonts.hammersmithOne().fontFamily
          )
          ),
          const SizedBox(height: 5),
          Text('Just one step to get started',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: const Color.fromARGB(255, 146, 146, 146), fontFamily: GoogleFonts.poppins().fontFamily)
          ),
          const SizedBox(height: 20),
          emailField(),
          const SizedBox(height: 15),
          nameField(),
          const SizedBox(height: 15),
          phoneField(),
          const SizedBox(height: 15),
          cityField(),
          const SizedBox(height: 15),
          passwordField(),
          const SizedBox(height: 15),
          confirmPasswordField(),
          const SizedBox(height: 20),
          

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (){
                onCreate();
              }, 
              style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                padding: const MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                    ),
                  ),
              ),
              child:Text('Create', 
              style: TextStyle(
                fontSize: 16,
                fontFamily: GoogleFonts.poppins().fontFamily
              )
              )
              ),
          ),
             const SizedBox(height: 20),
              Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: GoogleFonts.poppins().fontFamily
                ),),
                GestureDetector(
                  onTap:() {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: Text(' Log In', style: 
                  TextStyle(color:ElabColors.primaryColor, fontSize: 16,fontFamily: GoogleFonts.poppins().fontFamily),)
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
                style: TextStyle(color: Colors.red, fontFamily: GoogleFonts.poppins().fontFamily),   
              )
          
            ],
          );
  }


  Column nameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Name', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
        TextField(
          controller: nameController,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            prefixIcon:Icon(Icons.person, color:Colors.black,size: 20, ),
          ),     
        ),
      ],
    );
  }

  Column phoneField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone Number', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
            TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.phone, color:Colors.black,size: 20, ),
                ),     
              ),
            ],
          );
  }

  Column cityField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('City', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
        TextField(
          controller: cityController,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          decoration: const InputDecoration(
            prefixIcon:Icon(Icons.business, color:Colors.black,size: 20, ),
          ),     
        ),
      ],
    );
  }



Column passwordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Password (minimum 6 characters)', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.key, color:Colors.black,size: 20, ),
                ),     
              ),
                // show email validation error
                if (passwordValidationError)
                  Text(
                  'Minimum 6 characters required',
                  style: TextStyle(color: Colors.red, fontFamily: GoogleFonts.poppins().fontFamily),   
                ),         
              ],
            );
    }


Column confirmPasswordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Confirm Password', style:TextStyle(fontWeight: FontWeight.bold, color: ElabColors.greyColor, fontSize: 15, fontFamily:GoogleFonts.poppins().fontFamily),),
              TextField(
                controller: confirmpasswordController,
                obscureText: true,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(
                  prefixIcon:Icon(Icons.keyboard_alt_rounded, color:Colors.black,size: 20, ),
                ),     
              ),
                // show email validation error
                if (confirmpasswordError)
                  Text(
                  "Passwords don't match",
                  style: TextStyle(color: Colors.red, fontFamily: GoogleFonts.poppins().fontFamily),   
                ),         
              ],
            );
    }

 

}

 