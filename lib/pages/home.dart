import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [ 
          Image.asset('assets/images/home.jpg'),

          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.biotech_rounded ,size: 60, color: ElabColors.secondaryColor,) ,
              Text('E-Lab',
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: ElabColors.secondaryColor
              ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/register');
                  },
                  child: const Text('Register',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  )
                  ),
                ),
              const Text(' / ', style: TextStyle( fontSize: 30, fontWeight: FontWeight.bold)),
              GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text('Log In',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold
                  )
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}