import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:exam_connect/helpers/crud.dart';
import 'package:exam_connect/pages/aboutus-page.dart';
import 'package:exam_connect/widgets/text-widget.dart';
import 'package:url_launcher/url_launcher.dart';

class DrawerWidget extends StatefulWidget {
  final String username;

  DrawerWidget({@required this.username});

  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  String welcomeMessage = "Welcome to Exam Connect";
  CrudMethods crudObj = new CrudMethods();

  @override
  void initState() {
    super.initState();
    fetchWelcomeMessage();
  }

  _rateUsLink() async {
    var url =
        'https://play.google.com/store/apps/details?id=com.vktech.exam_connect';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  fetchWelcomeMessage() async {
    await crudObj.fetchAssets().then((doc) {
      setState(() {
        welcomeMessage = doc.data["message_board"];
      });
    });
  }

  _waGroupLink() async {
    var url = '';
    await crudObj.fetchAssets().then((doc) {
      url = doc.data["wa_group_link"];
    });
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        child: ListView(
          children: <Widget>[
            new SizedBox(
              height: 25,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: Color(0XFFf9fafd),
                  minRadius: 70,
                  maxRadius: 100,
                  backgroundImage: AssetImage("assets/images/new_logo.png"),
                ),
              ],
            ),
            new SizedBox(
              height: 10,
            ),
            new Divider(),
            Card(
              margin: EdgeInsets.all(8.0),
              color: Colors.indigo[500],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: new ListTile(
                title: PrimaryTextWidget(
                  content: "Hi " +
                          widget.username.toString().split(" ")[0] +
                          " 😃\n$welcomeMessage" ??
                      "Welcome to Exam Connect",
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            new ListTile(
              onTap: () {
                _rateUsLink();
              },
              leading: Icon(Icons.star_border_outlined),
              title: HeaderTextWidget(
                content: "Rate Us",
              ),
            ),
            new ListTile(
              onTap: () {
                Navigator.pushNamed(context, "/resourcesPage");
              },
              leading: Icon(Icons.youtube_searched_for_outlined),
              title: HeaderTextWidget(
                content: "Resources",
              ),
            ),
            new ListTile(
              onTap: () {
                _waGroupLink();
              },
              leading: Icon(Icons.chat_outlined),
              title: HeaderTextWidget(
                content: "Community Group",
              ),
            ),
            new ListTile(
              onTap: () => {
                Navigator.of(context).push(
                    new CupertinoPageRoute(builder: (context) => AboutUS()))
              },
              leading: Icon(Icons.info_outline),
              title: HeaderTextWidget(
                content: "About Us",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
