import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:exam_connect/classes/UserModel.dart';
import 'package:exam_connect/helpers/crud.dart';
import 'package:exam_connect/helpers/loader.dart';
import 'package:exam_connect/pages/intisplash-screen.page.dart';
import 'package:exam_connect/widgets/tc_header.dart';
import 'package:exam_connect/widgets/text-widget.dart';
import '../helpers/check-internet-connection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'package:provider/provider.dart';

class IsLogged {
  static bool isloggedin = false;
  static String name = '';
}

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  CrudMethods crudObj = new CrudMethods();
  GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  User user;
  User currentUser;
  bool _loading = false;
  String signupImage = "";
  UserModel userModel = new UserModel();
  bool showInitSplashScreen = false;

  _login() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final GoogleSignInAccount googleSignInAccount =
          await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      final UserCredential authResult =
          await _auth.signInWithCredential(credential);
      user = authResult.user;
      currentUser = await _auth.currentUser;
      debugPrint("User Obj" + _googleSignIn.currentUser.toString());
      prefs.setString('id', _googleSignIn.currentUser.id);
      prefs.setString('username', _googleSignIn.currentUser.displayName);
      prefs.setString('useremail', _googleSignIn.currentUser.email);
      prefs.setString('userphoto', _googleSignIn.currentUser.photoUrl);
      var _currentuser = _googleSignIn.currentUser;
      setState(() {
        IsLogged.name = _googleSignIn.currentUser.displayName;
        IsLogged.isloggedin = true;

        Provider.of<UserModel>(context, listen: false).userName =
            _currentuser.displayName;
        Provider.of<UserModel>(context, listen: false).userPhoto =
            _currentuser.photoUrl;
        Provider.of<UserModel>(context, listen: false).userEmail =
            _currentuser.email;
        Provider.of<UserModel>(context, listen: false).userId = _currentuser.id;
      });

      crudObj.addtoLoginDataCollection(
          email: _googleSignIn.currentUser.email,
          uid: _googleSignIn.currentUser.id,
          userName: _googleSignIn.currentUser.displayName,
          userPhoto: _googleSignIn.currentUser.photoUrl);

      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (context) => HomePage(
                userObj: {
                  "id": _googleSignIn.currentUser.id,
                  "displayName": _googleSignIn.currentUser.displayName,
                  "email": _googleSignIn.currentUser.email,
                  "photoUrl": _googleSignIn.currentUser.photoUrl
                },
              )));
    } catch (err) {
      print(err);
    }
  }

  void autoLogIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString("id", "12");
    prefs.setString("username", "Vasanth Korada");
    prefs.setString("useremail", "vasanthkorada999@gmail.com");
    prefs.setString("userphoto", "");

    final String id = prefs.getString('id');
    final String userId = prefs.getString('username');
    final String useremail = prefs.getString('useremail');
    final String userphoto = prefs.getString('userphoto');

    if (userId != null) {
      setState(() {
        setState(() {
          showInitSplashScreen = true;
        });
      });
      return;
    }
  }

  @override
  void initState() {
    autoLogIn();
    checkInternetConnectivity(context).then((val) {
      val == true
          ? ShowDialog(context: context, content: "No Internet Connection!")
          : print("Connected");
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return showInitSplashScreen
        ? InitSplashScreen(
            afterSplashCallback: () async {
              final SharedPreferences prefs =
                  await SharedPreferences.getInstance();
              final String id = prefs.getString('id');
              final String userId = prefs.getString('username');
              final String useremail = prefs.getString('useremail');
              final String userphoto = prefs.getString('userphoto');
              IsLogged.isloggedin = true;
              IsLogged.name = userId;

              Provider.of<UserModel>(context, listen: false).userName = userId;
              Provider.of<UserModel>(context, listen: false).userPhoto =
                  userphoto;
              Provider.of<UserModel>(context, listen: false).userEmail =
                  useremail;
              Provider.of<UserModel>(context, listen: false).userId = id;

              Navigator.of(context).pushReplacement(CupertinoPageRoute(
                  builder: (context) => HomePage(
                        userObj: {
                          "id": id,
                          "email": useremail,
                          "displayName": userId,
                          "photoUrl": userphoto
                        },
                      )));
            },
          )
        : SafeArea(
            child: Center(
              child: Scaffold(
                backgroundColor: Color(0XFFf9fafd),
                body: ModalProgressHUD(
                  progressIndicator: MyCustomLoader(
                    color: Color(0XFF7A17CE),
                  ),
                  inAsyncCall: _loading,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      TCHeader(),
                      SizedBox(
                        height: 30,
                      ),
                      CircleAvatar(
                        minRadius: 80,
                        maxRadius: 120,
                        backgroundColor: Color(0xFFf9fafd),
                        backgroundImage:
                            AssetImage("assets/images/new_logo.png"),
                      ),
                      SizedBox(
                        height: 30,
                      ),
                      Column(
                        children: <Widget>[
                          _signInButton(),
                          new SizedBox(
                            height: 25.0,
                          ),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Icon(
                                Icons.lock,
                                color: Colors.black,
                              ),
                              new SizedBox(
                                width: 5.0,
                              ),
                              new PrimaryTextWidget(
                                content:
                                    "Your data is safe with us.\nWe don't spam.",
                                color: Colors.black,
                                textAlign: TextAlign.center,
                                fontSize: 12.0,
                              )
                            ],
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget _signInButton() {
    return MaterialButton(
      splashColor: Colors.indigo[200],
      onPressed: () {
        setState(() {
          _loading = true;
        });
        _login();
      },
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(color: Colors.grey)),
      highlightElevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image(
                image: AssetImage("assets/images/google_logo.png"),
                height: 30.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: HeaderTextWidget(
                content: "Sign in with Google",
              ),
            )
          ],
        ),
      ),
    );
  }
}
