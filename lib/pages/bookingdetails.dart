import 'dart:io';

import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookingDetails extends StatefulWidget {
  const BookingDetails({super.key});

  @override
  State<BookingDetails> createState() => _BookingDetailsState();
}

class _BookingDetailsState extends State<BookingDetails> {
  final supabase = Supabase.instance.client;
  bool isLoading = false;
  dynamic labDetails;
  dynamic bookingDetails;
  dynamic bookingId;
  dynamic patientDetails;
  List testDetails = [];
  int totalPrice = 0;
  String bookingStatus = '';

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    Future.delayed(Duration.zero, () {
      bookingId = ModalRoute.of(context)?.settings.arguments as Map?;
      getBookingInfo();
    });
  }

  Future getBookingInfo() async {
    supabase.from('booking')
    .stream(primaryKey: ['id']).eq('id', bookingId['bookingId'])
    .listen((List<Map<String, dynamic>> data) {
      setState(() {
        bookingStatus = data[0]['status'];
      });
  });
    bookingDetails = await supabase
        .from('booking')
        .select()
        .match({'id': bookingId['bookingId']});
    labDetails = await supabase
        .from('labs')
        .select()
        .match({'id': bookingDetails[0]['lab_id']});
    patientDetails = await supabase
        .from('patient')
        .select()
        .match({'id': bookingDetails[0]['patient_id']});

    for (int id in bookingDetails[0]['tests']) {
      final testDetail =
          await supabase.from('tests').select().match({'id': id});
      testDetails.add(testDetail);
      totalPrice = totalPrice + int.parse(testDetail[0]['price'].toString());
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

  String convert24HourTo12Hour(String time24) {
    DateTime dateTime = DateFormat('HH:mm').parse(time24);
    String time12 = DateFormat('h:mm a').format(dateTime);
    return time12;
  }

  String formatToCustomFormat(String inputDate) {
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'rejected':
        return Colors.red;
      case 'confirmed':
        return Colors.green;
      case 'completed':
        return ElabColors.primaryColor;
      default:
        return Colors.amberAccent.shade700;
    }
  }

  Future downloadResult() async {
    try {
      final Uint8List file = await supabase.storage
          .from('testresults')
          .download("results/${bookingDetails[0]['id']}");
      DateTime now = DateTime.now();
      String concatenatedTime =
          '${now.hour}${now.minute}${now.second}${now.millisecond}';
      final targetFile = File(
          'storage/emulated/0/Download/Elab_$concatenatedTime${bookingDetails[0]['id']}.pdf');
      targetFile.writeAsBytesSync(file);

      Fluttertoast.showToast(
          msg: "File saved to Downloads ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0);
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Unable to download ",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLoading
          ? null
          : AppBar(
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
              backgroundColor: Colors.white,
              title: Text(
                'Booking Details',
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: GoogleFonts.hammersmithOne().fontFamily,
                    fontWeight: FontWeight.bold),
              ),
            ),
      body: isLoading
          ? const Center(
              child: SpinKitFadingCircle(color: ElabColors.primaryColor),
            )
          : SingleChildScrollView(child: listBookingDetails()),
      bottomNavigationBar: isLoading
          ? null
          : bookingStatus == 'pending' && bookingDetails[0]['pay_status'] =='pending'
              ? bottomNavBar()
              : null,
    );
  }

  Column listBookingDetails() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              labDetails[0]['labname'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              labDetails[0]['city'],
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                const Text("status: "),
                Text(bookingStatus,
                    style: TextStyle(
                        color: _getStatusColor(bookingStatus),
                        fontSize: 15,
                        fontFamily: GoogleFonts.poppins().fontFamily))
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Tests Selected",
              style: TextStyle(
                  color: ElabColors.greyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 1, // Adjust the height of the border line as needed
              decoration: BoxDecoration(
                color: ElabColors.greyColor2, // Color of the border line
                borderRadius:
                    BorderRadius.circular(2), // Adjust the radius as needed
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: testDetails.length,
                itemBuilder: (context, index) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        testDetails[index][0]['testname'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.currency_rupee,
                            color: Colors.black,
                            size: 20,
                          ),
                          Text(
                            testDetails[index][0]['price'].toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ],
                  );
                }),
            const Text(
              "Time Slot",
              style: TextStyle(
                  color: ElabColors.greyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 1, // Adjust the height of the border line as needed
              decoration: BoxDecoration(
                color: ElabColors.greyColor2, // Color of the border line
                borderRadius:
                    BorderRadius.circular(2), // Adjust the radius as needed
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              formatToCustomFormat(bookingDetails[0]['date'].toString()),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "${convert24HourTo12Hour(bookingDetails[0]['timeslot'])} - ${addOneHourToCurrentTime(convert24HourTo12Hour(bookingDetails[0]['timeslot']))}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Patient Details",
              style: TextStyle(
                  color: ElabColors.greyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              height: 1, // Adjust the height of the border line as needed
              decoration: BoxDecoration(
                color: ElabColors.greyColor2, // Color of the border line
                borderRadius:
                    BorderRadius.circular(2), // Adjust the radius as needed
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              patientDetails[0]['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Age : ${patientDetails[0]['age']}  Gender: ${patientDetails[0]['gender']}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              width: double.infinity,
              height: 1, // Adjust the height of the border line as needed
              decoration: BoxDecoration(
                color: ElabColors.greyColor2, // Color of the border line
                borderRadius:
                    BorderRadius.circular(2), // Adjust the radius as needed
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                const Text(
                  "Total amount payable: ",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Icon(Icons.currency_rupee),
                Text(
                  totalPrice.toString(),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green),
                ),
                Text(" ("+bookingDetails[0]['pay_status']+")",style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: FontWeight.bold),)

              ],
            ),
            const SizedBox(height: 10,),
            bookingDetails[0]['status'] == 'completed'? Center(
              child: ElevatedButton.icon(
                  onPressed: () {
                    downloadResult();
                  },
                  style: const ButtonStyle(
                      backgroundColor:
                          MaterialStatePropertyAll(ElabColors.primaryColor)),
                  icon: const Icon(Icons.download),
                  label: const Text("Result")),
            ): const Text('')
          ],
        ),
      ),
    ]);
  }

  Material bottomNavBar() {
    return Material(
        elevation: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 15, 8),
              child: ElevatedButton(
                onPressed: () {
                  showAlert(
                      context, 'Are you sure you want to cancel this booking?');
                },
                style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(
                      Color.fromARGB(255, 211, 78, 78)),
                  fixedSize: MaterialStateProperty.all(
                    const Size(150, 40),
                  ),
                ),
                child: Text('Cancel Booking',
                    style: TextStyle(
                      fontFamily: GoogleFonts.poppins().fontFamily,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
        ));
  }

  void showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the alert dialog
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () async {
                await supabase
                    .from('booking')
                    .delete()
                    .match({'id': bookingId['bookingId']});

                Fluttertoast.showToast(
                    msg: "Booking cancelled",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP,
                    timeInSecForIosWeb: 2,
                    backgroundColor: ElabColors.greyColor,
                    textColor: Colors.white,
                    fontSize: 16.0);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
                // ignore: use_build_context_synchronously
                Navigator.pop(context);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }
}
