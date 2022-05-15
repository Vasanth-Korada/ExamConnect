import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talent_connect/classes/UserModel.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/pages/signin-page.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talent_connect/widgets/drawer.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  final dynamic userObj;

  ProfilePage({@required this.userObj});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GoogleSignIn _googleSignIn = new GoogleSignIn();
  CrudMethods crudObj = new CrudMethods();
  UserModel userModel = new UserModel();

  _logout(BuildContext context) async {
    _googleSignIn.signOut();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('username', null);
    setState(() {
      userModel.userEmail = "";
      IsLogged.name = '';
      IsLogged.isloggedin = false;
    });

    Navigator.of(context)
        .pushReplacement(CupertinoPageRoute(builder: (context) => SignIn()));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserModel>(
        builder: (context, model, widget) => Scaffold(
            drawer: DrawerWidget(
              username: model.userName,
            ),
            appBar: GradientAppBar(content: "My Profile", appBar: AppBar()),
            body: ListView(
              children: [
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CircleAvatar(
                      backgroundColor: Colors.indigo[200],
                      radius: 70.0,
                      backgroundImage: NetworkImage(model.userPhoto),
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    HeaderTextWidget(
                      content: model.userName.toString().toUpperCase(),
                      fontSize: 20,
                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3.0),
                            border: Border.all(
                                width: 0.0, color: Color(0xFF023436))),
                        child: new DataTable(dataRowHeight: 60, columns: [
                          DataColumn(
                              label: HeaderTextWidget(
                            content: "Email",
                          )),
                        ], rows: [
                          DataRow(cells: [
                            DataCell(new PrimaryTextWidget(
                              content: model.userEmail,
                            ))
                          ]),
                        ]),
                      ),
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    Container(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/myActivity');
                            },
                            child: new Container(
                              height: 130,
                              width: MediaQuery.of(context).size.width / 2.5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF732BCA),
                                        Color(0xFF7A17CE)
                                      ])),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Lottie.asset("assets/lotties/activity.json",
                                      width: 65, height: 65),
                                  PrimaryTextWidget(
                                    content: "My Activity",
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/myCoinsPage');
                            },
                            child: new Container(
                              height: 130,
                              width: MediaQuery.of(context).size.width / 2.5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF732BCA),
                                        Color(0xFF7A17CE)
                                      ])),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Lottie.asset("assets/lotties/coin.json",
                                      width: 65, height: 65),
                                  PrimaryTextWidget(
                                    content: "My TC Coins",
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width - 48,
                      height: 60.0,
                      child: new RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                        color: Colors.redAccent.shade200,
                        onPressed: () => _logout(context),
                        child: new PrimaryTextWidget(
                          content: "LOGOUT",
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )));
  }
}
