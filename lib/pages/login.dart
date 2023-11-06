import 'package:elab/style/colors.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
          backgroundColor: ElabColors.secondaryColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
    }else{
        setState(() {
          emailValidationError = false;
          credentialError = false;
        });
        // email validation
        if(! EmailValidator.validate(emailController.text)){
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
          email: emailController.text,
          password: passwordController.text,
        );
        // ignore: use_build_context_synchronously
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }catch(e){
        setState(() {
            credentialError = true;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading? null :
      AppBar(
        title: const Text('E-Lab'),
        backgroundColor: ElabColors.primaryColor,
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
        padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.person, size: 60, color: ElabColors.primaryColor,),
          const SizedBox(height: 10),
          const Text('Log in to your E-lab account',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 20),
          if (credentialError)
              const Text(
              'Invalid Credentials',
              style: TextStyle(color: Colors.red, fontSize: 18),   
            ),
          const SizedBox(height: 20),
          emailField(),
          const SizedBox(height: 15),
          passwordField(),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (){
                onLogin();
              }, 
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(ElabColors.primaryColor),
                padding: MaterialStatePropertyAll(EdgeInsets.fromLTRB(30, 10, 30, 10)),
              ),
              child:const Text('Log In', 
              style: TextStyle(
                fontSize: 18
              )
              )
              ),
          ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?",
                style: TextStyle(
                  fontSize: 16
                ),),
                GestureDetector(
                  onTap:() {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text(' Sign Up', style: 
                  TextStyle(color:ElabColors.primaryColor, fontSize: 16),)
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
            const Text('Email',
            style: TextStyle(
              fontSize: 16,
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
                style: TextStyle(color: Colors.red,
                fontSize: 16),   
              )
          
            ],
          );
  }

  Column passwordField() {
      return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Password',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black
              ),
              ),
              TextField(
                  controller: passwordController,
                  obscureText: true,
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
