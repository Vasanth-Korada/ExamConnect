import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class MyCustomLoader extends StatelessWidget {
  final Color color;
  MyCustomLoader({this.color});
  @override
  Widget build(BuildContext context) {
    return SpinKitThreeBounce(
      color: color ?? Color(0XFF7A17CE),
      size: 35.0,
    );
  }
}
