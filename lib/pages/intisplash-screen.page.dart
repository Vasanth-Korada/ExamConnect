import 'dart:async';

import 'package:flutter/material.dart';
import 'package:talent_connect/widgets/tc_header.dart';

class InitSplashScreen extends StatefulWidget {
  final Function afterSplashCallback;
  InitSplashScreen({@required this.afterSplashCallback});
  @override
  _InitSplashScreenState createState() => _InitSplashScreenState();
}

class _InitSplashScreenState extends State<InitSplashScreen> {
  @override
  Widget build(BuildContext context) {
    Timer(Duration(milliseconds: 3000), () {
      print("Hello");
      widget.afterSplashCallback();
    });

    var assetsImage = new AssetImage('assets/tc_new_gif.gif');
    var image = new Image(
      image: assetsImage,
    );

    return Scaffold(
      backgroundColor: Color(0XFFf9fafd),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TCHeader(),
          Container(
            child: new Center(
              child: image,
            ),
          ),
        ],
      ),
    );
  }
}
