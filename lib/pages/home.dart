import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.biotech_rounded ,size: 60) ,
              Text('E-Lab',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
              ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox( 
                width: 180,
                height: 50,
                child: ElevatedButton(
                onPressed: (){
                   Navigator.pushNamed(context, '/register');
                }, 
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(ElabColors.primaryColor),
                ),
                child:const Text('Register', 
                style: TextStyle(
                  fontSize: 18
                )
                )
                ),
            )
          ),
        const SizedBox(height:15),
         Center(
            child: SizedBox( 
                width: 180,
                height: 50,
                child: ElevatedButton(
                onPressed: (){
                   Navigator.pushNamed(context, '/login');
                }, 
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(ElabColors.secondaryColor),
                ),
                child:const Text('Log In', 
                style: TextStyle(
                  fontSize: 18
                )
                )
                ),
            )
          ),
        ],
      ),
    );
  }
}