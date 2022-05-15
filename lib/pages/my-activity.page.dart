import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';

import 'activity-quiz-info.page.dart';

class MyActivityPage extends StatefulWidget {
  @override
  _MyActivityPageState createState() => _MyActivityPageState();
}

class _MyActivityPageState extends State<MyActivityPage> {
  CollectionReference userRef;
  CrudMethods crudObj = new CrudMethods();
  UserModel userModel = new UserModel();
  Map<String, dynamic> userObj;

  @override
  void initState() {
    super.initState();
    userObj = Provider.of<UserModel>(context, listen: false).getUserData();
    userRef = crudObj.getUserActivity(userObj["userEmail"]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, widget) => Scaffold(
        appBar: GradientAppBar(content: "My Activity", appBar: new AppBar()),
        body: new StreamBuilder(
            stream: userRef.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: PrimaryTextWidget(
                    content:
                        "Something went wrong!\nSeems like we cannot fetch your activity",
                    fontSize: 14,
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: PrimaryTextWidget(
                    content: "Loading...",
                    fontSize: 14,
                  ),
                );
              }
              var docs = snapshot.data.docs;

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DisplayBox(
                          content: "Total Contests Attempted: ${docs.length}",
                          showIcon: false,
                        ),
                      ),
                      CircleAvatar(
                        backgroundImage: NetworkImage(model.userPhoto),
                      ),
                    ],
                  ),
                  new ListTile(
                      leading: HeaderTextFancyWidget(
                        content: "S.NO",
                      ),
                      trailing: new HeaderTextFancyWidget(
                        content: "Contest ID",
                      )),
                  Expanded(
                    child: Scrollbar(
                      child: ListView(
                          children: docs.asMap().entries.map((entry) {
                        var idx = entry.key;
                        var val = entry.value;
                        return new ListTile(
                            onTap: () {
                              Navigator.of(context).push(new CupertinoPageRoute(
                                builder: (context) => ActivityQuizInfoPage(
                                    marksScored: val.get('marks'),
                                    quizId: val.id),
                              ));
                            },
                            leading: PrimaryTextWidget(
                              content: "${idx + 1}",
                              fontSize: 14,
                            ),
                            trailing: new HeaderTextWidget(
                              content: val.id,
                            ));
                      }).toList()),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}
