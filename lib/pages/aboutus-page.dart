import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:talent_connect/helpers/crud.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/text-widget.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutUS extends StatefulWidget {
  @override
  _AboutUSState createState() => _AboutUSState();
}

class _AboutUSState extends State<AboutUS> {
  CrudMethods crudObj = new CrudMethods();
  String weblink = "loading";
  String appdevImage = "";
  int randomImageNumber;
  final _random = new Random();
  int next(int min, int max) => min + _random.nextInt(max - min);

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    randomImageNumber = next(0, 2);
    crudObj.fetchAssets().then((doc) {
      setState(() {
        weblink = doc.data["website_link"];
      });
    });
  }

  // fetchappDevImage() async {
  //   await crudObj.fetchAssets().then((doc) {
  //     setState(() {
  //       appdevImage = doc.data["dev_images"][5];
  //     });
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: new GradientAppBar(content: "About Us", appBar: AppBar()),
        body: Scrollbar(
          child: Scrollbar(
            child: ListView(
              children: [
                new Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      "assets/images/about-us.png",
                      height: 200,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 12.0),
                      child: PrimaryTextWidget(
                        textAlign: TextAlign.center,
                        content:
                            "Talent Connect is an initiative by Vasanth Korada to help talented people unleash their skills and win prizes.\n\nWe will be hosting different kinds of quizzes or contests targeting multiple audience with your support.",
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Container(
                            decoration: BoxDecoration(border: Border.all()),
                            child: new DataTable(columnSpacing: 10, columns: [
                              new DataColumn(
                                  label: PrimaryTextWidget(
                                content: "Role",
                              )),
                              new DataColumn(
                                  label: PrimaryTextWidget(
                                content: "Name",
                              )),
                            ], rows: [
                              DataRow(cells: [
                                DataCell(PrimaryTextWidget(
                                  content: "Developer",
                                )),
                                DataCell(PrimaryTextWidget(
                                  content: "Vasanth Korada",
                                )),
                              ]),
                              DataRow(cells: [
                                DataCell(PrimaryTextWidget(
                                  content: "Core Team & Organiser(s)",
                                )),
                                DataCell(PrimaryTextWidget(
                                  content: "Srikanth. M",
                                )),
                              ]),
                            ]),
                          ),
                        ),
                        new SizedBox(height: 20),
                        new Divider(),
                        new SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  new Icon(Icons.language),
                                  new SizedBox(
                                    width: 5,
                                  ),
                                  PrimaryTextWidget(
                                    content: "Web",
                                    fontSize: 16,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () async {
                                  final url = weblink;
                                  print(url);
                                  if (await canLaunch(url)) {
                                    await launch(
                                      url,
                                      forceSafariVC: false,
                                    );
                                  } else {
                                    print("Cant Launch Url");
                                  }
                                },
                                child: RichText(
                                    text: TextSpan(
                                  text: "${weblink}",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline),
                                )),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
