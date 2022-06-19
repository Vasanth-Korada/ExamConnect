import 'package:flutter/material.dart';
import 'package:exam_connect/helpers/crud.dart';
import 'package:exam_connect/widgets/appbar.widget.dart';
import 'package:exam_connect/widgets/text-widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatefulWidget {
  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  CrudMethods crudObj = new CrudMethods();

  _subscribeLink() async {
    var url = '';
    await crudObj.fetchAssets().then((doc) {
      url = "https://www.youtube.com/channel/UCuxkk3TD7cfPR08JEWVyXZA";
    });
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _dccLink() async {
    var url = '';
    await crudObj.fetchAssets().then((doc) {
      url =
          "https://play.google.com/store/apps/details?id=com.vktech.daily_coding_challenges";
    });
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _sepLink() async {
    var url = '';
    await crudObj.fetchAssets().then((doc) {
      url =
          "https://play.google.com/store/apps/details?id=com.vktech.expiry_remainder";
    });
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget resourceWidget(
      {String url, String desc, String buttonText, Function buttonCallback}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(url),
                  SizedBox(height: 12),
                  PrimaryTextWidget(content: desc, fontSize: 14),
                  RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      onPressed: buttonCallback,
                      child: PrimaryTextWidget(
                        content: buttonText,
                        fontSize: 16,
                        color: Colors.white,
                      ))
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(
          appBar: AppBar(),
          content: "Resources",
        ),
        body: ListView(
          children: [
            resourceWidget(
                url:
                    "https://firebasestorage.googleapis.com/v0/b/talent-connect-70ae6.appspot.com/o/dev_images%2FINFY%20TECH%20Channel%20Banner.png?alt=media&token=57d3ca97-f10a-48d3-acee-3b9dfdc62379",
                desc:
                    "INFY TECH is a YouTube channel by Vasanth Korada where he delivers tech and programming content in the way that everyone needs",
                buttonText: "Subscribe now",
                buttonCallback: _subscribeLink),
            resourceWidget(
                url:
                    "https://firebasestorage.googleapis.com/v0/b/talent-connect-70ae6.appspot.com/o/dev_images%2FCopy%20of%20Daily%20Coding%20Challenges%20%26%20Concepts.png?alt=media&token=1c1321c3-48b7-4ade-ad0e-3daad6470a63",
                desc:
                    "Daily Coding Challenges, Concepts & Articles\nThis app delivers daily coding challenges, concepts & articles with relevant solutions and examples which might be helpful for your interview preparations and also in learning programming concepts and coding challenges",
                buttonText: "Download now",
                buttonCallback: _dccLink),
            resourceWidget(
                url:
                    "https://firebasestorage.googleapis.com/v0/b/talent-connect-70ae6.appspot.com/o/dev_images%2Fer19201080.png?alt=media&token=fe19c066-51f2-4129-8f26-0467d13207f9",
                desc:
                    "Smart Expiry Reminder\nGet Expiration Reminders for your Medical, Grocery & Other Products",
                buttonText: "Download now",
                buttonCallback: _sepLink),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                  child: PrimaryTextWidget(
                      content: "Keep looking here for more resources...🤗️",
                      fontSize: 12)),
            )
          ],
        ));
  }
}
