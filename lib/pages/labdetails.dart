import 'dart:io';
import 'dart:math';

import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
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
  bool isReviewing = true;
  dynamic lab;
  dynamic reviews;
  dynamic avgRating = 0;

  final TextEditingController reviewController = TextEditingController();

  final ImagePicker imagePicker = ImagePicker();
  dynamic imageFile;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, (){
       labDetails = ModalRoute.of(context)?.settings.arguments as Map?;
       setState(() {
         isLoading = false;
       }); 
       getReviewDetails();     
    });
  }

  @override
  void dispose() {
    reviewController.dispose();
    super.dispose();
  }
  
  Color getRandomColor() {
    final List<Color> colorSet = [
      ElabColors.primaryColor.withOpacity(0.5),
      Color.fromARGB(255, 235, 16, 16).withOpacity(0.5),
      Color.fromARGB(255, 60, 160, 5).withOpacity(0.5),
      Color.fromARGB(255, 13, 193, 175).withOpacity(0.5),
      Color.fromARGB(255, 192, 198, 10).withOpacity(0.5),
      Color.fromARGB(255, 154, 12, 186).withOpacity(0.5),
    ];

    final random = Random();
    return colorSet[random.nextInt(colorSet.length)];
  }

  Future getReviewDetails() async {
    lab = await supabase.from('labs').select().match({'id':labDetails['labId']});
    
    reviews = await supabase.from('ratings').select()
    .match({'lab_id': labDetails['labId']})
    .neq('review','');

    if(lab[0]['rating_count']!=0){
      avgRating = (lab[0]['rating']/lab[0]['rating_count']); 
    }
    setState(() {
      isReviewing = false;
    });
  }

  Future addRating() async{
    if(stars == null || stars == 0){
      return;
    }
    setState(() {
      isReviewing = true;
    });
    final userName = await supabase.from('profile').select('name').match({'user_id':supabase.auth.currentUser!.id});
    final Map ratings = {
      'stars': stars,
      'review': reviewController.text,
      'user_id': supabase.auth.currentUser!.id,
      'lab_id': labDetails['labId'],
      'user_name':userName[0]['name']
    };
    await supabase.from('ratings').insert(ratings);
    await supabase.from('labs')
    .update(
      {
        'rating_count': lab[0]['rating_count'] + 1, 
        'rating':(lab[0]['rating'] + stars)
      }
      )
      .match({'id':labDetails['labId']});
    reviewController.text='';
    getReviewDetails();
  }

  Future uploadImage() async {
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final imagePath = pickedImage.path;
      setState(() {
        imageFile = File(imagePath);
      });
      if (imageFile != null) {            
          showImage(context);
      }
    }
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
                      padding: EdgeInsets.fromLTRB(0, 3, 0, 3),                     
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
                          Icon(Icons.check_box_outlined,size:30,color: ElabColors.primaryColor),
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
                    GestureDetector(
                        onTap: () {
                          uploadImage();
                        }, 
                      child:Container(               
                      padding: EdgeInsets.fromLTRB(0, 3, 0, 3),
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
                      child:Column(
                        children: [
                          Icon(Icons.upload_file_outlined, size:30,color: ElabColors.primaryColor,),
                          Text('Upload Prescription')
                        ],
                      )
                      )
                    )
                  ],
                )
                )
            ]),

        //Health Packages
          InkWell(
            onTap: (){
              Navigator.pushNamed(context, '/health_packages',
              arguments: {
                'labId': labDetails['labId'],
                'labName': labDetails['labName'],
              });
            },
           child: Container(
              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
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
                            Icon(Icons.card_giftcard_outlined, size: 30, color: ElabColors.primaryColor,),
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
          ),

        //Ratings and Reviews
        isReviewing? 
          Column(
            children: [
              const SizedBox(height: 20,),
              SpinKitFadingCircle(color: ElabColors.primaryColor,),
            ],
          )
        :
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
                    itemSize: 30,
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
                  hintText: "Describe your experience (optional)"
                ),
              ),
              Row(
              children: [
                Text(avgRating.toDouble().toStringAsFixed(1),style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35),),
                Text(" ("+lab[0]['rating_count'].toString()+ " ratings)")
            ],
          ),

            ],
          )

          ),
          reviews != null && reviews.isNotEmpty ?
          Expanded(child: 
          ListView.builder(
            shrinkWrap: true,
            itemCount: reviews.length,
            itemBuilder: (context, index){
            return Container(
            margin: const EdgeInsets.fromLTRB(5,8,5,5),
            decoration: BoxDecoration(
                color: Colors.white,
               border: Border(
                  top: BorderSide(width: 1.0, color: ElabColors.greyColor), // Customize color and width
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                title: Row(
                  children: [
                    Container(
                        height: 30,
                        width: 30,
                        decoration: BoxDecoration(
                          color: getRandomColor(),
                          borderRadius: BorderRadius.circular(
                              25.0), // Set the border radius to make it rounded
                        ),
                        child: Center(
                          child: Text(
                            reviews[index]['user_name'][0].toString(),
                            style: TextStyle(
                              fontFamily:
                                  GoogleFonts.outfit().fontFamily,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(width: 8,),
                    Text(reviews[index]['user_name'], style: TextStyle(fontWeight: FontWeight.bold),),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBarIndicator(
                            rating: reviews[index]['stars'].toDouble(),
                            itemBuilder: (context, index) => Icon(
                                Icons.star,
                                color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                        ),
                    Text(reviews[index]['review'])
                  ],
                ),
                  
              )
              );
            }
          )
          )
          : 
          isReviewing? Text(''):Container(
            margin: EdgeInsets.all(10),
            child: Text("No reviews yet"))
        ],
      ),
    );
  }

  void showImage(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          content:  Image.file(
                  File(imageFile!.path),
                  height: 300,
                  width: 200,
                  fit: BoxFit.cover,
                ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context, 'Cancel');
                },
                child: Text('Cancel'),
              ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/patientdetails',
                arguments: {
                  'identifier': 'prescription',
                  'labId':labDetails['labId'],
                  'image':imageFile
                  });
              },
              style:ButtonStyle(
                backgroundColor: const MaterialStatePropertyAll(ElabColors.primaryColor),
                fixedSize: MaterialStateProperty.all(
                  const Size(100, 40), 
                ),
                shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)))
                  ),
              child: const Text('Next', style: TextStyle(color: Colors.white),),
            ),
          ],
        );
      },
    );
  }
}
