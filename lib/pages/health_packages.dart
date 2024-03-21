import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthPackages extends StatefulWidget {
  const HealthPackages({super.key});

  @override
  State<HealthPackages> createState() => _HealthPackagesState();
}

class _HealthPackagesState extends State<HealthPackages> {

  final supabase = Supabase.instance.client;
  dynamic packages;
  bool isLoading = true;
  dynamic labDetails;

  @override
  void initState() {
    super.initState();
     Future.delayed(Duration.zero,(){
      labDetails = ModalRoute.of(context)?.settings.arguments as Map?;
      getPackages();
      
    });
  }



  Future getPackages() async {
    packages = await supabase.from('packages').select().match({'lab_id':labDetails['labId']}).order('id');
    setState(() {
      isLoading = false;
    });
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Health Packages", style: TextStyle(fontWeight: FontWeight.bold,fontFamily: GoogleFonts.hammersmithOne().fontFamily),),
      ),
      body:Column(
        children: [
          viewPackages(),
          isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,): packageList(),
        ],
      ) ,
    );
  }

  Padding viewPackages() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5,0,5,10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              isLoading ? const Text(''):Text('${packages.length} Packages', style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily,
                fontSize: 16 , fontWeight: FontWeight.bold 
              )
              ),
          ]
          ),
        ]
      ),
    );
  }

  Expanded packageList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: getPackages,
        child:ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index){
          return InkWell(
            onTap: (){
              Navigator.pushNamed(context, '/view_packages',
              arguments: {
                'package_id':packages[index]['id'],
                'labId': labDetails['labId'],
                'labName': labDetails['labName'],
              });
            }, 
            child: Container(
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
                    Text(packages[index]['name'], style:const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18
                    ),
                    ),
                    const SizedBox(height: 10,),
                    Row(
                      children: [
                        const Icon(Icons.currency_rupee_sharp, color: Colors.black,),
                        Text(packages[index]['price'].toString(), style: const TextStyle(
                          fontWeight: FontWeight.bold,color: Colors.green, fontSize: 18
                        ),)
                      ],
                    ),
                  ],
                ),
                )

              )
          );
        }
      )
      )
      );
  }

}