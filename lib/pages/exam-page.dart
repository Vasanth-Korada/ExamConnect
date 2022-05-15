import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:talent_connect/helpers/check-internet-connection.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/helpers/loader.dart';
import 'package:talent_connect/pages/result-page.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';
import 'package:talent_connect/widgets/exam-page-buttonbar.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';
import 'dart:async';
import 'package:flutter/services.dart';

Map<int, dynamic> userAnswers = {};
Map<int, int> allocatedMarks = {};
Map<int, dynamic> radioValues = {};
Map<int, dynamic> globalCheckBoxValues = {};

var globalContestInfoObj = {};
int globalScore = 0;

void _handleRadioValueChange(
    {int qnumber, dynamic radioValue, String question, String userAnswer}) {
  userAnswers[qnumber] = userAnswer;
  radioValues[qnumber] = radioValue;
  print(userAnswers);
}

class ExamPage extends StatefulWidget {
  final List questions;
  final int duration;
  final Map contestInfoObj;
  final Map userObj;
  final Map orgObj;
  final bool forOrg;

  ExamPage({
    @required this.questions,
    @required this.duration,
    @required this.contestInfoObj,
    @required this.userObj,
    @required this.orgObj,
    @required this.forOrg,
  });

  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> with WidgetsBindingObserver {
  Map<dynamic, dynamic> correctAnswers = {};
  int score = 0;
  bool _loading;
  bool _tapped;
  CrudMethods crudObj = new CrudMethods();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int _currentQuestionIndex = 0;
  final ItemScrollController itemScrollController = ItemScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loading = false;
    _tapped = false;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    checkInternetConnectivity(context).then((val) {
      val == true
          ? ShowDialog(context: context, content: "No Internet Connection!")
          : print("Connected");
    });
    getCorrectAnswers();
    startTimer();
    print("Correct Answers:" + correctAnswers.toString());
    print("Contest Info Object" + widget.contestInfoObj.toString());
    for (int i = 0; i < widget.contestInfoObj["questions"].length; i++) {
      if (widget.contestInfoObj["questions"][i]["type"] == "Multiple") {
        print("bye");
        print(widget.contestInfoObj["questions"][i]["type"]);
        print(widget.contestInfoObj["questions"][i]["options"]);
        int optnsLength =
            widget.contestInfoObj["questions"][i]["options"].length;
        print("OptnLength" + optnsLength.toString());
        for (int j = 0; j < optnsLength; j++) {
          if (globalCheckBoxValues[i] != null) {
            globalCheckBoxValues[i] = {
              ...globalCheckBoxValues[i],
              widget.contestInfoObj["questions"][i]["options"][j]: false,
            };
          } else {
            globalCheckBoxValues[i] = {
              widget.contestInfoObj["questions"][i]["options"][j]: false,
            };
          }
        }
      }
    }
    print("Exam Page Global Checkbox");
    print(globalCheckBoxValues);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      calculateScore();
    }
  }

  @override
  void dispose() {
    super.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _timer.cancel();
    correctAnswers = {};
    userAnswers = {};
    radioValues = {};
    globalCheckBoxValues = {};
    score = 0;
    WidgetsBinding.instance.removeObserver(this);
  }

  Timer _timer;
  int _currentTimeMins;

  void startTimer() {
    _currentTimeMins = widget.duration;
    _timer = Timer.periodic(Duration(minutes: 1), (Timer t) {
      setState(() {
        if (_currentTimeMins == 1) {
          debugPrint("Timer Done");
          _timer.cancel();
          setState(() {
            _loading = true;
          });
          calculateScore();
        }
        _currentTimeMins--;
      });
    });
  }

  void getCorrectAnswers() async {
    await widget.questions.forEach((questionObj) {
      correctAnswers[widget.questions.indexOf(questionObj)] =
          questionObj["correct_answer"];
    });
    debugPrint("CORRECT ANSWERS");
  }

  bool areListsEqual(var list1, var list2) {
    // check if both are lists
    if (!(list1 is List && list2 is List)
        // check if both have same length
        ||
        list1.length != list2.length) {
      return false;
    }

    // check if elements are equal
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) {
        return false;
      }
    }

    return true;
  }

  void calculateScore() {
    try {
      print("Hello USER ANSWERS");
      print(userAnswers);
      print(userAnswers);
      userAnswers.forEach((key, value) {
        debugPrint("USER ANSWERS");
        print(key.toString() + ": " + value.toString());
        debugPrint("CORRECT ANS VALUES VS USER ANS VALUES");
        debugPrint(correctAnswers[key].toString() + " " + value.toString());
        if (value is Map && value.keys.length >= 1) {
          var options_list = [];
          value.keys.forEach((option) {
            if (value[option] == true) {
              options_list.add(option);
            }
          });
          if (areListsEqual(correctAnswers[key], options_list)) {
            score = score + (allocatedMarks[key]);
          }
        } else if (correctAnswers[key].toString().toLowerCase() ==
            value.toString().toLowerCase()) {
          print(allocatedMarks[key]);
          score = score + allocatedMarks[key];
        }
      });
    } catch (e) {
      print(e);
    }
    handleSubmit(context);
  }

  showConfirmSubmitDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: HeaderTextFancyWidget(
              content: "Confirm Submission",
            ),
            titlePadding: EdgeInsets.all(18.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DisplayBox(
                  height: 50,
                  showIcon: false,
                  content: "Total Questions: ${widget.questions.length}",
                ),
                SizedBox(height: 10),
                DisplayBox(
                  height: 50,
                  showIcon: false,
                  content: "Questions Attempted: ${userAnswers.length}",
                ),
                SizedBox(height: 10),
              ],
            ),
            contentPadding: EdgeInsets.all(12),
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                  style: ButtonStyle(),
                  onPressed: () => Navigator.of(context).pop(),
                  child: PrimaryTextWidget(
                    content: "No, Take me back",
                    fontSize: 14,
                  )),
              MaterialButton(
                  splashColor: Colors.purple[200],
                  color: Color(0xFF733ECA),
                  onPressed: _tapped
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          setState(() {
                            _loading = true;
                            _tapped = true;
                          });
                          calculateScore();
                          debugPrint("USER SCORE: ${score}");
                        },
                  shape: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8)),
                  child: PrimaryTextWidget(
                    content: "Submit",
                    fontSize: 14,
                  )),
            ],
          );
        });
  }

  void handleSubmit(BuildContext newContext) async {
    globalContestInfoObj = widget.contestInfoObj;
    globalScore = score;
    await crudObj
        .userSubmittedContest(
      score,
      widget.userObj,
      widget.contestInfoObj["exam_id"],
      widget.forOrg ? widget.orgObj : null,
      userAnswers,
      widget.contestInfoObj["storeUserRes"] == null
          ? false
          : widget.contestInfoObj["storeUserRes"],
    )
        .then((_) {
      setState(() {
        _loading = false;
        ;
      });

      Navigator.of(newContext).pop();
      print(userAnswers.toString());
      Navigator.of(newContext).pushReplacement(new CupertinoPageRoute(
          builder: (BuildContext newContext) => ResultSplash()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            elevation: 30.0,
            title: HeaderTextFancyWidget(
              content: 'Warning',
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset("assets/images/clip-log-out.png"),
                PrimaryTextWidget(
                  content: "Do you really want to exit? \n\n"
                      "1. On Tapping 'Exit' contest will be terminated and you won't be able to retake again.\n"
                      "\n2. It is recommended to click on submit before you exit.",
                  fontSize: 14.0,
                ),
              ],
            ),
            actions: [
              TextButton(
                child: Text('Exit'),
                onPressed: () => Navigator.pop(c, true),
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF7A17CE))),
                child: Text('Take me Back'),
                onPressed: () => Navigator.pop(c, false),
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        appBar: new GradientAppBar(
          appBar: AppBar(),
          content: widget.contestInfoObj["exam_name"],
          showExamPageActions: true,
          onExamPageSubmitClicked: (BuildContext context) {
            showConfirmSubmitDialog(context);
          },
        ),
        body: ModalProgressHUD(
          inAsyncCall: _loading,
          progressIndicator: MyCustomLoader(),
          child: Column(
            children: <Widget>[
              Container(
                color: Colors.indigo[200],
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 12,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new HeaderTextWidget(
                        color: Colors.black,
                        content: "Ends in:",
                      ),
                      new HeaderTextWidget(
                        color: Colors.black,
                        content: "${_currentTimeMins} Mins",
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: ScrollablePositionedList.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: widget.questions.length,
                    itemScrollController: itemScrollController,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: MaterialButton(
                          color: Colors.indigo[200],
                          shape: CircleBorder(),
                          onPressed: () {
                            // int index = widget.questions.indexOf(question);
                            setState(() {
                              _currentQuestionIndex = index;
                            });
                          },
                          child: PrimaryTextWidget(
                            content: (index + 1).toString(),
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      );
                    }),
              ),
              Divider(),
              Expanded(
                flex: 9,
                child: Scrollbar(
                  child: ListView(
                    children: [
                      Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            widget.questions[_currentQuestionIndex]["type"] ==
                                    "Single"
                                ? SingleTypeQuestion(
                                    obj:
                                        widget.questions[_currentQuestionIndex],
                                    qnumber: _currentQuestionIndex,
                                    totalQuestions: int.parse(widget.contestInfoObj[
                                        "exam_total_questions"]),
                                    onNextClicked: () {
                                      setState(() {
                                        _currentQuestionIndex++;
                                      });
                                      itemScrollController.scrollTo(
                                          index: _currentQuestionIndex,
                                          duration: Duration(seconds: 1),
                                          curve: Curves.easeIn);
                                    },
                                    onPrevClicked: () {
                                      setState(() {
                                        _currentQuestionIndex--;
                                      });
                                      itemScrollController.scrollTo(
                                          index: _currentQuestionIndex,
                                          duration: Duration(seconds: 1),
                                          curve: Curves.easeIn);
                                    },
                                    onSubmitClicked: (BuildContext context) {
                                      setState(() {
                                        showConfirmSubmitDialog(context);
                                      });
                                    })
                                : widget.questions[_currentQuestionIndex]
                                            ["type"] ==
                                        "Multiple"
                                    ? MultipleTypeQuestion(
                                        obj: widget
                                            .questions[_currentQuestionIndex],
                                        qnumber: _currentQuestionIndex,
                                        totalQuestions: int.parse(
                                            widget.contestInfoObj[
                                                "exam_total_questions"]),
                                        onNextClicked: () {
                                          setState(() {
                                            _currentQuestionIndex++;
                                          });
                                          itemScrollController.scrollTo(
                                              index: _currentQuestionIndex,
                                              duration: Duration(seconds: 1),
                                              curve: Curves.easeIn);
                                        },
                                        onPrevClicked: () {
                                          setState(() {
                                            _currentQuestionIndex--;
                                          });
                                          itemScrollController.scrollTo(
                                              index: _currentQuestionIndex,
                                              duration: Duration(seconds: 1),
                                              curve: Curves.easeIn);
                                        },
                                        onSubmitClicked:
                                            (BuildContext context) {
                                          setState(() {
                                            showConfirmSubmitDialog(context);
                                          });
                                        })
                                    : widget.questions[_currentQuestionIndex]
                                                ["type"] ==
                                            "Descriptive"
                                        ? DescriptiveTypeQuestion(
                                            obj: widget.questions[
                                                _currentQuestionIndex],
                                            qnumber: _currentQuestionIndex,
                                            totalQuestions: int.parse(
                                                widget.contestInfoObj[
                                                    "exam_total_questions"]),
                                            onNextClicked: () {
                                              setState(() {
                                                _currentQuestionIndex++;
                                              });
                                              itemScrollController.scrollTo(
                                                  index: _currentQuestionIndex,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  curve: Curves.easeIn);
                                            },
                                            onPrevClicked: () {
                                              setState(() {
                                                _currentQuestionIndex--;
                                              });
                                            },
                                            onSubmitClicked: (BuildContext context) {
                                              setState(() {
                                                showConfirmSubmitDialog(
                                                    context);
                                              });
                                            })
                                        : SingleTypeQuestion(
                                            obj: widget.questions[_currentQuestionIndex],
                                            qnumber: _currentQuestionIndex,
                                            totalQuestions: int.parse(widget.contestInfoObj["exam_total_questions"]),
                                            onNextClicked: () {
                                              setState(() {
                                                _currentQuestionIndex++;
                                              });
                                              itemScrollController.scrollTo(
                                                  index: _currentQuestionIndex,
                                                  duration:
                                                      Duration(seconds: 1),
                                                  curve: Curves.easeIn);
                                            },
                                            onPrevClicked: () {
                                              setState(() {
                                                _currentQuestionIndex--;
                                              });
                                            },
                                            onSubmitClicked: (BuildContext context) {
                                              setState(() {
                                                showConfirmSubmitDialog(
                                                    context);
                                              });
                                            }),
                          ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SingleTypeQuestion extends StatefulWidget {
  final dynamic obj;
  final int qnumber;
  final Function onNextClicked;
  final Function onPrevClicked;
  final Function onSubmitClicked;
  final int totalQuestions;

  SingleTypeQuestion({
    @required this.obj,
    @required this.qnumber,
    @required this.onNextClicked,
    @required this.onPrevClicked,
    @required this.totalQuestions,
    @required this.onSubmitClicked,
  });

  @override
  _SingleTypeQuestionState createState() => _SingleTypeQuestionState();
}

class _SingleTypeQuestionState extends State<SingleTypeQuestion> {
  int _radioValue = null;

  @override
  Widget build(BuildContext context) {
    setState(() {});
    allocatedMarks[widget.qnumber] =
        int.parse(widget.obj["allocated_marks"], onError: (source) => -1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.indigo[200],
                  child: new HeaderTextWidget(
                    color: Colors.white,
                    content: (widget.qnumber + 1).toString(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: new HeaderTextWidget(
                    content: widget.obj["question"],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.green[400],
                  child: new HeaderTextWidget(
                    color: Colors.white,
                    content: "${widget.obj["allocated_marks"]}M",
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          for (int i = 0; i < widget.obj["options"].length; i++)
            widget.obj["options"][i] != ""
                ? new RadioListTile(
                    title: Text("${widget.obj["options"][i]}"),
                    value: i,
                    groupValue: radioValues[widget.qnumber] ?? null,
                    onChanged: (dynamic value) {
                      print("On Change Value" + value.toString());
                      setState(() {
                        _radioValue = value;
                      });
                      _handleRadioValueChange(
                          qnumber: widget.qnumber,
                          radioValue: value,
                          question: widget.obj["question"],
                          userAnswer: widget.obj["options"][i]);
                    })
                : Container(),
          ExamPageButtonBar(
              qnumber: widget.qnumber,
              totalQuestions: widget.totalQuestions,
              onPrevClicked: () {
                widget.onPrevClicked();
              },
              onSubmitClicked: (BuildContext context) {
                widget.onSubmitClicked(context);
              },
              onNextClicked: () {
                widget.onNextClicked();
              })
        ],
      ),
    );
  }
}

class MultipleTypeQuestion extends StatefulWidget {
  final dynamic obj;
  final int qnumber;
  final Function onNextClicked;
  final Function onPrevClicked;
  final Function onSubmitClicked;
  final int totalQuestions;

  const MultipleTypeQuestion(
      {Key key,
      this.obj,
      this.qnumber,
      this.onNextClicked,
      this.onPrevClicked,
      this.onSubmitClicked,
      this.totalQuestions})
      : super(key: key);

  @override
  _MultipleTypeQuestionState createState() => _MultipleTypeQuestionState();
}

class _MultipleTypeQuestionState extends State<MultipleTypeQuestion> {
  Map<dynamic, bool> optMap = {};

  @override
  Widget build(BuildContext context) {
    allocatedMarks[widget.qnumber] =
        int.parse(widget.obj["allocated_marks"], onError: (source) => -1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.indigo[200],
                  child: new HeaderTextWidget(
                    color: Colors.white,
                    content: (widget.qnumber + 1).toString(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: new HeaderTextWidget(
                    content: widget.obj["question"],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: CircleAvatar(
                  radius: 12.0,
                  backgroundColor: Colors.green[400],
                  child: new HeaderTextWidget(
                    color: Colors.white,
                    content: "${widget.obj["allocated_marks"]}M",
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          for (int i = 0; i < widget.obj["options"].length; i++)
            widget.obj["options"][i] != ""
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        new Checkbox(
                          value: globalCheckBoxValues[widget.qnumber]
                                      [widget.obj["options"][i]] ==
                                  null
                              ? false
                              : globalCheckBoxValues[widget.qnumber]
                                  [widget.obj["options"][i]],
                          onChanged: (bool val) {
                            setState(() {
                              optMap[widget.obj["options"][i]] = val;
                              // List multipleAnswers = [];

                              // optMap.keys.forEach((key) {
                              //   if (optMap[key] == true) {
                              //     multipleAnswers.add(key);
                              //   }
                              // });

                              // print(multipleAnswers);
                              globalCheckBoxValues[widget.qnumber]
                                  [widget.obj["options"][i]] = val;
                              userAnswers[widget.qnumber] =
                                  globalCheckBoxValues[widget.qnumber];
                              print("Test Here");
                              print(globalCheckBoxValues[widget.qnumber]);
                            });
                          },
                        ),
                        Text(widget.obj["options"][i])
                      ],
                    ),
                  )
                : Container(),
          ExamPageButtonBar(
              qnumber: widget.qnumber,
              totalQuestions: widget.totalQuestions,
              onPrevClicked: () {
                widget.onPrevClicked();
              },
              onSubmitClicked: (BuildContext context) {
                widget.onSubmitClicked(context);
              },
              onNextClicked: () {
                widget.onNextClicked();
              })
        ],
      ),
    );
  }
}

class DescriptiveTypeQuestion extends StatefulWidget {
  final dynamic obj;
  final int qnumber;
  final Function onNextClicked;
  final Function onPrevClicked;
  final Function onSubmitClicked;
  final int totalQuestions;

  const DescriptiveTypeQuestion(
      {Key key,
      this.obj,
      this.qnumber,
      this.onNextClicked,
      this.onPrevClicked,
      this.onSubmitClicked,
      this.totalQuestions})
      : super(key: key);

  @override
  _DescriptiveTypeQuestionState createState() =>
      _DescriptiveTypeQuestionState();
}

class _DescriptiveTypeQuestionState extends State<DescriptiveTypeQuestion> {
  TextEditingController _descriptiveTextController =
      new TextEditingController();

  @override
  void initState() {
    super.initState();
    allocatedMarks[widget.qnumber] =
        int.parse(widget.obj["allocated_marks"], onError: (source) => -1);
  }

  @override
  Widget build(BuildContext context) {
    _descriptiveTextController.text = userAnswers[widget.qnumber];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.indigo[200],
                  child: new HeaderTextWidget(
                    color: Colors.white,
                    content: (widget.qnumber + 1).toString(),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: new HeaderTextWidget(
                    content: widget.obj["question"].toString(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: CircleAvatar(
                  radius: 12.0,
                  backgroundColor: Colors.green[400],
                  child: new HeaderTextWidget(
                    color: Colors.white,
                    content: "${widget.obj["allocated_marks"]}M",
                    fontSize: 12,
                  ),
                ),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Scrollbar(
              child: TextField(
                controller: _descriptiveTextController,
                maxLength: int.parse(widget.obj["max_words"]),
                onChanged: (String text) {
                  userAnswers[widget.qnumber] = text;
                },
              ),
            ),
          ),
          ExamPageButtonBar(
              qnumber: widget.qnumber,
              totalQuestions: widget.totalQuestions,
              onPrevClicked: () {
                widget.onPrevClicked();
              },
              onSubmitClicked: (BuildContext context) {
                widget.onSubmitClicked(context);
              },
              onNextClicked: () {
                widget.onNextClicked();
              })
        ],
      ),
    );
  }
}

class ResultSplash extends StatefulWidget {
  @override
  _ResultSplashState createState() => _ResultSplashState();
}

class _ResultSplashState extends State<ResultSplash> {
  @override
  Widget build(BuildContext context) {
    Timer(
        Duration(milliseconds: 3000),
        () => Navigator.of(context).pushReplacement(new CupertinoPageRoute(
            builder: (BuildContext context) => ResultPage(
                  contestInfoObj: globalContestInfoObj,
                  score: globalScore,
                ))));

    var assetsImage = new AssetImage('assets/tc_new_gif.gif');
    var image = new Image(
      image: assetsImage,
    );

    return Scaffold(
      backgroundColor: Color(0XFFf9fafd),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PrimaryTextWidget(
              content: "Calculating your score -- hold your breath!"),
          Container(
            child: new Center(
              child: image,
            ),
          ),
        ],
      ),
    );
  }
}
