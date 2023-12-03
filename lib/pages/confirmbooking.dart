import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';


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
  String payment = "pending";
  bool isChecked = false;

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

  String addOneHourToCurrentTime(String currentTime) {
    DateTime parsedTime = DateFormat('h:mm a').parse(currentTime);
    DateTime newTime = parsedTime.add(const Duration(hours: 1));
    String formattedTime = DateFormat('h:mm a').format(newTime);
    return formattedTime;
  }



  Future bookTest() async{
    setState(() {
      isLoading = true;
    });

    DateTime inputDate = DateFormat("dd MMM yy").parse(testsMap['date']);
    String formattedDate = DateFormat("yyyy-MM-dd").format(inputDate);



    try{
      final patient = await supabase.from('patient').upsert({
         if (testsMap['patientDetails']['id'] != '')
            'id': testsMap['patientDetails']['id'],
        'name':testsMap['patientDetails']['name'],
        'age':testsMap['patientDetails']['age'],
        'gender':testsMap['patientDetails']['gender'],
        'bloodgroup':testsMap['patientDetails']['bloodGroup'],
        'user_id': supabase.auth.currentUser!.id
      }).select();

      final patientId = patient[0]['id'];

      final contact = await supabase.from('contact').upsert({
        if (testsMap['contactDetails']['id'] != '')
            'id': testsMap['contactDetails']['id'],
          'address': testsMap['contactDetails']['address'],
          'phone' : testsMap['contactDetails']['phone'],
          'landmark': testsMap['contactDetails']['landmark'],
          'latitude':testsMap['contactDetails']['latitude'],
          'longitude':testsMap['contactDetails']['longitude'],
          'user_id': supabase.auth.currentUser!.id
      }).select();

      final contactId = contact[0]['id'];

      await supabase.from('booking').insert({
        'tests': testsMap['tests'],
        'timeslot' : testsMap['time'],
        'date': formattedDate,
        'patient_id' : patientId,
        'contact_id': contactId,
        'lab_id': testsMap['labId'],
        'pay_status': payment
      });

      Fluttertoast.showToast(
          msg: "Test Booked",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );

      // ignore: use_build_context_synchronously
      Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);

    } catch(e) {
       Fluttertoast.showToast(
          msg: "Unable to book test",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0
        );
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
           SingleChildScrollView( child:
             listBookingDetails(),
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
                  physics: NeverScrollableScrollPhysics(),
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

      
                
                const Text("Time Slot", style: TextStyle(color: ElabColors.greyColor, fontWeight: FontWeight.bold, fontSize: 16),),
                const SizedBox(height: 10,),
                 Container(
                  width: double.infinity,
                  height: 1, // Adjust the height of the border line as needed
                  decoration: BoxDecoration(
                    color: ElabColors.greyColor2, // Color of the border line
                    borderRadius: BorderRadius.circular(2), // Adjust the radius as needed
                  ),
                ),
                const SizedBox(height: 20,),
                Text(testsMap['date'], style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,
                        ),),
                const SizedBox(height: 10,),
                Text(testsMap['time']+' - '+addOneHourToCurrentTime(testsMap['time']), style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16,
                        ),),

               
                const SizedBox(height: 20,),

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
                const SizedBox(height: 20,),

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
            Row(
              children: [
                Checkbox(
                value: isChecked,
                onChanged: (bool? value) {
                  setState(() {
                    isChecked = value ?? false;
                  });
                },
          ),
          Text('Pay Now',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),)
          ],
            ),      
           
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,15,8),
            child: ElevatedButton(
              onPressed: () {
                if (isChecked){
                  payNow();
                }
                else{
                  bookTest();
                }
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

  Future payNow() async{
    await dotenv.load(fileName: ".env");
    Razorpay razorpay = Razorpay();
    var options = {
      'key': dotenv.env['RAZKEY'],
      'amount': testsMap['price']*100,
      'description': 'Book Tests',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'external': {
        'wallets': ['paytm']
      }
    };
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, handlePaymentErrorResponse);
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, handlePaymentSuccessResponse);
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, handleExternalWalletSelected);
    razorpay.open(options);
  }

  handlePaymentErrorResponse(PaymentFailureResponse response) {
     showAlertDialog(context, "Payment Failed");
  }

  handlePaymentSuccessResponse(PaymentSuccessResponse response) {
    payment = 'paid';
    bookTest();
    
  }

  handleExternalWalletSelected(ExternalWalletResponse response) {
    showAlertDialog(context, "External Wallet Selected ${response.walletName}");
    payment = 'paid';
    bookTest();
  }

  void showAlertDialog(BuildContext context, String message,){
    // set up the buttons
    Widget continueButton = ElevatedButton(
      child: const Text("Ok"),
      onPressed:  () {
        Navigator.pop(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(message),
      actions: [
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}