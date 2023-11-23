import 'dart:io';

import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewResults extends StatefulWidget {
  const ViewResults({super.key});

  @override
  State<ViewResults> createState() => _ViewResultsState();
}

class _ViewResultsState extends State<ViewResults> {
  dynamic booking;
  dynamic bookingCount;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  

  @override
  void initState() {
    super.initState();
    getBookingData();
  }



  Future getBookingData() async {
    setState(() {
      isLoading = true;
    });

    booking = await supabase.from('booking').select().match({
      'user_id': supabase.auth.currentUser!.id,
      'status': 'completed'
    }).order('id');

    bookingCount = await supabase
        .from('booking')
        .select('id')
        .eq('user_id', supabase.auth.currentUser!.id);

    setState(() {
      isLoading = false;
    });
  }

  String formatToCustomFormat(String inputDate) {
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  String convert24HourTo12Hour(String time24) {
    DateTime dateTime = DateFormat('HH:mm').parse(time24);
    String time12 = DateFormat('h:mm a').format(dateTime);
    return time12;
  }

  Future downloadResult() async {
    try {
      final Uint8List file = await supabase.storage
          .from('testresults')
          .download("results/${booking[0]['id']}");
      DateTime now = DateTime.now();
      String concatenatedTime =
          '${now.hour}${now.minute}${now.second}${now.millisecond}';
      final targetFile = File(
          'storage/emulated/0/Download/Elab_$concatenatedTime${booking[0]['id']}.pdf');
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
    return RefreshIndicator(
      onRefresh: getBookingData,
      child: isLoading
          ? const Center(
              child: Text(
                "Loading...",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            )
          : bookingCount.length == 0
              ? const Center(
                  child: Text(
                    "No results yet",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                )
              : showBookings(),
    );
  }

  showBookings() {
    return ListView.builder(
        itemCount: booking.length,
        itemBuilder: (context, index) {
          return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/bookingdetails',
                    arguments: {'bookingId': booking[index]['id']});
              },
              child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    formatToCustomFormat(
                                        booking[index]['date'].toString()),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const Text(
                                    " | ",
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    convert24HourTo12Hour(
                                        booking[index]['timeslot'].toString()),
                                    style: const TextStyle(fontSize: 16),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "${booking[index]['tests'].length} tests",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ]),
                        ElevatedButton.icon(
                            onPressed: () {
                              downloadResult();
                            },
                            style: const ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(
                                    ElabColors.primaryColor)),
                            icon: const Icon(Icons.download),
                            label: const Text("Result"))
                      ],
                    ),
                  )));
        });
  }
}
