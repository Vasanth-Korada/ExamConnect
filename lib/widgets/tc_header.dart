import 'package:flutter/material.dart';
import 'package:exam_connect/widgets/text-widget.dart';

class TCHeader extends StatefulWidget {
  @override
  _TCHeaderState createState() => _TCHeaderState();
}

class _TCHeaderState extends State<TCHeader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          HeaderTextFancyWidget(
            content: "Exam Connect".toUpperCase(),
            fontSize: 32,
          ),
          SizedBox(
            height: 10,
          ),
          PrimaryTextWidget(
            content: "Unleash your skills",
            fontSize: 16,
          ),
        ],
      ),
    );
  }
}
