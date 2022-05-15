import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';

class MyCoinsPage extends StatefulWidget {
  @override
  _MyCoinsPageState createState() => _MyCoinsPageState();
}

class _MyCoinsPageState extends State<MyCoinsPage> {
  MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
    keywords: <String>[
      'education',
      'career',
      'coding',
      'programming',
      'games',
      'sports',
      'technology',
      'tech',
      'interview',
      'entertainment'
    ],
    contentUrl: 'https://flutter.io',
    childDirected: false,
    testDevices: <String>[],
  );
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  CrudMethods crudObj = new CrudMethods();
  UserModel userModel = new UserModel();
  Map userObj = {};
  var coinsActivity;

  @override
  void initState() {
    userObj = Provider.of<UserModel>(context, listen: false).getUserData();
    DocumentReference ref = crudObj.getUserInfo(userObj["userEmail"]);
    ref.get().then(
        (doc) => Provider.of<UserModel>(context).coins = doc.get('coins'));

    crudObj.fetchUserCoinsActivity(email: userObj["userEmail"]).then((data) {
      setState(() {
        coinsActivity = data;
      });
    });

    super.initState();
  }

  SnackBar displaySnackBar({@required String message}) {
    return SnackBar(
      content: PrimaryTextWidget(
        content: message,
        fontSize: 14,
      ),
    );
  }

  void showRewardAd() {
    try {
      final videoAd = RewardedVideoAd.instance;

      videoAd
          .load(
              adUnitId: "ca-app-pub-8559543128044506/7938630466",
              targetingInfo: targetingInfo)
          .then((value) => {
                if (value == false)
                  {
                    _scaffoldKey.currentState.showSnackBar(displaySnackBar(
                        message: "No Ads Available, Please try again!"))
                  }
                else if (value == true)
                  {
                    videoAd.show().catchError((e) {
                      _scaffoldKey.currentState.showSnackBar(displaySnackBar(
                          message: "No Ads Available, Please try again!"));
                      return null;
                    })
                  }
              });

      videoAd.listener =
          (RewardedVideoAdEvent event, {String rewardType, int rewardAmount}) {
        rewardAmount = 5;
        if (event == RewardedVideoAdEvent.failedToLoad) {
          _scaffoldKey.currentState
              .showSnackBar(displaySnackBar(message: "Failed to Load"));
        } else if (event == RewardedVideoAdEvent.rewarded) {
          setState(() {
            Provider.of<UserModel>(context).coins += rewardAmount;
            crudObj.modifyUserCoins(
                email: userObj["userEmail"],
                coins: rewardAmount,
                context: context);
          });
          DateTime now = new DateTime.now();
          DateTime date = new DateTime(
              now.year, now.month, now.day, now.hour, now.minute, now.second);
          crudObj.addToCoinsActivity(
              email: userObj["userEmail"],
              transacDate: date,
              transacType: "credit",
              coins: rewardAmount,
              reason: "Earned for watching an Ad");
          _scaffoldKey.currentState.showSnackBar(
              displaySnackBar(message: "${rewardAmount} Coins rewarded!"));
        }
      };
    } on PlatformException {
      _scaffoldKey.currentState.showSnackBar(
          displaySnackBar(message: "No Ads Available, Please try again!"));
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
      builder: (context, model, widget) => Scaffold(
        key: _scaffoldKey,
        appBar: GradientAppBar(
          content: "My TC Coins",
          appBar: AppBar(),
        ),
        body: new Column(
          children: [
            Container(
              height: 40,
              color: Colors.black26,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  PrimaryTextWidget(
                    content: "Want more coins?",
                    fontSize: 14,
                  ),
                  SizedBox(width: 30),
                  TextButton(
                      onPressed: () {
                        showRewardAd();
                      },
                      child: PrimaryTextWidget(
                        content: "WATCH AN AD",
                        fontSize: 14,
                      ))
                ],
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 80.0,
              decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(4.0)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HeaderTextWidget(
                    content: "Available Coins",
                  ),
                  HeaderTextFancyWidget(
                    content: model.coins.toString(),
                    fontSize: 32,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder(
                  stream: coinsActivity,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: new PrimaryTextWidget(
                          content: "Loading ....",
                          fontSize: 12.0,
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data.docs.isEmpty) {
                      return Center(
                        child: new PrimaryTextWidget(
                          content: "Oops! No Transactions available",
                          fontSize: 12.0,
                        ),
                      );
                    }
                    return Column(
                      children: [
                        SizedBox(height: 15),
                        SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              HeaderTextFancyWidget(
                                content: "DATE",
                              ),
                              HeaderTextFancyWidget(
                                content: "TYPE",
                              ),
                              SizedBox(
                                width: 60,
                                child: HeaderTextFancyWidget(
                                  content: "COINS",
                                ),
                              ),
                              SizedBox(
                                width: 100,
                                child: HeaderTextFancyWidget(
                                  content: "REASON",
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Scrollbar(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: snapshot.data.docs.length,
                              itemBuilder: (context, i) {
                                var len = snapshot.data.docs.length;
                                var transacType = snapshot.data
                                    .docs[len - i - 1].data()["transacType"];
                                var coins = snapshot
                                    .data.docs[len - i - 1].data()["coins"];
                                var reason = snapshot
                                    .data.docs[len - i - 1].data()["reason"];
                                var date = snapshot
                                    .data.docs[len - i - 1].id
                                    .toString()
                                    .substring(0, 10);
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          PrimaryTextWidget(
                                            content:
                                                date.toString().toUpperCase(),
                                            fontSize: 14,
                                          ),
                                          SizedBox(
                                            width: 80,
                                            child: PrimaryTextWidget(
                                              content: transacType
                                                  .toString()
                                                  .toUpperCase(),
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 50,
                                            child: PrimaryTextWidget(
                                              content: coins.toString(),
                                              fontSize: 14,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: PrimaryTextWidget(
                                              content: reason,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider()
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
