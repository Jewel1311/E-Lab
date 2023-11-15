import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ConfirmBooking extends StatefulWidget {
  const ConfirmBooking({super.key});

  @override
  State<ConfirmBooking> createState() => _ConfirmBookingState();
}

class _ConfirmBookingState extends State<ConfirmBooking> {

  dynamic testsMap;
  final supabase = Supabase.instance.client;
  dynamic labDetails;
  bool isLoading = false;
  List testDetails = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration.zero, () {
      testsMap = ModalRoute.of(context)?.settings.arguments as Map?;
      getBookingDetails();
    });
  }


  Future getBookingDetails() async {
    labDetails = await supabase.from('labs').select().match({'id':testsMap['labId']});
    for(int id in testsMap['tests']){
      final testDetail = await supabase.from('tests').select().match({'id': id});
      testDetails.add(testDetail);
    }
     setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar:isLoading?null: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Summary', style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.hammersmithOne().fontFamily, fontWeight: FontWeight.bold),),
      ),
      body: isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,) :
            Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [ 
             listBookingDetails(),
            ],
          ),
    
      bottomNavigationBar: isLoading ?null :bottomNavBar(), 
    );
  }

  Column listBookingDetails() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  Text(labDetails[0]['labname'], style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8,),
                  Text(labDetails[0]['city'], style: const TextStyle(
                    fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 15,),

                  Container(
                  width: double.infinity,
                  height: 1, // Adjust the height of the border line as needed
                  decoration: BoxDecoration(
                    color: ElabColors.greyColor2, // Color of the border line
                    borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
                  ),
                ),
                
                const SizedBox(height: 10,),
                const Text("Tests Selected", style: TextStyle(color: ElabColors.greyColor, fontWeight: FontWeight.bold, fontSize: 16),),
                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height: 1, // Adjust the height of the border line as needed
                  decoration: BoxDecoration(
                    color: ElabColors.greyColor2, // Color of the border line
                    borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
                  ),
                ),
                const SizedBox(height: 15,),

                ListView.builder(
                  shrinkWrap: true,
                  itemCount: testDetails.length,
                  itemBuilder: (context , index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(testDetails[index][0]['testname'], style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,
                        ),),
                        const SizedBox(height: 8,),
                        Row(
                          children: [
                            const Icon(Icons.currency_rupee, color: Colors.black, size: 20,),
                            Text(testDetails[index][0]['price'].toString(), style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green,
                            ),),
                          ],
                        ),
                        const SizedBox(height: 20,)
                      ],
                    );
                  }
                ),

                Container(
                  width: double.infinity,
                  height: 1, // Adjust the height of the border line as needed
                  decoration: BoxDecoration(
                    color: ElabColors.greyColor2, // Color of the border line
                    borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
                  ),
                ),
                const SizedBox(height: 10,),

                const Text("Patient Details", style: TextStyle(color: ElabColors.greyColor, fontWeight: FontWeight.bold, fontSize: 16),),

                const SizedBox(height: 10,),
                Container(
                  width: double.infinity,
                  height: 1, // Adjust the height of the border line as needed
                  decoration: BoxDecoration(
                    color: ElabColors.greyColor2, // Color of the border line
                    borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
                  ),
                ),
                const SizedBox(height: 10,),

                 Text(testsMap['patientDetails']['name'], style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,
                        ),),
                const SizedBox(height: 10,),
                Text("Age : ${testsMap['patientDetails']['age']}  Gender: ${ testsMap['patientDetails']['gender']}", style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,
                      ),),

                const SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  height: 1, // Adjust the height of the border line as needed
                  decoration: BoxDecoration(
                    color: ElabColors.greyColor2, // Color of the border line
                    borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
                  ),
                ),
                const SizedBox(height: 20,),
                Row(
                  children: [
                    const Text("Total amount payable: ", style:  TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16,
                      ),),
                      const Icon(Icons.currency_rupee),
                    Text(testsMap['price'].toString(), style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18,color: Colors.green
                      ),),
                  ],
                ),
                ],
              ),
            ),
        ]
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
                
              },
              style: ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                fixedSize: MaterialStateProperty.all(
                  const Size(100, 40), 
                ),
                  ),
              child: Text('Book Test',style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily,
              fontWeight: FontWeight.bold,)),
            ),
          ),
        ],
      )
    );
  }

}