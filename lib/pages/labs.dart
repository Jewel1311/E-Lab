import 'dart:math';

import 'package:elab/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:longitude_and_latitude_calculator/longitude_and_latitude_calculator.dart';
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
  double EarthRadiusMeters = 6371000.0;
  dynamic currentLocation;

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

  Future getLabs() async {
    setState(() {
      isLoading = true;
    });

    if (searchController.text == '') {
      final uid = supabase.auth.currentUser!.id;
      final data =
          await supabase.from('profile').select().match({'user_id': uid});
      city = data[0]['city'];
    } else {
      city = searchController.text.trim();
    }
    labs = await supabase.from('labs').select().ilike('city', '%$city%');

    setState(() {
      isLoading = false;
    });
  }

  Future determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Fluttertoast.showToast(
            msg: "Location permission is required",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: ElabColors.greyColor,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      return;
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(
          msg: "Location permission is required",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: ElabColors.greyColor,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }
    setState(() {
      isLoading = true;
    });

    currentLocation = await Geolocator.getCurrentPosition();
    getNearbyLabs();
  }

  Future getNearbyLabs() async {
    labs = [];
    var lonAndLatDistance = LonAndLatDistance();
    final allLabs = await supabase.from('labs').select();
    for (dynamic lab in allLabs) {
      dynamic distance = lonAndLatDistance.lonAndLatDistance(
          lat1: currentLocation.latitude,
          lon1: currentLocation.longitude,
          lat2: lab['latitude'],
          lon2: lab['longitude'],
          km: true);
      if (distance < 10) {
        labs.add(lab);
      }
      setState(() {
        isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: isLoading
            ? const SpinKitFadingCircle(
                color: ElabColors.primaryColor,
              )
            : Column(
                children: [
                  searchBox(),
                  labs.length > 0 ? labList() : noLabsFound(),
                ],
              ),
      ),
    );
  }

  Padding noLabsFound() {
    return const Padding(
      padding: EdgeInsets.all(20.0),
      child: Center(
        child: Text(
          "No Labs found in your area !",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Expanded labList() {
    return Expanded(
        child: ListView.builder(
            itemCount: labs.length,
            itemBuilder: (context, index) {
              return Container(
                  margin: const EdgeInsets.fromLTRB(10, 8, 10, 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: Offset(0, 2), // changes position of shadow
                      ),
                    ],
                  ),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/tests', arguments: {
                        'labId': labs[index]['id'],
                        'labName': labs[index]['labname'],
                        'opentime': labs[index]['opentime'],
                        'closetime': labs[index]['closetime']
                      });
                    },
                    child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 5),
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 0, 0, 0),
                                  child: Container(
                                    height: 45,
                                    width: 45,
                                    decoration: BoxDecoration(
                                      color: getRandomColor(),
                                      borderRadius: BorderRadius.circular(
                                          25.0), // Set the border radius to make it rounded
                                    ),
                                    child: Center(
                                      child: Text(
                                        labs[index]['labname'][0].toString(),
                                        style: TextStyle(
                                          fontFamily:
                                              GoogleFonts.outfit().fontFamily,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Flexible(
                                  child: Text(
                                    labs[index]['labname'],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 18,
                                    color: ElabColors.secondaryColor,
                                  ),
                                  Text(labs[index]['city']),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.phone,
                                    size: 18,
                                    color: ElabColors.secondaryColor,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  SelectableText(
                                      labs[index]['phone'].toString()),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Icon(Icons.access_time,
                                      size: 18,
                                      color: ElabColors.secondaryColor),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    convert24HourTo12Hour(
                                            labs[index]['opentime']) +
                                        ' - ' +
                                        convert24HourTo12Hour(
                                            labs[index]['closetime']),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              decoration: const BoxDecoration(
                                  color: ElabColors.greyColor2,
                                  shape: BoxShape.rectangle,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, '/tests',
                                        arguments: {
                                          'labId': labs[index]['id'],
                                          'labName': labs[index]['labname'],
                                          'opentime': labs[index]['opentime'],
                                          'closetime': labs[index]['closetime']
                                        });
                                  },
                                  child: const Icon(
                                      Icons.keyboard_arrow_right_outlined,
                                      size: 25,
                                      color: Colors.black),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ));
            }));
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
                  if (searchController.text != '') {
                    getLabs();
                  }
                },
                child: const Icon(
                  Icons.search,
                  size: 30,
                ),
              ),
              border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  borderSide: BorderSide.none),
            ),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 0, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    "Labs near you",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: GoogleFonts.poppins().fontFamily),
                  ),
                  const Icon(
                Icons.location_on_outlined,
                size: 25,
                color: ElabColors.secondaryColor,
              ),
                ],
              ),
              
              
              Padding(
                padding: const EdgeInsets.fromLTRB(0,0,15,0),
                child: ElevatedButton(
                    style: ButtonStyle(backgroundColor: MaterialStatePropertyAll(ElabColors.primaryColor)),
                    onPressed: () {
                      determinePosition();
                    },
                    child: Text('Find',style: TextStyle(fontFamily: GoogleFonts.poppins().fontFamily, fontWeight: FontWeight.bold),)),
              )
            ],
          ),
        )
      ],
    );
  }
}
