import 'package:flutter/material.dart';
import 'package:exam_connect/helpers/crud.dart';
import 'package:exam_connect/widgets/appbar.widget.dart';
import 'package:exam_connect/widgets/streambuilder.widget.dart';

class AllArchivedContests extends StatefulWidget {
  final userObj;
  AllArchivedContests({this.userObj});
  @override
  _AllArchivedContestsState createState() => _AllArchivedContestsState();
}

class _AllArchivedContestsState extends State<AllArchivedContests> {
  CrudMethods crudObj = new CrudMethods();
  var contests;

  @override
  void initState() {
    crudObj.getContests().then((results) {
      setState(() {
        contests = results;
        debugPrint(contests.toString());
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new GradientAppBar(
            content: "Archived Contests", appBar: new AppBar()),
        body: Scrollbar(
          child: MyStreamBuilderWidget(
            stream: contests,
            isArchived: true,
            userObj: widget.userObj,
            scrollDirection: Axis.vertical,
            contestsCount: "all",
            showMore: false,
          ),
        ));
  }
}
