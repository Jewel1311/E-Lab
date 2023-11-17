import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TimeSlot extends StatefulWidget {
  const TimeSlot({super.key});

  @override
  State<TimeSlot> createState() => _TimeSlotState();
}

class _TimeSlotState extends State<TimeSlot> {

  dynamic testsMap;
  List timeIntervalList = [];
  bool slotsAvailable = true;
  bool isLoading = false;
  String selectedTime = '';
  String formattedDate ='';

  List<String> generateIntervals(String startTime, String endTime) {

    List<String> intervals = [];
    final format = DateFormat('HH:mm:ss');
    final currentTime = DateTime.now();

   if (_truncateMinutesAndSeconds(format.parse(startTime)).hour < 6 && _truncateMinutesAndSeconds(format.parse(startTime)).hour > 18){
    startTime = '06:00:00';
   } 
  
   if (_truncateMinutesAndSeconds( format.parse(endTime)).hour > 18){
    endTime = '18:00:00';
   } 

    // Ensure startTime is greater than or equal to the current time
    final startDateTime = _truncateMinutesAndSeconds(currentTime).hour > format.parse(startTime).hour
        ? currentTime
        : format.parse(startTime);

    final start = TimeOfDay.fromDateTime(_truncateMinutesAndSeconds(startDateTime));
    final end = TimeOfDay.fromDateTime(_truncateMinutesAndSeconds(format.parse(endTime)));
    

    TimeOfDay i = start;
    

    while (i.hour < end.hour || (i.hour == end.hour && i.minute <= end.minute)) {
      intervals.add(DateFormat('hh:mm a').format(DateTime(2023, 1, 1, i.hour, i.minute)));

      // Add 1 hour in minutes and convert back to TimeOfDay
      i = TimeOfDay.fromDateTime(DateTime(2023, 1, 1, i.hour + 1, i.minute));
    }

    return intervals;
  }

  DateTime _truncateMinutesAndSeconds(DateTime dateTime) {
    if (dateTime.minute > 30) {
      return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour + 1, 0, 0);
    } else {
      return DateTime(dateTime.year, dateTime.month, dateTime.day, dateTime.hour, 0, 0);
    }
  }

  void nextDayDate() {
    DateTime now = DateTime.now();
    if (now.hour == 23 && now.minute >= 31) {
      now = now.add(const Duration(days: 1));
    }
    formattedDate = DateFormat('dd MMM yy').format(now);
  }

  void slotRemainingCheck(List timeIntervalList){
    if (timeIntervalList.isEmpty || timeIntervalList.length < 2 ){
      slotsAvailable = false;
    }
  }


  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
     Future.delayed(Duration.zero, () {
      testsMap = ModalRoute.of(context)?.settings.arguments as Map?;
      timeIntervalList = generateIntervals(testsMap['opentime'],testsMap['closetime']);
      slotRemainingCheck(timeIntervalList);
      nextDayDate();
      setState(() {
        isLoading = false;
      });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.white,
      appBar: isLoading? null: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text('Time Slot $formattedDate', style: TextStyle(color: Colors.black, fontFamily: GoogleFonts.hammersmithOne().fontFamily, fontWeight: FontWeight.bold),),
      ),
      body:   Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isLoading ?  const SpinKitFadingCircle(color: ElabColors.primaryColor,):
          slotsAvailable? 
          timeslots()
          :noAvailableSlots(),
        ],
      ), 
      bottomNavigationBar: !isLoading && slotsAvailable && selectedTime != ''?  bottomNavBar() :null,
    );
  }

  Center noAvailableSlots() => const Center(child: Text('No slots available today !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),));

  Expanded timeslots() {
    return Expanded(child: ListView.builder(
          itemCount: timeIntervalList.length - 1,
          itemBuilder: (context, index){
            return Container(
              margin: const EdgeInsets.fromLTRB(10,8,10,5),
              decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: ElabColors.color3,
                      width: 1.0
                    )
                  )
                ),
                child: GestureDetector (onTap:(){
                   
                } , child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Radio(
                              value: timeIntervalList[index].toString(),
                              groupValue: selectedTime,
                              onChanged: (String? value) {
                                setState(() {
                              selectedTime = value!;
                                 });
                                },
                            ),
                          Text("${timeIntervalList[index]}   -   ${timeIntervalList[index + 1]}", 
                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                          ),      
                        ],
                      ),
                    ],
                  ),
                ),
                )
            );
          }
        )
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
                Navigator.pushNamed(context, '/patientdetails', arguments: {'tests':testsMap['tests'], 'price':testsMap['price'], 'labId':testsMap['labId'], 'time':selectedTime, 'date':formattedDate});
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