import 'package:flutter/material.dart';

class HeaderTextWidget extends StatelessWidget {
  final String content;
  final Color color;
  final TextAlign textalign;
  final FontWeight fontweight;
  final double fontSize;
  HeaderTextWidget(
      {@required this.content,
      this.color,
      this.textalign,
      this.fontweight,
      this.fontSize});
  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: textalign,
      style: TextStyle(
          fontFamily: 'GoogleSansMedium',
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 16,
          color: color),
    );
  }
}

class HeaderTextFancyWidget extends StatelessWidget {
  final String content;
  final TextAlign textAlign;
  final Color color;
  final double fontSize;
  HeaderTextFancyWidget(
      {@required this.content, this.textAlign, this.fontSize, this.color});
  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: textAlign,
      style: TextStyle(
          fontFamily: 'GoogleSansMedium',
          fontWeight: FontWeight.w600,
          fontSize: fontSize ?? 16,
          color: color ?? Color(0xFF7A17CE)),
    );
  }
}

class PrimaryTextWidget extends StatelessWidget {
  final String content;
  final double fontSize;
  final Color color;
  final TextAlign textAlign;
  final FontStyle fontStyle;

  PrimaryTextWidget(
      {@required this.content,
      this.fontSize,
      this.color,
      this.textAlign,
      this.fontStyle});
  @override
  Widget build(BuildContext context) {
    return Text(
      content,
      textAlign: textAlign,
      style: new TextStyle(
          fontFamily: 'GoogleSansRegular',
          fontWeight: FontWeight.w500,
          fontStyle: fontStyle ?? FontStyle.normal,
          fontSize: 14,
          color: color),
    );
  }
}
