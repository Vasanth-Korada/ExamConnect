import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:exam_connect/classes/UserModel.dart';
import 'package:exam_connect/firebase_options.dart';
import 'package:exam_connect/helpers/crud.dart';
import 'package:exam_connect/pages/announcements-page.dart';
import 'package:exam_connect/pages/contests-page.dart';
import 'package:exam_connect/pages/my-activity.page.dart';
import 'package:exam_connect/pages/mycoins.page.dart';
import 'package:exam_connect/pages/profile-page.dart';
import 'package:exam_connect/pages/resources.page.dart';
import 'package:exam_connect/pages/signin-page.dart';
import 'package:exam_connect/pages/talent-connect-community.page.dart';
import 'package:exam_connect/widgets/text-widget.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  await WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ChangeNotifierProvider(
    create: (context) => UserModel(),
    child: new MaterialApp(
      title: "Exam Connect",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          fontFamily: "GoogleSansRegular",
          textSelectionTheme: TextSelectionThemeData(
              cursorColor: Color(0xFF7A17CE),
              selectionHandleColor: Colors.indigo[200],
              selectionColor: Colors.indigo),
          primaryColorLight: Color(0xFF7A17CE),
          primaryColor: Color(0xFF7A17CE),
          splashColor: Colors.indigo[200],
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.indigo)
              .copyWith(secondary: Color(0xFF7A17CE))),
      home: SignIn(),
      routes: {
        '/myActivity': (context) => MyActivityPage(),
        '/talentConnectCommunity': (context) => TalentConnectCommunity(),
        '/myCoinsPage': (context) => MyCoinsPage(),
        '/resourcesPage': (context) => ResourcesPage(),
      },
    ),
  ));
}

class HomePage extends StatefulWidget {
  final Map userObj;

  HomePage({@required this.userObj});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CrudMethods crudObj = new CrudMethods();
  bool updateApp = false;
  bool maintenance = false;

  void fetchCoins() async {
    DocumentReference ref = await crudObj.getUserInfo(widget.userObj["email"]);
    await ref.get().then((doc) {
      print(doc.get('coins'));
      Provider.of<UserModel>(context, listen: false).coins = doc.get('coins');
    });
  }

  checkAppStatus() async {
    await FirebaseFirestore.instance
        .collection("assets")
        .doc("assets")
        .get()
        .then((doc) {
      if (doc.get('update_app')) {
        setState(() {
          updateApp = true;
        });
      } else if (doc.get('maintenance')) {
        setState(() {
          maintenance = true; //Change to true here
        });
      }
    });
  }

  void onTapHandler(int index) {
    if (index == 0) {
      _children[0] = ContestsPage(
        userObj: widget.userObj,
      );
    } else if (index == 1) {
      _children[1] = AnnouncementsPage(
        userObj: widget.userObj,
      );
    } else {
      _children[2] = ProfilePage(
        userObj: widget.userObj,
      );
    }
    setState(() {
      _currentIndex = index;
    });
  }

  _saveDeviceToken() async {
    String fcmToken = await _fcm.getToken();
    if (fcmToken != null) {
      var tokens = _db.collection('tokens').doc(fcmToken);

      await tokens.set({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem
      });
    }
  }

  final List<Widget> _children = [
    Container(),
    Container(),
    Container(),
  ];

  @override
  void initState() {
    super.initState();
    fetchCoins();

    checkAppStatus();

    onTapHandler(0);
    _saveDeviceToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onTapHandler(1);
      print("onMessage: $message");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: ListTile(
            title: Text(message.notification.title),
            subtitle: Text(message.notification.body),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      onTapHandler(1);
      print("onLaunch: $event");
    });

    FirebaseMessaging.onBackgroundMessage((RemoteMessage message) async {
      onTapHandler(1);
    });
  }

  showInfoUI({@required String type}) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HeaderTextFancyWidget(
          content: type == "update_app"
              ? "Update the App now, We just got little better 🙂️"
              : "Maintenance Break, We'll be back soon 😉️",
        ),
        SizedBox(height: 20),
        type == "update_app"
            ? Image.asset("assets/images/update_app.png")
            : Image.asset("assets/images/maintenance.png"),
        type == "update_app"
            ? Container(
                width: MediaQuery.of(context).size.width - 40,
                height: 50.0,
                child: new RaisedButton(
                  onPressed: () async {
                    final url =
                        "https://play.google.com/store/apps/details?id=com.vktech.exam_connect";
                    if (await canLaunch(url)) {
                      await launch(
                        url,
                        forceSafariVC: false,
                      );
                    }
                  },
                  child: new PrimaryTextWidget(
                    content: "UPDATE NOW",
                    color: Colors.white,
                  ),
                ),
              )
            : Container(),
      ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return updateApp
        ? showInfoUI(type: "update_app")
        : maintenance
            ? showInfoUI(type: "maintenance")
            : Scaffold(
                backgroundColor: Color(0xFFefefef),
                body: _children[_currentIndex],
                bottomNavigationBar: Container(
                  height: 80,
                  child: BottomNavigationBar(
                    elevation: 16.0,
                    type: BottomNavigationBarType.fixed,
                    currentIndex: _currentIndex,
                    onTap: (index) {
                      onTapHandler(index);
                    },
                    items: [
                      BottomNavigationBarItem(
                        icon: new Icon(Icons.home_filled),
                        label: "Home",
                      ),
                      BottomNavigationBarItem(
                        icon: new Icon(Icons.article_rounded),
                        label: "Messages",
                      ),
                      BottomNavigationBarItem(
                          icon: Icon(Icons.account_circle_rounded),
                          label: "Profile")
                    ],
                  ),
                ),
              );
  }
}
