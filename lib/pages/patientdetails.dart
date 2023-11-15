import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDetails extends StatefulWidget {
  const PatientDetails({super.key});

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {

  dynamic testsMap;

  String selectedGender = '';
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();


  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      testsMap = ModalRoute.of(context)?.settings.arguments as Map?;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    bloodGroupController.dispose();
    super.dispose();
  }

  void getPatientDetails() {
     if ([nameController.text, ageController.text].any((text) => text.isEmpty)) { 

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

      final Map patientDetials = {
        'name': nameController.text,
        'age': ageController.text,
        'gender': selectedGender,
        'bloodGroup': bloodGroupController.text
      };

      Navigator.pushNamed(context, '/contactinfo', arguments: {
        'tests':testsMap['tests'],
        'price':testsMap['price'],
        'labId':testsMap['labId'],
        'time': testsMap['time'],
        'patientDetails': patientDetials
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
        title: Text('Patient Details', style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.hammersmithOne().fontFamily, fontWeight: FontWeight.bold),),
      ), 
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          children: [
            patientForm(),
          ],
        ),
      ),
      bottomNavigationBar:  bottomNavBar(),
    );
  }

  Column patientForm() {
    return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Name",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),
              TextField(
                controller: nameController,
                style: const TextStyle(fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person,color: Colors.black,)
                ),
              ),

            const SizedBox(height: 20,),

            const Text("Age",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),

            TextField(
              controller: ageController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.timelapse_sharp,color: Colors.black,),    
                ),
              keyboardType: TextInputType.number,
              inputFormatters: [
              LengthLimitingTextInputFormatter(3),
              FilteringTextInputFormatter.digitsOnly, // Allow only digits
              ],
            ),

            const SizedBox(height: 20,),

            const Text("Gender",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),
            Row(
              children: [
                 Row(
                   children: [
                     Radio(
                      value: 'Male',
                      groupValue: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                      ),
                      const Text('Male',style:TextStyle(fontSize: 16,) ,)
                   ],
                 ),
                const SizedBox(width: 40,),
                Row(
                   children: [
                     Radio(
                      value: 'Female',
                      groupValue: selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      },
                      ),
                      const Text('Female',style:TextStyle(fontSize: 16,) ,)
                   ],
                 ),
              ],
            ),

            const SizedBox(height: 20,),

            const Text("Blood Group",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),

             TextField(
              controller: bloodGroupController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.bloodtype,color: Colors.black,),    
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
                getPatientDetails();
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