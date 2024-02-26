import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LabDetails extends StatefulWidget {
  const LabDetails({super.key});

  @override
  State<LabDetails> createState() => _LabDetailsState();
}

class _LabDetailsState extends State<LabDetails> {

  final supabase = Supabase.instance.client;

  dynamic labDetails;
  bool isLoading = true;
  dynamic stars;

  final TextEditingController reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, (){
       labDetails = ModalRoute.of(context)?.settings.arguments as Map?;
       setState(() {
         isLoading = false;
       });      
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }

  Future addRating() async{
    final Map ratings = {
      'stars': stars,
      'review': reviewController.text,
      'user_id': supabase.auth.currentUser!.id,
      'lab_id': labDetails['labId']
    };
    await supabase.from('ratings').insert(ratings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isLoading? null: AppBar(
        title: Text(labDetails['labName'],
        style: TextStyle(fontWeight: FontWeight.bold, fontFamily: GoogleFonts.hammersmithOne().fontFamily),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
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
                      child: GestureDetector( 
                        onTap: () {
                          Navigator.pushNamed(context, '/tests',
                            arguments: {
                              'labId': labDetails['labId'],
                              'labName': labDetails['labName'],
                            });
                        },
                        child:Column(
                        children: [
                          Icon(Icons.check_box_outlined),
                          Text('Select Tests')
                        ],
                      )
                      )
                    )
                  ],
                )
                ),
                Expanded(
                flex: 1,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(10),
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
                      child: Column(
                        children: [
                          Icon(Icons.upload_file_outlined),
                          Text('Upload Prescription')
                        ],
                      )
                    )
                  ],
                )
                )
            ]),

        //Health Packages

          Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
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
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row( 
                          children: [
                            Icon(Icons.card_giftcard_outlined, size: 30,),
                            Text(' Health Packages')
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Explore',style: TextStyle(color: ElabColors.primaryColor),),
                      )
                    ],
                  ),
                  
                ],
              )
            ),

        //Ratings and Reviews
        Container(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ratings and reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
              const SizedBox(height: 8,),
              Text("Rate your experience"),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RatingBar.builder(
                    initialRating: 0,
                    direction: Axis.horizontal,
                    itemBuilder: (context, _)=>Icon(Icons.star, color: Colors.amber,), 
                    onRatingUpdate: (rating)=>{
                      stars = rating
                    }
                    ),

                    TextButton(onPressed: () {
                      addRating();
                    }, child: Text('Post', style: TextStyle(fontSize: 16, color: ElabColors.primaryColor),))
                ],
              ),
              TextField(
                controller: reviewController,
                decoration: InputDecoration(
                  border:  OutlineInputBorder(borderRadius:BorderRadius.circular(8)),
                  hintText: "Write something..."
                ),
              )
            ],
          ))


        ],
      ),
    );
  }
}
