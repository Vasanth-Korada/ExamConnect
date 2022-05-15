import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/ad_manager.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/pages/detailed-archived-key.page.dart';
import 'package:talent_connect/pages/mycoins.page.dart';
import 'package:talent_connect/widgets/BlurFilter.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';

class ArchivedContestPage extends StatefulWidget {
  final String contestName;
  final String contestId;
  final String keyUnlockCost;
  final List<dynamic> questions;
  ArchivedContestPage(
      {@required this.contestName,
      @required this.questions,
      this.keyUnlockCost = "5",
      @required this.contestId});
  @override
  _ArchivedContestPageState createState() => _ArchivedContestPageState();
}

class _ArchivedContestPageState extends State<ArchivedContestPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CrudMethods crudObj = new CrudMethods();
  double sigmaX = 3.0;
  double sigmaY = 3.0;
  Map<String, dynamic> userObj = {};
  bool already_unlocked = false;
  @override
  void initState() {
    super.initState();
    userObj = Provider.of<UserModel>(context, listen: false).getUserData();

    crudObj
        .checkIfKeyUnlocked(
            email: userObj["userEmail"], contestId: widget.contestId)
        .then((value) {
      setState(() {
        already_unlocked = value;
        print(value);
      });
    });
    interstitialAd
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );
  }

  @override
  void dispose() {
    super.dispose();
    interstitialAd?.dispose();
  }

  void handleUnlockKey() async {
    Navigator.of(context).pop();
    if (Provider.of<UserModel>(context,listen: false).coins >=
        int.parse(widget.keyUnlockCost)) {
      setState(() {
        sigmaX = 0.0;
        sigmaY = 0.0;
        already_unlocked = true;
        DateTime now = new DateTime.now();
        DateTime date = new DateTime(
            now.year, now.month, now.day, now.hour, now.minute, now.second);

        crudObj.modifyUserCoins(
            email: userObj["userEmail"],
            coins: -(int.parse(widget.keyUnlockCost)),
            context: context);

        crudObj.addToKeysUnlockArray(
            email: userObj["userEmail"], contestId: widget.contestId);

        crudObj.addToCoinsActivity(
            email: userObj["userEmail"],
            transacDate: date,
            transacType: "debit",
            coins: int.parse(widget.keyUnlockCost),
            reason: "Unlocked key for ${widget.contestName}");

        userObj["coins"] = Provider.of<UserModel>(context).coins;

        final snackBar = SnackBar(
            content: PrimaryTextWidget(
          content: 'Yay, You key is unlocked!',
          fontSize: 14,
        ));
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    } else {
      setState(() {
        final snackBar = SnackBar(
          content: PrimaryTextWidget(
            content: 'Not enough coins!',
            fontSize: 14,
          ),
          action: SnackBarAction(
            textColor: Colors.orange,
            label: "WATCH AN AD",
            onPressed: () {
              Navigator.of(context).push(
                  new CupertinoPageRoute(builder: (context) => MyCoinsPage()));
            },
          ),
        );
        _scaffoldKey.currentState.showSnackBar(snackBar);
      });
    }
  }

  showPurchaseAttemptDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: HeaderTextFancyWidget(
              content: "Unlock Key",
            ),
            titlePadding: EdgeInsets.all(18.0),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/awesome.png",
                  height: 150,
                ),
                SizedBox(height: 10),
                DisplayBox(
                  height: 50,
                  showIcon: false,
                  content: "Unlock Cost: " +
                      "${int.parse(widget.keyUnlockCost)}" +
                      " Coins",
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PrimaryTextWidget(
                    content: "Available Coins: " +
                        Provider.of<UserModel>(context, listen: true)
                            .coins
                            .toString(),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            contentPadding: EdgeInsets.all(12),
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                  style: ButtonStyle(),
                  onPressed: () => Navigator.of(context).pop(),
                  child: PrimaryTextWidget(
                    content: "Cancel",
                    fontSize: 14,
                  )),
              MaterialButton(
                  splashColor: Colors.purple[200],
                  color: Color(0xFF733ECA),
                  onPressed: () => handleUnlockKey(),
                  shape: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8)),
                  child: PrimaryTextWidget(
                    content: "Unlock Key",
                    fontSize: 14,
                  )),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: GradientAppBar(content: "Archived Contest", appBar: AppBar()),
      body: Scrollbar(
        child: new ListView(
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new HeaderTextFancyWidget(
                    content: widget.contestName,
                    textAlign: TextAlign.center,
                    fontSize: 24,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new HeaderTextWidget(content: "KEY"),
                ),
                already_unlocked
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: RaisedButton(
                            splashColor: Colors.greenAccent,
                            color: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              showPurchaseAttemptDialog(context);
                            },
                            child: PrimaryTextWidget(
                              content:
                                  "Unlock Key for ${int.parse(widget.keyUnlockCost)} Coins",
                              color: Colors.white,
                            )),
                      ),
                BlurFilter(
                  sigmaX: already_unlocked ? 0.0 : sigmaX,
                  sigmaY: already_unlocked ? 0.0 : sigmaY,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3.0),
                          border:
                              Border.all(width: 0.0, color: Color(0xFF023436))),
                      child: new DataTable(
                          horizontalMargin: 8,
                          dataRowHeight: 100.0,
                          columnSpacing: MediaQuery.of(context).size.width / 9,
                          columns: [
                            new DataColumn(
                                label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: HeaderTextWidget(
                                content: "Question",
                                color: Colors.black,
                              ),
                            )),
                            new DataColumn(
                                label: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: HeaderTextWidget(
                                content: "Answer",
                                color: Colors.black,
                              ),
                            )),
                          ],
                          rows: [
                            for (int i = 0; i < widget.questions.length; i++)
                              DataRow(cells: [
                                DataCell(GestureDetector(
                                  onTap: already_unlocked ? () {
                                    Navigator.of(context).push(
                                        new CupertinoPageRoute(
                                            builder: (context) =>
                                                DetailedArchivedKeyPage(
                                                  question: widget.questions[i]
                                                      ["question"],
                                                  answer: widget.questions[i]
                                                      ["correct_answer"],
                                                  options: widget.questions[i]
                                                      ["options"],
                                                  explanation:
                                                      widget.questions[i]
                                                          ["explanation"],
                                                )));
                                  } : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: PrimaryTextWidget(
                                        content: widget.questions[i]
                                            ["question"],
                                        fontSize: 12.0),
                                  ),
                                )),
                                DataCell(GestureDetector(
                                  onTap: already_unlocked ? () {
                                    Navigator.of(context).push(
                                        new CupertinoPageRoute(
                                            builder: (context) =>
                                                DetailedArchivedKeyPage(
                                                  question: widget.questions[i]
                                                      ["question"],
                                                  answer: widget.questions[i]
                                                      ["correct_answer"],
                                                  options: widget.questions[i]
                                                      ["options"],
                                                  explanation:
                                                      widget.questions[i]
                                                          ["explanation"],
                                                )));
                                  } : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 130,
                                      child: PrimaryTextWidget(
                                        content: widget.questions[i]
                                                ["correct_answer"]
                                            .toString(),
                                        fontSize: 12.0,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ),
                                ))
                              ])
                          ]),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
