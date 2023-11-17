import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Tests extends StatefulWidget {
  const Tests({super.key});

  @override
  State<Tests> createState() => _TestsState();
}

class _TestsState extends State<Tests> {

  final supabase = Supabase.instance.client;
  dynamic tests;
  bool isLoading = true;
  dynamic labDetails;
  Set selectedItems = {};
  List selectedItemsList = [];
  dynamic price = 0;
  String opentime = '';
  String closetime = '';
  int labId = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      labDetails = ModalRoute.of(context)?.settings.arguments as Map?;
      opentime = labDetails['opentime'];
      closetime = labDetails['closetime'];
      labId = labDetails['labId'];
      getTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.white,
      appBar: isLoading ? null : AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Colors.white,
        title:Text(labDetails['labName'], style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.hammersmithOne().fontFamily, color: Colors.black),),
      ),
      body: isLoading ?const SpinKitFadingCircle(color: ElabColors.primaryColor,):
      tests.length == 0 ?const Center(child:Text("No tests available")):Padding(
      padding: const EdgeInsets.fromLTRB(10,10,10,0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,):
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Select your tests", style: TextStyle(
              fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: FontWeight.bold,
              fontSize: 16,
            ),),
          ),

          testList()
        ],
      ),
    ),
    bottomNavigationBar: selectedItemsList.isNotEmpty ? 
      bottomNavBar()
      :
      null
    );
  }

  



  Expanded testList() {
    return Expanded(
      child:ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index){
          return Container(
            margin: const EdgeInsets.fromLTRB(5,8,5,5),
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
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tests[index]['testname'], style:const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18
                    ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee_sharp, color: Colors.black,),
                        Text(tests[index]['price'].toString(), style: const TextStyle(
                          fontWeight: FontWeight.bold,color: Colors.green, fontSize: 18
                        ),)
                      ],
                    ),
                    const SizedBox(height: 10,),
                    Text('Requirements', style: TextStyle(color: ElabColors.greyColor,fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: FontWeight.bold),),
                    const SizedBox(height: 10,),
                    Text(tests[index]['requirements'],)
                  ],
                ),
                 trailing: Checkbox(
                  value: selectedItems.contains(tests[index]['id']),
                  onChanged: (value) {
                    setState(() {

                      if (value!) {
                        selectedItems.add(tests[index]['id']);
                        price = price + tests[index]['price']; 
                      } else {
                       selectedItems.remove(tests[index]['id']);
                       price = price - tests[index]['price'];
                      }
                     selectedItemsList = selectedItems.toList();

                    });
                  },
                  activeColor: ElabColors.primaryColor,
                 )

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15,8,8,8),
            child: Text("${selectedItemsList.length.toString()} tests selected",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ,),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8,8,15,8),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/timeslot',arguments: {'tests':selectedItemsList, 'price':price, 'opentime':opentime, 'closetime':closetime,'labId':labId});
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


  Future getTests() async {
    setState(() {
      isLoading = true;
    });
    
    tests = await supabase.from('tests').select().match({'lab_id':labDetails['labId']});

    setState(() {
      isLoading = false;
    });
  }  

}