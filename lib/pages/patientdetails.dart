import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PatientDetails extends StatefulWidget {
  const PatientDetails({super.key});

  @override
  State<PatientDetails> createState() => _PatientDetailsState();
}

class _PatientDetailsState extends State<PatientDetails> {

  dynamic testsMap;
  dynamic previousPatients;
  bool isLoading = false;
  String selectedPatient = '';
  String selectedGender = '';
  
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController bloodGroupController = TextEditingController();

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration.zero, () {
      testsMap = ModalRoute.of(context)?.settings.arguments as Map?;
      getPreviousPatients();
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
        'bloodGroup': bloodGroupController.text,
        'id':selectedPatient
      };

      Navigator.pushNamed(context, '/contactinfo', arguments: {
        'tests':testsMap['tests'],
        'price':testsMap['price'],
        'labId':testsMap['labId'],
        'time': testsMap['time'],
        'date': testsMap['date'],
        'patientDetails': patientDetials
      });
      
    }
  }

  Future getPreviousPatients()async {
    previousPatients = await supabase.from('patient').select().match({'user_id' :supabase.auth.currentUser!.id}).order('id');
    setState(() {
      isLoading = false;
    });
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
      body:  SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.fromLTRB(15,5,15,0),
        child: patientForm(),
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

            const SizedBox(height: 15,),

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

            const SizedBox(height: 15,),

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

            const SizedBox(height: 15,),

            const Text("Blood Group",style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: ElabColors.greyColor), ),

             TextField(
              controller: bloodGroupController,
              style: const TextStyle(fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.bloodtype,color: Colors.black,),    
                ),
            ),
            const SizedBox(height: 30,),
            const Text("Previous Patients", style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 16, color: ElabColors.greyColor),),
            const SizedBox(height: 5,),
            isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,):
            patientDetailsView(),
            ],   
          );
  }

  ListView patientDetailsView() {
    return ListView.builder(
              shrinkWrap: true,
              physics:NeverScrollableScrollPhysics(),
              itemCount: previousPatients.length,
              itemBuilder:(context, index) {
                return Container(
              margin: const EdgeInsets.fromLTRB(5,8,5,8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2), // changes position of shadow
                ),
              ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0,5,0,5),
                child: ListTile(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(previousPatients[index]['name']+ "  ",style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold
                        ),),
                     const SizedBox(height: 5,),
                    Text("Age: ${previousPatients[index]['age'].toString()}",style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold
                    ),),
                     ],
                    ),
                    trailing: Radio(
                      value: previousPatients[index]['id'].toString(),
                      groupValue: selectedPatient,
                      onChanged: (String? value) {
                        setState(() {
                          selectedPatient = value!;
                           nameController.text = previousPatients[index]['name'];
                           ageController.text = previousPatients[index]['age'].toString();
                           selectedGender = previousPatients[index]['gender'];
                           bloodGroupController.text = previousPatients[index]['bloodgroup'];
                        });
                      },
                      ),
                ),
              )
                );
              } 
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