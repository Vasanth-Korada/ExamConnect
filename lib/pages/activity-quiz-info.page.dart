import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/pages/archived-contest.page.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';

class ActivityQuizInfoPage extends StatefulWidget {
  final int marksScored;
  final String quizId;
  ActivityQuizInfoPage({@required this.marksScored, @required this.quizId});
  @override
  _ActivityQuizInfoPageState createState() => _ActivityQuizInfoPageState();
}

class _ActivityQuizInfoPageState extends State<ActivityQuizInfoPage> {
  CrudMethods crudObj = new CrudMethods();
  UserModel userModel = new UserModel();
  Map<String, dynamic> quizData = {};
  Map<String, dynamic> quizPerRef = {};

  @override
  void initState() {
    super.initState();
    DocumentReference quizDocRef = crudObj.getQuizInfo(widget.quizId);
    quizDocRef.get().then((value) => {
          setState(() {
            quizData = value.data();
          })
        });

    Map userObj = Provider.of<UserModel>(context, listen: false).getUserData();

    DocumentReference perfRef =
        crudObj.getQuizPerformance(widget.quizId, userObj["userEmail"]);

    perfRef.get().then((value) => {
          setState(() {
            quizPerRef = value.data();
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          content: quizData["exam_name"] != null
              ? quizData["exam_name"]
              : "Loading...",
          appBar: AppBar(),
        ),
        body: quizData.isNotEmpty
            ? Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  quizData["contest_img_url"] != null
                      ? new Image.network(quizData["contest_img_url"])
                      : Container(),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DisplayBox(
                          showIcon:false,
                          height: 80,
                          content:
                              "Marks Scored: ${widget.marksScored} / ${quizData["exam_marks"]}",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DisplayBox(
                          showIcon: false,
                          height: 80,
                          content: quizPerRef["submit_time"] != null
                              ? "Latest Submit Time\n ${DateTime.parse(quizPerRef["submit_time"].toDate().toString()).toString().substring(0, 16)}"
                              : "Latest Submit Time\n NA",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Align(
                      alignment: Alignment.bottomCenter,
                      child: Image(
                          image: AssetImage("assets/images/analysis.png")))
                ],
              )
            : Center(child: LinearProgressIndicator()),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: RaisedButton(
              onPressed: () {
                Navigator.of(context).push(new CupertinoPageRoute(
                    builder: (context) => ArchivedContestPage(
                      contestId: quizData["exam_id"],
                      keyUnlockCost: quizData["key_unlock_cost"] != null ? quizData["key_unlock_cost"] : "5",
                        contestName: quizData["exam_name"],
                        questions: quizData["questions"])));
              },
              child: HeaderTextWidget(
                content: "View Quiz Answers",
                color: Colors.white,
              ),
            ),
          ),
        ));
  }
}
