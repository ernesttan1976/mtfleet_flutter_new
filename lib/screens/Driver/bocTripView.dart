import 'package:flutter/material.dart';
import 'package:transport_flutter/config/dio.dart';
import 'package:transport_flutter/screens/Driver/selectVehicle.dart';

class BOCTripPageView extends StatefulWidget {
  BOCTripPageView({Key? key}) : super(key: key);

  @override
  _BOCTripPageViewState createState() => _BOCTripPageViewState();
}

class _BOCTripPageViewState extends State<BOCTripPageView> {
  final dioClient = AuthedDio.instance.dio;

  // TripForm Variable
  var tripFormData;
  dynamic userID;

  // @override
  // void dispose() {
  //   mypageViewController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SelectVehicleFormScreen(
      key: Key("SelectVehicleForm"),
    )

        // PageView.builder(
        //   physics: new NeverScrollableScrollPhysics(),
        //   controller: mypageViewController,
        //   itemBuilder: (BuildContext context, int index) {
        //     print("index $index");
        //     if (index == 0) {
        //       return
        //     } else {
        //
        //       return BOCELogBookFormScreen(
        //         tripData: tripFormData,
        //         onPrev: onPrevScreen,
        //         key: Key("BOCLOGFORM"),
        //       );
        //     }
        //   },
        //   itemCount: 2,
        // ),
        );
  }
}
