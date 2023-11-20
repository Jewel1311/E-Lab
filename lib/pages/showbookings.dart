import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShowBookings extends StatefulWidget {
  const ShowBookings({super.key});

  @override
  State<ShowBookings> createState() => _ShowBookingsState();
}

class _ShowBookingsState extends State<ShowBookings> {

  dynamic bookingsStream;
  dynamic bookingCount;
  bool isLoading = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    getBookingData();
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

  Future getBookingData() async{
    setState(() {
      isLoading = true;
    });

    bookingsStream =  supabase.from('booking').stream(primaryKey:['id']).eq('user_id', supabase.auth.currentUser!.id).order('id');

    bookingCount = await supabase.from('booking').select('id').eq('user_id', supabase.auth.currentUser!.id);

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


  @override
  Widget build(BuildContext context) {
    return isLoading?const Center(child: Text("Loading...", style: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold
    ),),):bookingCount.length == 0 ?
    const Center(child: Text("No bookings yet", style: TextStyle(fontWeight: FontWeight.bold,
    fontSize: 16),),)
    :
    showBookings();
  }

  StreamBuilder<List<dynamic>> showBookings() {
    return StreamBuilder(
    stream: bookingsStream,
    builder: (context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          final booking = snapshot.data!;
          return ListView.builder(
            itemCount: booking.length,
            itemBuilder: (context, index){
             return GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/bookingdetails', arguments: {
                    'bookingId': booking[index]['id'] 
                  });
                },
                child:Container(
              margin: const EdgeInsets.fromLTRB(10,8,10,10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
              ),
              child:Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children:[
                        Row(
                          children: [
                            Text(formatToCustomFormat( booking[index]['date'].toString()),
                                    style: const TextStyle( fontWeight: FontWeight.bold, fontSize: 16) ,
                                    ),
                            const Text(" | ", style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),

                            Text(convert24HourTo12Hour(booking[index]['timeslot'].toString()), style: const TextStyle(fontSize: 16),)
                          ],
                        ),
                        const SizedBox(height: 10,),
                        Text("${booking[index]['tests'].length} tests booked", style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold,
                        ),),
                        const SizedBox(height: 10,),
                        Row(
                          children: [
                            const Text('status: '),
                            Text(booking[index]['status'],
                            style: TextStyle(color: _getStatusColor(booking[index]['status']), fontSize: 15, fontFamily: GoogleFonts.poppins().fontFamily),
                            ),
                          ],
                        ),
                        ]
                    ),
                    const Icon(Icons.chevron_right_outlined,size: 40,)
                  ],
                ),
              )
              )
             );
            }
            
          );
        }
        return Container();
    }
  );
  }
  
}
