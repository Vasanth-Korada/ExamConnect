import 'package:flutter/material.dart';
import 'package:talent_connect/widgets/raised-button.dart';

class ExamPageButtonBar extends StatefulWidget {
  final int qnumber;
  final int totalQuestions;
  final Function onPrevClicked;
  final Function onSubmitClicked;
  final Function onNextClicked;

  const ExamPageButtonBar(
      {Key key,
      @required this.qnumber,
      @required this.totalQuestions,
      @required this.onPrevClicked,
      @required this.onSubmitClicked,
      @required this.onNextClicked})
      : super(key: key);

  @override
  _ExamPageButtonBarState createState() => _ExamPageButtonBarState();
}

class _ExamPageButtonBarState extends State<ExamPageButtonBar> {
  @override
  Widget build(BuildContext context) {
    print("QNumber" + widget.qnumber.toString());
    print("TQues" + widget.totalQuestions.toString());
    return ButtonBar(
      alignment: MainAxisAlignment.center,
      layoutBehavior: ButtonBarLayoutBehavior.padded,
      children: [
        widget.qnumber == 0
            ? Container()
            : CustomRaisedButton(
                isNext: false,
                height: 50,
                width: MediaQuery.of(context).size.width / 2 - 20,
                // color: Color(0xFF9a65db),
                color: Colors.grey.shade500,
                onPressed: () {
                  widget.onPrevClicked();
                },
                buttonText: "Prev"),
        (widget.totalQuestions - 1) == widget.qnumber
            ? CustomRaisedButton(
                color: Colors.green,
                height: 50,
                width: MediaQuery.of(context).size.width / 2 - 20,
                onPressed: () {
                  widget.onSubmitClicked(context);
                },
                isSubmit: true,
                isNext: true,
                buttonText: "Submit")
            : CustomRaisedButton(
                isNext: true,
                isSubmit: false,
                height: 50,
                width: MediaQuery.of(context).size.width / 2 - 20,
                onPressed: () {
                  widget.onNextClicked();
                },
                buttonText: "Next"),
      ],
    );
  }
}
