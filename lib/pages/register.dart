import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';

class Register extends StatelessWidget {
  const Register({super.key});

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
            _buildTextField('Email'),
            const SizedBox(height: 10),
            _buildTextField('Name'),
            const SizedBox(height: 10),
            _buildTextField('Phone'),
            const SizedBox(height: 10),
            _buildTextField('City'),
            const SizedBox(height: 10),
            _buildTextField('District'),
            const SizedBox(height: 10),
            _buildTextField('Password', showText:true),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: (){}, 
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

  Widget _buildTextField(String label, {bool showText = false}){
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
            obscureText: showText,
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