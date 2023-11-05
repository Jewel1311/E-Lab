import 'package:elab/style/colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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


  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();


  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    phoneController.dispose();
    cityController.dispose();
    districtController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // check input validations
  void onCreate() {
    if ([emailController.text, nameController.text, phoneController.text, cityController.text, districtController.text, passwordController.text].any((text) => text.isEmpty)) { 

        Fluttertoast.showToast(
          msg: "All Fields are required",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.secondaryColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
    }else{
        setState(() {
          emailValidationError = false;
          passwordValidationError = false;
        });
        // email validation
        if(! EmailValidator.validate(emailController.text)){
          setState(() {
            emailValidationError = true;
          });
        }
        //password validation
        if(passwordController.text.length < 6){
          setState(() {
            passwordValidationError = true;
          });
        }
        if( emailValidationError == false && passwordValidationError == false){
          registerUser();
        }
    }
  }

  Future registerUser() async{
    final supabase = Supabase.instance.client;
    try{
      final AuthResponse res = await supabase.auth.signUp(
        email: emailController.text,
        password: passwordController.text,
      );
      
      await supabase.auth.signInWithPassword(
        email: emailController.text,
        password: passwordController.text,
      );


      final Map<String, dynamic> profileData = {
      'user_id': res.user!.id, // Reference to the user logged in user
      'name': nameController.text,
      'phone': phoneController.text,
      'city': cityController.text,
      'district': districtController.text
      };

      await supabase
      .from('profile') 
      .upsert([profileData]);

      // ignore: use_build_context_synchronously
      Navigator.pushNamed(context, '/dashboard');

    }catch(e){
      if (supabase.auth.currentUser != null){
        String uid = supabase.auth.currentUser!.id; 
        final supabaseadmin = SupabaseClient(dotenv.env['URL']!, dotenv.env['SERVICE_KEY']!);
        await supabaseadmin.auth.signOut(); // Sign out the user
        await supabaseadmin.auth.admin.deleteUser(uid);
        
        Fluttertoast.showToast(
          msg: "Unable to create account",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.secondaryColor,
          textColor: Colors.white,
          fontSize: 16.0
        );

      }

    }

   
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Lab'),
        backgroundColor: ElabColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text('Create an account',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold
            )
            ),
            const SizedBox(height: 20),
            emailField(),
            const SizedBox(height: 10),
            _buildTextField('Name',nameController),
            const SizedBox(height: 10),
            phoneField(),
            const SizedBox(height: 10),
            _buildTextField('City',cityController),
            const SizedBox(height: 10),
            _buildTextField('District',districtController),
            const SizedBox(height: 10),
            passwordField(),
            const SizedBox(height: 20),
            

            ElevatedButton(
              onPressed: (){
                onCreate();
              }, 
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(ElabColors.primaryColor),
                padding: MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
              ),
              child:const Text('Create', 
              style: TextStyle(
                fontSize: 18
              )
              )
              )
          ],
        ),
      )
      ),
    );
  }

  Column emailField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black
            ),
            ),
            TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
                
              ),
              // show email validation error
               if (emailValidationError)
                const Text(
                'Enter a valid email',
                style: TextStyle(color: Colors.red),   
              )
          
            ],
          );
  }

  Column phoneField() {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Phone Number',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black
            ),
            ),
            TextField(
                controller: phoneController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                LengthLimitingTextInputFormatter(10),
                FilteringTextInputFormatter.digitsOnly, // Allow only digits
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5)
                  )
                ),
              ),
            ],
          );
  }


  Column passwordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Password (minimum 6 characters)',
              style: TextStyle(
                fontSize: 15,
                color: Colors.black
              ),
              ),
              TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5)
                    )
                  ),
                  
                ),
                // show email validation error
                if (passwordValidationError)
                  const Text(
                  'Minimum 6 characters required',
                  style: TextStyle(color: Colors.red),   
                )
            
              ],
            );
    }


  // for name city district and password
  Widget _buildTextField(String label, TextEditingController customController ){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black
        ),
        ),
        TextField(
            controller: customController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5)
              )
            ),
          ),   
      ],
    );
  }

}

 