import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/check-internet-connection.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/pages/exam-page.dart';
import 'package:talent_connect/helpers/loader.dart';
import 'package:talent_connect/pages/mycoins.page.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';
import 'package:talent_connect/widgets/share.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'dart:math';
import '../helpers/ad_manager.dart';
import '../helpers/quotes.dart';

class OngoingContestPage extends StatefulWidget {
  final String contestName;
  final List questions;
  final int duration;
  final Map contestInfoObj;
  final Map userObj;

  OngoingContestPage(
      {@required this.contestName,
      @required this.questions,
      @required this.duration,
      @required this.contestInfoObj,
      @required this.userObj});

  @override
  _OngoingContestPageState createState() => _OngoingContestPageState();
}

class _OngoingContestPageState extends State<OngoingContestPage> {
  bool _loading = false;
  int randomImageNumber;
  CrudMethods crudObj = new CrudMethods();
  bool userIsAttempted = true;
  int remainingAttempts;
  String zerothImage = "";
  String onethImage = "";
  String secondImage = "";
  int userCoins;
  bool isReadInstructions = false;
  final _random = new Random();

  int next(int min, int max) => min + _random.nextInt(max - min);
  final TextEditingController _pinController = new TextEditingController();
  final TextEditingController _regdNoController = new TextEditingController();
  final TextEditingController _branchController = new TextEditingController();
  final TextEditingController _secController = new TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _orgFormKey = new GlobalKey<FormState>();
  Quotes quotesObj = new Quotes();
  final _randomQuote = new Random();

  @override
  void dispose() {
    super.dispose();
    interstitialAd?.dispose();
    _pinController.clear();
    _pinController.dispose();
  }

  @override
  void initState() {
    super.initState();
    widget.contestInfoObj["for_org"] = widget.contestInfoObj["for_org"] == null
        ? false
        : widget.contestInfoObj["for_org"];
    fetchImages();
    try {
      interstitialAd
        ..load()
        ..show(
          anchorType: AnchorType.bottom,
          anchorOffset: 0.0,
          horizontalCenterOffset: 0.0,
        );
    } on Exception {
      debugPrint("Failed to Load Ad");
    } catch (e) {
      debugPrint(e);
    }

    checkInternetConnectivity(context).then((val) {
      val == true
          ? ShowDialog(context: context, content: "No Internet Connection!")
          : print("Connected");
    });
    setState(() {
      _loading = true;
    });
    randomImageNumber = next(0, 3);
    checkUserAttempStatus();
    setState(() {
      _loading = false;
    });
  }

  fetchImages() async {
    await crudObj.fetchAssets().then((doc) {
      setState(() {
        zerothImage = doc.data()["dev_images"][0];
        onethImage = doc.data()["dev_images"][2];
        secondImage = doc.data()["dev_images"][4];
      });
    });
  }

  askExtraAttemptDialog(
      {@required BuildContext context, @required String content}) async {
    return showGeneralDialog(
      barrierLabel: "Extra Attempt",
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      transitionDuration: Duration(milliseconds: 700),
      context: context,
      pageBuilder: (context, anim1, anim2) {
        return SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Container(
                height: 100,
                child: SizedBox.expand(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Material(
                      child: new HeaderTextFancyWidget(
                        content: "No attempts available! Want another?",
                      ),
                    ),
                    SizedBox(height: 3),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        FlatButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              showPurchaseAttemptDialog(context);
                            },
                            child: Text("YES")),
                        FlatButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text("NO"))
                      ],
                    )
                  ],
                )),
                margin: EdgeInsets.only(bottom: 50, left: 12, right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return SlideTransition(
          position:
              Tween(begin: Offset(1, 0), end: Offset(0, 0)).animate(anim1),
          child: child,
        );
      },
    );
  }

  showPurchaseAttemptDialog(BuildContext context) {
    userCoins = Provider.of<UserModel>(context, listen: false).coins;
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: HeaderTextFancyWidget(
              content: "Purchase Attempt",
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
                  content: "Attempt Cost: " +
                      widget.contestInfoObj["coins_per_attempt"].toString() +
                      " Coins",
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: PrimaryTextWidget(
                    content: "Available Coins: " +
                        Provider.of<UserModel>(context, listen: false)
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
                  onPressed: () => handlePurchaseAttempt(),
                  shape: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8)),
                  child: PrimaryTextWidget(
                    content: "Purchase Attempt",
                    fontSize: 14,
                  )),
            ],
          );
        });
  }

  void handlePurchaseAttempt() async {
    userCoins = Provider.of<UserModel>(context, listen: false).coins;
    Navigator.of(context).pop();
    if (userCoins >= widget.contestInfoObj["coins_per_attempt"]) {
      await crudObj.purchaseAttempt(
          contestId: widget.contestInfoObj["exam_id"],
          email: widget.userObj["email"],
          debitCoins: widget.contestInfoObj["coins_per_attempt"]);
      setState(() {
        checkUserAttempStatus();
        DocumentReference ref = crudObj.getUserInfo(widget.userObj["email"]);
        ref.get().then((doc) => Provider.of<UserModel>(context, listen: false)
            .coins = doc.get('coins'));

        DateTime now = new DateTime.now();
        DateTime date = new DateTime(
            now.year, now.month, now.day, now.hour, now.minute, now.second);
        crudObj.addToCoinsActivity(
            email: widget.userObj["email"],
            transacDate: date,
            transacType: "debit",
            coins: widget.contestInfoObj["coins_per_attempt"],
            reason:
                "Purchased an Attempt for ${widget.contestInfoObj["exam_id"]} Contest");

        final snackBar = SnackBar(
            content: PrimaryTextWidget(
          content: 'Yay, You purchased an attempt!',
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

  void checkUserAttempStatus() async {
    await crudObj
        .checkAvailableAttempts(widget.contestInfoObj, widget.userObj["email"])
        .then((int value) {
      setState(() {
        remainingAttempts = value;
        if (remainingAttempts <= 0) {
          userIsAttempted = true;
          widget.contestInfoObj["is_purchase_attempt"] == null ||
                  widget.contestInfoObj["is_purchase_attempt"] == true
              ? askExtraAttemptDialog(
                  context: context,
                  content: "No attempts available! Want another?")
              : null;
        } else {
          userIsAttempted = false;
        }
      });
    });
    print(userIsAttempted.toString());
  }

  showContestPINDialog(BuildContext context) {
    Navigator.of(context).pop();
    setState(() {
      _loading = false;
    });
    var contestPIN = widget.contestInfoObj["contest_pin"];

    return showDialog(
      context: _scaffoldKey.currentContext,
      builder: (dialogContext) {
        return SimpleDialog(
          title: HeaderTextFancyWidget(
            content: "Almost there!",
          ),
          children: [
            widget.contestInfoObj["for_org"]
                ? Form(
                    key: _orgFormKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: new TextFormField(
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.characters,
                            controller: _regdNoController,
                            textInputAction: TextInputAction.done,
                            decoration: new InputDecoration(
                                hintText: "17KD1A0572",
                                labelText: "Enter Regd No:",
                                border: new OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.greenAccent,
                                        width: 1.5,
                                        style: BorderStyle.solid))),
                            validator: (String val) {
                              if (val.isEmpty || val.length == 0)
                                return "Regd No cannot be empty!";
                              else
                                return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: new TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _branchController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            decoration: new InputDecoration(
                                labelText: "Enter Branch:",
                                hintText: "E.G: CSE",
                                border: new OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.greenAccent,
                                        width: 1.5,
                                        style: BorderStyle.solid))),
                            validator: (String val) {
                              if (val.isEmpty || val.length == 0)
                                return "Branch cannot be empty!";
                              else
                                return null;
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: new TextFormField(
                            keyboardType: TextInputType.text,
                            controller: _secController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            decoration: new InputDecoration(
                                hintText: "E.G: B",
                                labelText: "Enter Section:",
                                border: new OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.greenAccent,
                                        width: 1.5,
                                        style: BorderStyle.solid))),
                            validator: (String val) {
                              if (val.isEmpty || val.length == 0)
                                return "Section cannot be empty!";
                              else
                                return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: new TextFormField(
                keyboardType: TextInputType.number,
                maxLength: 4,
                controller: _pinController,
                textInputAction: TextInputAction.done,
                decoration: new InputDecoration(
                    labelText: "Enter Contest PIN:",
                    border: new OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors.greenAccent,
                            width: 1.5,
                            style: BorderStyle.solid))),
                validator: (String val) {
                  if (val.isEmpty || val.length == 0)
                    return "Contest PIN cannot be empty!";
                  if (val.length != 4)
                    return "Four Digits Required!";
                  else
                    return null;
                },
              ),
            ),
            FlatButton(
              onPressed: () {
                bool formValidation = widget.contestInfoObj["for_org"]
                    ? _orgFormKey.currentState.validate()
                    : true;
                if (_pinController.text == contestPIN && formValidation) {
                  Navigator.of(dialogContext).pop();

                  setState(() {
                    _loading = true;
                  });

                  afterPINVerification();
                } else {
                  _pinController.clear();
                  _regdNoController.clear();
                  _branchController.clear();
                  _secController.clear();
                  Navigator.of(dialogContext).pop();
                  _scaffoldKey.currentState.showSnackBar(SnackBar(
                      content: PrimaryTextWidget(
                    content: "Invalid Details",
                    fontSize: 12,
                  )));
                }
              },
              child: HeaderTextFancyWidget(
                content: "ENTER",
              ),
            )
          ],
        );
      },
    );
  }

  void afterPINVerification() {
    Map orgObj = {
      "regdNo": _regdNoController.text.toUpperCase(),
      "branch": _branchController.text.toUpperCase(),
      "section": _secController.text.toUpperCase()
    };
    crudObj
        .userAttemptedContest(widget.userObj, widget.contestInfoObj,
            widget.contestInfoObj["for_org"] ? orgObj : null)
        .then((_) {
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _loading = false;
        });
        Navigator.of(context).pushReplacement(new CupertinoPageRoute(
          builder: (context) => ExamPage(
              questions: widget.questions,
              duration: widget.duration,
              contestInfoObj: widget.contestInfoObj,
              userObj: widget.userObj,
              forOrg: widget.contestInfoObj["for_org"],
              orgObj: orgObj),
        ));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    userCoins = Provider.of<UserModel>(context, listen: false).coins;
    print(widget.contestInfoObj["for_org"].toString());
    return Consumer<UserModel>(
      builder: (context, model, child) => Scaffold(
        // resizeToAvoidBottomPadding: true,
        resizeToAvoidBottomInset: true,
        key: _scaffoldKey,
        body: ModalProgressHUD(
            inAsyncCall: _loading,
            progressIndicator: MyCustomLoader(),
            child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: 220.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: HeaderTextWidget(
                          content: "Ongoing",
                          color: Colors.white,
                        ),
                        background: SafeArea(
                          child: Image.network(
                            widget.contestInfoObj["contest_img_url"],
                            fit: BoxFit.cover,
                          ),
                        )),
                    actions: [
                      PopupMenuButton<String>(
                        enabled:
                            widget.contestInfoObj["is_purchase_attempt"] == null
                                ? true
                                : widget.contestInfoObj["is_purchase_attempt"],
                        onSelected: (val) => showPurchaseAttemptDialog(context),
                        itemBuilder: (BuildContext context) {
                          return {'Purchase an Attempt'}.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: PrimaryTextWidget(
                                  content: choice, fontSize: 14),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                ];
              },
              body: Scrollbar(
                child: new ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: new HeaderTextFancyWidget(
                            textAlign: TextAlign.center,
                            content: widget.contestName,
                            fontSize: 20,
                          ),
                        ),
                        widget.contestInfoObj["for_org"]
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        size: 19,
                                      ),
                                      PrimaryTextWidget(
                                        content:
                                            "  This is an organizational quiz",
                                        fontSize: 12,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Container(),
                        ExpansionTile(
                          initiallyExpanded: true,
                          title: PrimaryTextWidget(content: "Contest Info"),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(
                                        width: 0.0, color: Color(0xFF023436))),
                                child: new DataTable(
                                    columnSpacing:
                                        MediaQuery.of(context).size.width / 2.7,
                                    columns: [
                                      DataColumn(
                                          label: HeaderTextWidget(
                                        content: "Name",
                                        color: Colors.black,
                                      )),
                                      DataColumn(
                                          label: HeaderTextWidget(
                                        content: "Info",
                                        color: Colors.black,
                                      ))
                                    ],
                                    rows: [
                                      DataRow(cells: [
                                        DataCell(PrimaryTextWidget(
                                          content: "Contest ID",
                                        )),
                                        DataCell(PrimaryTextWidget(
                                          content: widget
                                              .contestInfoObj["exam_id"]
                                              .toString(),
                                        )),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(PrimaryTextWidget(
                                          content: "Total Questions",
                                        )),
                                        DataCell(PrimaryTextWidget(
                                          content: widget.contestInfoObj[
                                                  "exam_total_questions"]
                                              .toString(),
                                        )),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(PrimaryTextWidget(
                                          content: "Total Marks",
                                        )),
                                        DataCell(PrimaryTextWidget(
                                          content: widget
                                              .contestInfoObj["exam_marks"]
                                              .toString(),
                                        )),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(PrimaryTextWidget(
                                          content: "Contest Duration",
                                        )),
                                        DataCell(PrimaryTextWidget(
                                          content: widget.contestInfoObj[
                                                      "exam_duration"]
                                                  .toString() +
                                              " Mins",
                                        )),
                                      ]),
                                      DataRow(cells: [
                                        DataCell(PrimaryTextWidget(
                                          content: "Attempts Remaining",
                                        )),
                                        DataCell(PrimaryTextWidget(
                                          content: remainingAttempts.toString(),
                                          color: Colors.green,
                                        )),
                                      ]),
                                      if (widget.contestInfoObj["for_org"] &&
                                          widget.contestInfoObj["org_name"] !=
                                              null)
                                        DataRow(cells: [
                                          DataCell(PrimaryTextWidget(
                                            content: "Organization",
                                          )),
                                          DataCell(PrimaryTextWidget(
                                            content: widget
                                                .contestInfoObj["org_name"]
                                                .toString(),
                                          )),
                                        ])
                                    ]),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                          ],
                        ),
                        new ListTile(
                          onTap: () {
                            share(
                                title:
                                    'Hey,\nParticipate in this awesome ${widget.contestInfoObj["exam_name"]} from Talent Connect.',
                                subject:
                                    '${widget.contestInfoObj["exam_name"]}');
                          },
                          title: PrimaryTextWidget(
                            content: "Share this contest",
                            fontSize: 20,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Image.asset(
                                "assets/images/whatsapp-icon.png",
                                height: 26,
                              ),
                              new SizedBox(
                                width: 5.0,
                              ),
                              Icon(
                                Icons.expand_more,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: DisplayBox(
                              icon: "assets/images/lightbulb.png",
                              showIcon: true,
                              content:
                                  "If you score more than or equal to ${(int.parse(widget.contestInfoObj["exam_marks"]) / 2).floor()} Marks. You will be rewarded with ${widget.contestInfoObj["gift"]} coins"),
                        ),
                        Container(
                            child: randomImageNumber == 0
                                ? FadeInImage.assetNetwork(
                                    placeholder: 'assets/nointernet.gif',
                                    image: zerothImage,
                                  )
                                : randomImageNumber == 1
                                    ? FadeInImage.assetNetwork(
                                        placeholder: 'assets/nointernet.gif',
                                        image: onethImage,
                                      )
                                    : FadeInImage.assetNetwork(
                                        placeholder: 'assets/nointernet.gif',
                                        image: secondImage,
                                      )),
                        SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: PrimaryTextWidget(
                            textAlign: TextAlign.center,
                            fontSize: 12,
                            content:
                                "${quotesObj.quotes[_randomQuote.nextInt(quotesObj.quotes.length)]["quote"]}\n-${quotesObj.quotes[_randomQuote.nextInt(quotesObj.quotes.length)]["author"]}",
                          ),
                        ),
                        SizedBox(height: 5),
                      ],
                    )
                  ],
                ),
              ),
            )),
        bottomNavigationBar: BottomAppBar(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 60.0,
            child: ElevatedButton(
              onPressed: userIsAttempted
                  ? null
                  : () {
                      showModalBottomSheet(
                          isScrollControlled: false,
                          elevation: 60,
                          barrierColor: Colors.black87,
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (BuildContext context, setState) {
                                return Scrollbar(
                                    child: ListView(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: HeaderTextFancyWidget(
                                              content: widget
                                                  .contestInfoObj["exam_name"],
                                              fontSize: 20,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: new HeaderTextWidget(
                                              content: "Instructions",
                                              fontSize: 20,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: <Widget>[
                                                widget.contestInfoObj["for_org"]
                                                    ? PrimaryTextWidget(
                                                        content:
                                                            "1. You will be having only ${widget.contestInfoObj["max_attempts"]} free attempt(s). However you can purchase more attempts with your TC Coins if your organization allows you to do so.\n\n"
                                                            "2. Make sure you are connected to a stable internet connection before attempting the contest.\n\n"
                                                            "3. Note that this is an organisational quiz. Please follow and adhere to the rules given by your organization and attempt the contest accordingly.\n\n"
                                                            "4. Any kind of cheating or other activities will not be entertained and may lead to disqualify your participation as per your organization rules.\n\n"
                                                            "5. Once the timer ends your contest will be auto submitted\n\n"
                                                            "6. Declaration of contest results is solely responsible by your 'Organisation'. Please note that Talent Connect will not involve in any kind of result modification therefore only involves in providing system generated reports to the organization.\n\n"
                                                            "7. Please do not try to get out of scope from the app, Doing so your contest will be auto submitted.\n\n"
                                                            "8. Please keep your mobile phone in DND Mode while taking the contest so that your contest will not be auto submitted while receiving a phone call.")
                                                    : new PrimaryTextWidget(
                                                        content:
                                                            "1. You will be having only ${widget.contestInfoObj["max_attempts"]} free attempt(s). However you can purchase more attempts with your TC Coins.\n\n"
                                                            "2. Make sure you are connected to a stable internet connection before attempting the contest.\n\n"
                                                            "3. Any kinds of cheating or other activities will not be entertained.\n\n"
                                                            "4. Once the timer ends your contest will be auto submitted\n\n"
                                                            "5. Declaration of contest results is solely responsible to the 'Talent Connect Team'. Results once announced cannot be changed further.\n\n"
                                                            "6. Please do not try to get out of scope from the app, Doing so your contest will be auto submitted.\n\n"
                                                            "7. Please keep your mobile phone in DND Mode while taking the contest so that your contest will not be auto submitted while receiving a phone call."),
                                                CheckboxListTile(
                                                    controlAffinity:
                                                        ListTileControlAffinity
                                                            .leading,
                                                    title: PrimaryTextWidget(
                                                      content:
                                                          "I have carefully read the instructions",
                                                    ),
                                                    value: isReadInstructions,
                                                    onChanged: (val) {
                                                      setState(() {
                                                        isReadInstructions =
                                                            val;
                                                      });
                                                    })
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                height: 60,
                                                child: ElevatedButton(
                                                  onPressed: userIsAttempted
                                                      ? null
                                                      : isReadInstructions
                                                          ? () async {
                                                              if (widget.contestInfoObj[
                                                                          "contest_pin_required"] ==
                                                                      false &&
                                                                  !widget.contestInfoObj[
                                                                      "for_org"]) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                              setState(() {
                                                                _loading = true;
                                                              });
                                                              await crudObj
                                                                  .checkForContestPIN(
                                                                      widget
                                                                          .contestInfoObj)
                                                                  .then(
                                                                      (isRequired) {
                                                                print("IS REQUIRED:" +
                                                                    isRequired
                                                                        .toString());
                                                                if (isRequired ||
                                                                    widget.contestInfoObj[
                                                                        "for_org"]) {
                                                                  setState(() {
                                                                    _loading =
                                                                        true;
                                                                  });
                                                                  showContestPINDialog(
                                                                      context);
                                                                } else {
                                                                  afterPINVerification();
                                                                }
                                                              });
                                                            }
                                                          : null,
                                                  child: HeaderTextWidget(
                                                    content: userIsAttempted
                                                        ? "No attempts left"
                                                        : "🔒 Enter the Contest",
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ));
                              },
                            );
                          });
                    },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeaderTextWidget(
                    content:
                        userIsAttempted ? "No attempts available" : "Proceed",
                    color: Colors.white,
                  ),
                  userIsAttempted
                      ? Container()
                      : Icon(
                          Icons.arrow_right_alt_rounded,
                          color: Colors.white,
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
