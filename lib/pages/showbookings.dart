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
  String result = '';

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
      result = 'Tests';
    });
  }

  Future getPrescriptionData() async{
    setState(() {
      isLoading = true;
    });
    bookingsStream =  supabase.from('prescription').stream(primaryKey:['id']).eq('user_id', supabase.auth.currentUser!.id).order('id');

    bookingCount = await supabase.from('prescription').select('id').eq('user_id', supabase.auth.currentUser!.id);

    setState(() {
      isLoading = false;
      result = 'Prescription';
    });


  }

  String formatToCustomFormat(String inputDate) {
    DateTime dateTime = DateFormat('yyyy-MM-dd').parse(inputDate);
    String formattedDate = DateFormat('dd MMM yyyy').format(dateTime);
    return formattedDate;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading?const Center(child: Text("Loading...", style: TextStyle(
      fontSize: 16, fontWeight: FontWeight.bold
    ),),):bookingCount.length == 0 ?
    const Center(child: Text("No bookings yet", style: TextStyle(fontWeight: FontWeight.bold,
    fontSize: 16),),)
    :
    Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(onPressed: (){
                getBookingData();
              }, 
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
              child: Text('Tests', style: TextStyle(color: Colors.white),)),

              ElevatedButton(onPressed: (){
                 getPrescriptionData();
              }, 
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
              child: Text('Prescription', style: TextStyle(color: Colors.white),)),

              ElevatedButton(onPressed: (){
              }, 
              style: ButtonStyle(
                  backgroundColor: const MaterialStatePropertyAll(ElabColors.secondaryColor),
                  
                  shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                    ),
              child: Text('Packages', style: TextStyle(color: Colors.white),)),
            
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8,0,0,5),
          child: Row(
            children: [
              Text('Showing results from ',style: TextStyle(fontSize: 15),),
              Text(result, style:TextStyle(fontWeight: FontWeight.bold,fontSize: 16) ,)
            ],
          ),
        ),
        showBookings(),
      ],
    );
  }

  StreamBuilder<List<dynamic>> showBookings() {
    return StreamBuilder(
    stream: bookingsStream,
    builder: (context, AsyncSnapshot snapshot){
        if(snapshot.hasData){
          final booking = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
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
                        Text(booking[index]['lab_name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),),
                        const SizedBox(height: 5,),
                        Row(
                          children: [
                            Text(formatToCustomFormat( booking[index]['date'].toString()),
                                    style: const TextStyle(fontSize: 16) ,
                                    ),

                          ],
                        ),
                        const SizedBox(height: 5,),
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
