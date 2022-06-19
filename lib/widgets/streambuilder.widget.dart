import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exam_connect/pages/all_archived_contests.dart';
import 'package:exam_connect/pages/archived-contest.page.dart';
import 'package:exam_connect/pages/ongoing-contest.page.dart';
import 'package:exam_connect/widgets/text-widget.dart';

class MyStreamBuilderWidget extends StatefulWidget {
  final Stream stream;
  final bool isArchived;
  final Map userObj;
  Axis scrollDirection = null;
  var contestsCount = null;
  var showMore = true;

  MyStreamBuilderWidget(
      {@required this.stream,
      @required this.isArchived,
      @required this.userObj,
      this.scrollDirection,
      this.contestsCount,
      this.showMore});

  @override
  _MyStreamBuilderWidgetState createState() => _MyStreamBuilderWidgetState();
}

class _MyStreamBuilderWidgetState extends State<MyStreamBuilderWidget> {
  @override
  Widget build(BuildContext context) {
    print("Check");
    print(widget.userObj);
    return StreamBuilder(
        stream: widget.stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: new PrimaryTextWidget(content: "Loading ...."));
          }
          if (!snapshot.hasData /*|| snapshot.data.docs.isEmpty*/) {
            return Center(
              child: new PrimaryTextWidget(
                content: "No Contests",
              ),
            );
          } else {
            var length = snapshot.data.docs.length;

            try {
              return Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: widget.scrollDirection == null
                          ? Axis.horizontal
                          : widget.scrollDirection,
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, i) {
                        // if (widget.showMore && i >= 2) {
                        //   return widget.isArchived
                        //       ? Padding(
                        //           padding: const EdgeInsets.only(right: 12.0),
                        //           child: Column(
                        //             mainAxisAlignment: MainAxisAlignment.center,
                        //             crossAxisAlignment:
                        //                 CrossAxisAlignment.center,
                        //             children: [
                        //               new IconButton(
                        //                   color: Colors.green,
                        //                   icon: Icon(
                        //                     Icons.arrow_forward_ios,
                        //                     size: 36.0,
                        //                     color: Colors.green,
                        //                   ),
                        //                   onPressed: () {
                        //                     Navigator.of(context).push(
                        //                         new CupertinoPageRoute(
                        //                             builder: (context) =>
                        //                                 AllArchivedContests(
                        //                                   userObj:
                        //                                       widget.userObj,
                        //                                 )));
                        //                   }),
                        //               new PrimaryTextWidget(content: "See All")
                        //             ],
                        //           ),
                        //         )
                        //       : Container();
                        // }
                        var contestName = snapshot.data.docs[length - i - 1]
                            .data()['exam_name'];
                        var examID = snapshot.data.docs[length - i - 1]
                            .data()['exam_id'];
                        var examDuration = snapshot.data.docs[length - i - 1]
                            .data()['exam_duration'];
                        var examMarks = snapshot.data.docs[length - i - 1]
                            .data()['exam_marks'];
                        var examTotalQuestions = snapshot
                            .data.docs[length - i - 1]
                            .data()['exam_total_questions'];
                        var maxAttempts = snapshot.data.docs[length - i - 1]
                            .data()['max_attempts'];
                        var keyUnlockCost = snapshot.data.docs[length - i - 1]
                            .data()['key_unlock_cost'];
                        bool isArchived = snapshot.data.docs[length - i - 1]
                            .data()['isActive'];
                        List<dynamic> questions = snapshot
                            .data.docs[length - i - 1]
                            .data()['questions'];

                        Map<String, dynamic> displayData = {
                          "Contest ID": examID,
                          "Contest Duration": examDuration.toString() + " Mins",
                          "Total Questions": examTotalQuestions,
                          "Total Marks": examMarks,
                          "Free Attempts": maxAttempts
                        };
                        return isArchived != widget.isArchived
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: GestureDetector(
                                  onTap: () {
                                    !isArchived
                                        ? Navigator.of(context).push(
                                            new CupertinoPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    ArchivedContestPage(
                                                        contestId: examID,
                                                        keyUnlockCost:
                                                            keyUnlockCost != null
                                                                ? keyUnlockCost
                                                                : "5",
                                                        contestName:
                                                            contestName,
                                                        questions: questions)))
                                        : Navigator.of(context).push(
                                            new CupertinoPageRoute(
                                                builder: (BuildContext
                                                        context) =>
                                                    OngoingContestPage(
                                                      contestInfoObj: snapshot
                                                          .data
                                                          .docs[length - i - 1]
                                                          .data(),
                                                      contestName: contestName,
                                                      questions: questions,
                                                      duration: examDuration,
                                                      userObj: widget.userObj,
                                                    )));
                                  },
                                  child: InkWell(
                                    splashColor: Colors.white,
                                    child: new Container(
                                      width: MediaQuery.of(context).size.width -
                                          10,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(30.0)),
                                      child: new Card(
                                        shadowColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(6.0)),
                                        elevation: 4.0,
                                        child: Scrollbar(
                                          child: SingleChildScrollView(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: new Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  new SizedBox(height: 15),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: isArchived
                                                                ? Colors.green
                                                                : Color(
                                                                    0XFF732BCA),
                                                            style: BorderStyle
                                                                .solid,
                                                            width: 1.5),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.0)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child:
                                                          new HeaderTextFancyWidget(
                                                        content: contestName
                                                            .toString(),
                                                        color: isArchived
                                                            ? Colors.green
                                                            : Color(0XFF732BCA),
                                                      ),
                                                    ),
                                                  ),
                                                  new SizedBox(height: 25),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        children: displayData
                                                            .entries
                                                            .map((e) {
                                                          return Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              HeaderTextWidget(
                                                                content: e.key,
                                                              ),
                                                              HeaderTextWidget(
                                                                content: e.value
                                                                    .toString(),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container();
                      },
                    ),
                  ),
                ],
              );
            } catch (e) {
              return Center(
                child: new PrimaryTextWidget(
                  content: "No Contests",
                ),
              );
            }
          }
        });
  }
}
