import 'package:flutter/material.dart';
import 'package:exam_connect/widgets/text-widget.dart';

class CustomRaisedButton extends StatefulWidget {
  final double height;
  final double width;
  final Function onPressed;
  final String buttonText;
  final Color color;
  final bool isNext;
  final bool isSubmit;

  const CustomRaisedButton(
      {Key key,
      @required this.height,
      @required this.width,
      @required this.onPressed,
      @required this.buttonText,
      this.isNext,
      this.isSubmit,
      this.color})
      : super(key: key);

  @override
  _CustomRaisedButtonState createState() => _CustomRaisedButtonState();
}

class _CustomRaisedButtonState extends State<CustomRaisedButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(widget.color),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.0),
                  side: BorderSide(color: Colors.red))),
        ),
        onPressed: () {
          widget.onPressed();
        },
        child: widget.isNext
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeaderTextWidget(
                    content: widget.buttonText,
                    color: Colors.white,
                  ),
                  widget.isSubmit
                      ? Icon(Icons.done)
                      : Icon(Icons.arrow_right_alt_rounded)
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RotatedBox(
                      quarterTurns: 2,
                      child: Icon(Icons.arrow_right_alt_rounded,
                          color: Colors.white)),
                  HeaderTextWidget(
                    content: widget.buttonText,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}
