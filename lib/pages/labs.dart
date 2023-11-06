import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Labs extends StatefulWidget {
  const Labs({super.key});

  @override
  State<Labs> createState() => _LabsState();
}

class _LabsState extends State<Labs> {
  final supabase = Supabase.instance.client;
  dynamic labs;
  bool isLoading = false;

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

  Future getLabs() async{
    String city;
    setState(() {
      isLoading = true;
    });
    if (searchController.text == ''){
      final uid = supabase.auth.currentUser!.id;
      final data = await supabase.from('profile').select().match({'user_id':uid});
      city = data[0]['city'];
      searchController.text = city;
    }
    else{
      city = searchController.text;
    }
    labs = await supabase.from('labs').select().filter('city', 'ilike', '%$city%');

    setState(() {
      isLoading = false;
    });
  }
  
  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: isLoading? const SpinKitFadingCircle(color: ElabColors.primaryColor,) :
      Column(
        children: [
          searchBox(),
          labs.length> 0 ? labList():noLabsFound(),
        ],
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
              margin: const EdgeInsets.fromLTRB(10,0, 10,20),
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
                  title: Text(labs[index]['labname'], 
                  style: const TextStyle(fontWeight: FontWeight.bold,fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.fromLTRB(0,15,0,0),
                    child: Text(labs[index]['city']+ '  '+labs[index]['opentime'] + ' - '+ labs[index]['closetime'],
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


  Padding searchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 15),
      child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search city...',
              suffixIcon: GestureDetector(
                onTap: () {
                  getLabs();
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
    );
  }
}