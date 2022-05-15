import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/ad_manager.dart';
import 'package:talent_connect/helpers/check-internet-connection.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/pages/signin-page.dart';
import 'package:talent_connect/widgets/AnimatedCount.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';

class ResultPage extends StatefulWidget {
  final Map contestInfoObj;
  int score;

  ResultPage({@required this.contestInfoObj, @required this.score});

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final player = new AudioPlayer();
  bool showDisplayBox = false;
  bool isGiftEarned;
  ConfettiController _confettiController;
  final _random = new Random();

  int next(int min, int max) => min + _random.nextInt(max - min);
  int randomImageNumber;
  String zerothImage = "";
  String onethImage = "";
  CrudMethods crudObj = new CrudMethods();

  void playMusic() {
    print("Playing");
    player.play("congratulations.mp3");
  }

  @override
  void initState() {
    super.initState();
    print("Result Screen");
    print(widget.score);
    print(widget.contestInfoObj);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    fetchImages();
    interstitialAd
      ..load()
      ..show(
        anchorType: AnchorType.bottom,
        anchorOffset: 0.0,
        horizontalCenterOffset: 0.0,
      );
    checkInternetConnectivity(context).then((val) {
      val == true
          ? ShowDialog(context: context, content: "No Internet Connection!")
          : print("Connected");
    });

    String email = Provider.of<UserModel>(context, listen: false).userEmail;

    if ((widget.score) >=
        (int.parse(widget.contestInfoObj["exam_marks"]) / 2).floor()) {
      playMusic();
      _confettiController =
          new ConfettiController(duration: Duration(seconds: 15));
      _confettiController.play();

      var ref = crudObj.isGiftEarned(
          contestId: widget.contestInfoObj["exam_id"], email: email);
      ref.then((var val) {
        print(val);
        if (val == false || val == null) {
          crudObj.modifyUserCoins(
              email: email,
              coins: widget.contestInfoObj["gift"],
              context: context);

          DateTime now = new DateTime.now();
          DateTime date = new DateTime(
              now.year, now.month, now.day, now.hour, now.minute, now.second);

          crudObj.addToCoinsActivity(
              email: email,
              transacDate: date,
              transacType: "credit",
              coins: widget.contestInfoObj["gift"],
              reason:
                  "Gifted for scoring ${widget.score} / ${widget.contestInfoObj["exam_marks"]} for ${widget.contestInfoObj["exam_id"]} Contest");

          crudObj.modifyGiftEarnedStatus(
              email: email, contestId: widget.contestInfoObj["exam_id"]);

          setState(() {
            showDisplayBox = true;
            widget.score = widget.score;
          });
        }
      });
    } else {
      _confettiController =
          new ConfettiController(duration: Duration(seconds: 1));
      _confettiController.stop();
    }

    randomImageNumber = next(0, 2);
  }

  fetchImages() async {
    await crudObj.fetchAssets().then((doc) {
      setState(() {
        zerothImage = doc.data["dev_images"][0];
        onethImage = doc.data["dev_images"][4];
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _confettiController.dispose();
    interstitialAd.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        appBar: GradientAppBar(
            content: widget.contestInfoObj["exam_name"], appBar: AppBar()),
        body: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (widget.contestInfoObj["showResult"] == null
                    ? false
                    : widget.contestInfoObj["showResult"])
                ? Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirection: pi,
                          // radial value - LEFT
                          particleDrag: 0.05,
                          // apply drag to the confetti
                          emissionFrequency: 0.01,
                          // how often it should emit
                          numberOfParticles: 20,
                          // number of particles to emit
                          gravity: 0.05,
                          // gravity - or fall speed
                          shouldLoop: false,
                          colors: const [
                            Colors.green,
                            Colors.blue,
                            Colors.pink,
                            Colors.purple
                          ], // manually specify the colors to be used
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirection: 0,
                          // radial value - RIGHT

                          emissionFrequency: 0.01,
                          minimumSize: const Size(10, 10),
                          // set the minimum potential size for the confetti (width, height)
                          maximumSize: const Size(10, 30),
                          // set the maximum potential size for the confetti (width, height)
                          numberOfParticles: 20,
                          gravity: 0.1,
                        ),
                      ),
                      new PrimaryTextWidget(
                        content:
                            "We are as fast as you. And so here is your result!",
                      ),
                      new SizedBox(height: 20),
                      new Container(
                        width: MediaQuery.of(context).size.width - 80,
                        height: 100.0,
                        decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.circular(4.0)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            new HeaderTextWidget(
                              textalign: TextAlign.center,
                              fontweight: FontWeight.w700,
                              color: Colors.green,
                              content: "Result",
                              fontSize: 26,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedCount(
                                    count: widget.score,
                                    duration: Duration(seconds: 6)),
                                new HeaderTextWidget(
                                  textalign: TextAlign.center,
                                  fontweight: FontWeight.w700,
                                  color: Colors.green,
                                  content:
                                      " / ${widget.contestInfoObj["exam_marks"]}",
                                  fontSize: 26,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      randomImageNumber == 0
                          ? new FadeInImage.assetNetwork(
                              placeholder: 'assets/nointernet.gif',
                              image: zerothImage,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/nointernet.gif',
                              image: onethImage,
                            ),
                      new SizedBox(
                        height: 20,
                      ),
                      showDisplayBox
                          ? DisplayBox(
                              content:
                                  "You won ${widget.contestInfoObj["gift"]} coins",
                              showIcon: false,
                              width: 200,
                            )
                          : Container(),
                      SizedBox(
                        height: 30,
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: HeaderTextWidget(
                          content:
                              "Your result has been calculated. Please stay in touch with the contest organiser for the result update 🙂",
                          textalign: TextAlign.center,
                        ),
                      ),
                      randomImageNumber == 0
                          ? new FadeInImage.assetNetwork(
                              placeholder: 'assets/nointernet.gif',
                              image: zerothImage,
                            )
                          : FadeInImage.assetNetwork(
                              placeholder: 'assets/nointernet.gif',
                              image: onethImage,
                            ),
                    ],
                  ),
            new CircleAvatar(
              radius: 30.0,
              backgroundColor: Color(0xFF7A17CE),
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).push(CupertinoPageRoute(
                    builder: (context) => SignIn(),
                  ));
                },
                icon: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30.0,
                ),
              ),
            ),
          ],
        ));
  }
}
