import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class Labs extends StatefulWidget {
  const Labs({super.key});

  @override
  State<Labs> createState() => _LabsState();
}

class _LabsState extends State<Labs> {
  final supabase = Supabase.instance.client;
  dynamic labs;
  bool isLoading = false;
  dynamic city;

  final TextEditingController searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    getLabs();
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }


  String convert24HourTo12Hour(String time24Hour) {
    final inputFormat = DateFormat('HH:mm:ss');
    final outputFormat = DateFormat('h:mm a');
    final dateTime = inputFormat.parse(time24Hour);
    final time12Hour = outputFormat.format(dateTime);
    return time12Hour;
}



  Future getLabs() async{
    setState(() {
      isLoading = true;
    });

    if (searchController.text == '') {
      final uid = supabase.auth.currentUser!.id;
      final data = await supabase.from('profile').select().match({'user_id':uid});
      city = data[0]['city'];
    }
    else{
      city = searchController.text;
    }
    labs = await supabase.from('labs').select().ilike('city', '%$city%');

    setState(() {
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {


    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,) :
        Column(
          children: [
            searchBox(),
            labs.length> 0 ? labList():noLabsFound(),
          ],
        ),
      ),
    );
  }

  Padding noLabsFound() {
    return const Padding(
          padding:  EdgeInsets.all(20.0),
          child: Center(child: Text("No Labs found in your area !", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),),
        );
  }
  

  Expanded labList() {
    return Expanded(child: ListView.builder(
          itemCount: labs.length,
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
                   Navigator.pushNamed(context, '/tests', arguments: {'labId' :labs[index]['id'], 'labName':labs[index]['labname'], 'opentime':labs[index]['opentime'], 'closetime':labs[index]['closetime']});
                } , child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.biotech_rounded, color: ElabColors.secondaryColor, size: 30,),
                          Text(labs[index]['labname'], 
                          style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8,),
                    
                      Padding(
                        padding: const EdgeInsets.fromLTRB(5,0,0,0),
                        child: Row(
                        children: [
                          const Icon(Icons.phone, size: 20,),
                          const SizedBox(width: 5,),
                          SelectableText(labs[index]['phone'].toString())
                        ],
                                          ),
                      ),
                   const SizedBox(height: 10,),
                   Padding(
                     padding: const EdgeInsets.fromLTRB(5,0,0,0),
                     child: Text(labs[index]['city']+ ' | '+ convert24HourTo12Hour(labs[index]['opentime']) + ' - '+  convert24HourTo12Hour(labs[index]['closetime']),
                      style: const TextStyle(color: Colors.black),
                      ),
                   ),
                    ],
                  ),
                  trailing: Container(
                    decoration: const BoxDecoration(
                      color: ElabColors.greyColor2,
                      shape: BoxShape.rectangle, 
                      borderRadius: BorderRadius.all(Radius.circular(10))
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/tests', arguments: {'labId' :labs[index]['id'], 'labName':labs[index]['labname'],'opentime':labs[index]['opentime'], 'closetime':labs[index]['closetime']});
                        },
                        child: const Icon(Icons.keyboard_arrow_right_outlined, size: 25, color: Colors.black),
                      ),
                    ),
                  )

                ),
                )
            );
          }
        )
    );
  }

  Column searchBox() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: TextField(

                controller: searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: ElabColors.greyColor2,
                  hintText: 'Search city...',
                  suffixIcon: GestureDetector(
                    onTap: () {
                      if(searchController.text != ''){
                        getLabs();
                      }
                    },
                    child: const Icon(Icons.search, size: 30,),
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10)
                    ),
                    borderSide: BorderSide.none
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 0, 10),
          child: Row(
            children: [
              Text("Labs near you", style: 
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: GoogleFonts.poppins().fontFamily
              ),
              ),
              const Icon(Icons.location_on_outlined, size: 25,color: ElabColors.primaryColor,)
            ],
          ),
        )
      ],
    );
   
  }
}