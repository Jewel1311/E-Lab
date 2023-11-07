import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
      color: ElabColors.color3,
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
              margin: const EdgeInsets.fromLTRB(10,8,10,8),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10), // Set the background color of the Container
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 189, 189, 189),
                      offset: Offset(0, 3),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  title: Row(
                    children: [
                      const Icon(Icons.biotech_rounded, color: ElabColors.primaryColor, size: 30,),
                      Text(labs[index]['labname'], 
                      style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0,15,0,0),
                    child: Text(labs[index]['city']+ ' | '+ convert24HourTo12Hour(labs[index]['opentime']) + ' - '+  convert24HourTo12Hour(labs[index]['closetime']),
                    style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  trailing: GestureDetector(
                    onTap: () {},
                    child: const Icon(Icons.arrow_forward_ios_sharp, size: 25, 
                    color: ElabColors.primaryColor),
                  ),
                ),
            );
          }
        )
    );
  }


  Column searchBox() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
          child: TextField(

                controller: searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
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
                      Radius.circular(50)
                    ),
                  ),
                ),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(15, 15, 0, 10),
          child: Row(
            children: [
              Text("Labs near you", style: 
              TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              ),
              Icon(Icons.location_on_outlined, size: 25,color: ElabColors.primaryColor,)
            ],
          ),
        )
      ],
    );
   
  }
}