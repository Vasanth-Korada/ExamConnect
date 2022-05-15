import 'package:flutter/material.dart';
import 'package:talent_connect/helpers/check-internet-connection.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/drawer.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementsPage extends StatefulWidget {
  final Map userObj;
  AnnouncementsPage({@required this.userObj});
  @override
  _AnnouncementsPageState createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends State<AnnouncementsPage> {
  CrudMethods crudObj = new CrudMethods();
  var announcements;

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
  void initState() {
    super.initState();

    checkInternetConnectivity(context).then((val) {
      val == true
          ? ShowDialog(context: context, content: "No Internet Connection!")
          : print("Connected");
    });
    crudObj.fetchAnnouncements().then((results) {
      setState(() {
        announcements = results;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(username: widget.userObj["displayName"]),
      appBar: GradientAppBar(content: "Announcements", appBar: AppBar()),
      body: Column(
        children: <Widget>[
          new SizedBox(
            height: 10,
          ),
          Container(
            child: RaisedButton(
              onPressed: () {
                _waGroupLink();
              },
              splashColor: Colors.green,
              textColor: Colors.white,
              padding: const EdgeInsets.all(0.0),
              child: Container(
                width: MediaQuery.of(context).size.width - 20,
                height: 55,
                decoration: new BoxDecoration(
                    gradient: new LinearGradient(
                  colors: [
                    Color(0xFF04BF00),
                    Color(0xFF04BF00),
                  ],
                )),
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        height: 30,
                        child: Image.asset("assets/images/whatsapp-icon.png"),
                      ),
                      new SizedBox(
                        width: 10.0,
                      ),
                      HeaderTextWidget(
                        color: Colors.white,
                        content: "Join TC Community",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: announcements,
              builder: (context, snapshot) {
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
                      content: "No Announcements",
                      fontSize: 12.0,
                    ),
                  );
                }
                return Scrollbar(
                  child: ListView.builder(
                      itemCount: snapshot.data.docs.length,
                      itemBuilder: (context, i) {
                        String title = snapshot.data.docs[i].data()["title"];
                        String desc =
                            snapshot.data.docs[i].data()["description"];
                        String img =
                            snapshot.data.docs[i].data()["image_url"];
                        print(img);
                        String datePosted = snapshot
                            .data.docs[i].data()["date_posted"]
                            .toDate()
                            .toUtc()
                            .toString();
                        print("Title" + title);
                        return Card(
                          elevation: 4.0,
                          margin: EdgeInsets.all(8.0),
                          shape: Border.all(),
                          shadowColor: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: HeaderTextFancyWidget(
                                content: title,
                                textAlign: TextAlign.center,
                              ),
                              subtitle: Column(
                                children: <Widget>[
                                  if (img != null)
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.network(img),
                                    ),
                                  new SizedBox(height: 5.0),
                                  PrimaryTextWidget(
                                    content: desc,
                                    color: Colors.black87,
                                    fontSize: 12,
                                  ),
                                  new SizedBox(height: 10.0),
                                  PrimaryTextWidget(
                                      content: "Date Posted: " +
                                          datePosted.substring(0, 10),
                                      fontSize: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
