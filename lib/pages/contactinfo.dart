import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ContactInfo extends StatefulWidget {
  const ContactInfo({super.key});

  @override
  State<ContactInfo> createState() => _ContactInfoState();
}

class _ContactInfoState extends State<ContactInfo> {

  dynamic testsMap;
  bool isLoading = false;
  dynamic previousContactDetails;
  String selectedContact = '';

  final supabase = Supabase.instance.client;

  TextEditingController addressController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController landMarkController = TextEditingController();


  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration.zero, () {
      testsMap = ModalRoute.of(context)?.settings.arguments as Map?;
      getPreviousDetails();
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
        'landmark':landMarkController.text,
        'id': selectedContact
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

   Future getPreviousDetails() async {
    previousContactDetails = await supabase.from('contact').select().match({'user_id':supabase.auth.currentUser!.id}).order('id');
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
        title: Text('Contact Information', style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.hammersmithOne().fontFamily, fontWeight: FontWeight.bold),),
      ), 
      body:SingleChildScrollView(child: Padding(
        padding: const EdgeInsets.fromLTRB(15,5,15,0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contactForm(),
            const SizedBox(height: 30,),
            const Text("Previous Contact Details", style: TextStyle(fontWeight:  FontWeight.bold, fontSize: 16, color: ElabColors.greyColor),),
            const SizedBox(height: 5,),
            isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,):
            perviousContactsView(),
          ],
        ),

      ),
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

            const SizedBox(height: 20,),

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

            const SizedBox(height: 20,),

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

  ListView perviousContactsView() {
    return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: previousContactDetails.length,
              itemBuilder:(context, index) {
                return Container(
                margin: const EdgeInsets.fromLTRB(5,8,5,5),
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
                        Text(previousContactDetails[index]['address']+ "  ",style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold
                        ),),
                     ],
                    ),
                    trailing: Radio(
                      value: previousContactDetails[index]['id'].toString(),
                      groupValue: selectedContact,
                      onChanged: (String? value) {
                        setState(() {
                          selectedContact = value!;
                           addressController.text = previousContactDetails[index]['address'];
                           phoneController.text = previousContactDetails[index]['phone'].toString();
                           landMarkController.text = previousContactDetails[index]['landmark'];
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