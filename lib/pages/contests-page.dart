import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_connect/classes/UserModel.dart';
import 'package:exam_connect/helpers/check-internet-connection.dart';
import 'package:exam_connect/helpers/crud.dart';
import 'package:exam_connect/widgets/appbar.widget.dart';
import 'package:exam_connect/widgets/drawer.widget.dart';
import 'package:exam_connect/widgets/streambuilder.widget.dart';
import 'package:exam_connect/widgets/text-widget.dart';

class ContestsPage extends StatefulWidget {
  final Map userObj;
  ContestsPage({@required this.userObj});
  @override
  _ContestsPageState createState() => _ContestsPageState();
}

class _ContestsPageState extends State<ContestsPage> {
  CrudMethods crudObj = new CrudMethods();
  var contests;

  @override
  void initState() {
    super.initState();
    
    print(widget.userObj);
    checkInternetConnectivity(context).then((val) {
      val == true
          ? ShowDialog(context: context, content: "No Internet Connection!")
          : print("Connected");
    });
    crudObj.getContests().then((results) {
      setState(() {
        contests = results;
        debugPrint(contests.toString());
        
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: new DrawerWidget(username: widget.userObj["displayName"]),
      appBar: GradientAppBar(
        content: "Exam Connect",
        appBar: AppBar(),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: new HeaderTextFancyWidget(
                  content: "Ongoing Exams",
                ),
              ),
              new Icon(Icons.arrow_right)
            ],
          ),
          Flexible(
              child: MyStreamBuilderWidget(
            stream: contests,
            isArchived: false,
            userObj: widget.userObj,
            showMore: false,
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: new HeaderTextFancyWidget(
                  content: "Upcoming Exams",
                ),
              ),
              Row(
                children: <Widget>[
                  new Icon(Icons.arrow_right),
                ],
              )
            ],
          ),
          Flexible(
              child: MyStreamBuilderWidget(
            stream: contests,
            isArchived: true,
            userObj: widget.userObj,
            showMore: true,
          )),
        ],
      ),
    );
  }
}
