import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class ContactInfo extends StatefulWidget {
  const ContactInfo({super.key});

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {

  dynamic testsMap;

  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController landMarkController = TextEditingController();


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      testsMap = ModalRoute.of(context)?.settings.arguments as Map?;
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    phoneController.dispose();
    landMarkController.dispose();
    super.dispose();
  }

  void getcontactDetails() {
     if ([addressController.text, phoneController.text].any((text) => text.isEmpty)) { 

        Fluttertoast.showToast(
          msg: "Address and phone number required ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0,
        );
    }else{

      final Map contactDetails = {
        'address':addressController.text,
        'phone': phoneController.text,
        'landmark':landMarkController.text
      };

      Navigator.pushNamed(context, '/confirmbooking', arguments: {
        'tests':testsMap['tests'],
        'price':testsMap['price'],
        'labId':testsMap['labId'],
        'time': testsMap['time'],
        'date': testsMap['date'],
        'patientDetails': testsMap['patientDetails'],
        'contactDetails' : contactDetails
      });
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Contact Information', style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.hammersmithOne().fontFamily, fontWeight: FontWeight.bold),),
      ), 
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(child: Column(
          children: [
            contactForm(),
          ],
        ),
        )
      ),
      bottomNavigationBar:  bottomNavBar(),
    );
  }

  Column contactForm() {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Address",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),
              TextField(
                maxLines: null,
                controller: addressController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.bungalow_outlined,color: Colors.black,),
                  hintText: 'provide full address', hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal)
                ),
              ),

            const SizedBox(height: 30,),

            const Text("Phone Number",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),

            TextField(
              controller: phoneController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.phone_outlined,color: Colors.black,),    
                ),
              keyboardType: TextInputType.number,
              inputFormatters: [
              LengthLimitingTextInputFormatter(10),
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
            ),

            const SizedBox(height: 30,),

            const Text("Landmark",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),

             TextField(
              controller: landMarkController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.landscape_outlined,color: Colors.black,),
                hintText: 'if any',hintStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.normal)  
                ),
            ),
              
            ],   
          );
  }

Material bottomNavBar() {
    return Material( 
      elevation: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,15,8),
            child: ElevatedButton(
              onPressed: () {
                getcontactDetails();
              },
              style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                fixedSize: MaterialStateProperty.all(
                  const Size(100, 40), 
                ),
                  ),
              child: const Text('Next',),
            ),
          ),
        ],
      )
    );
  }


}