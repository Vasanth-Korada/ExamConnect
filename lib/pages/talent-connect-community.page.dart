import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:talent_connect/widgets/appbar.widget.dart';
import 'package:talent_connect/widgets/display-box.widget.dart';

class TalentConnectCommunity extends StatefulWidget {
  @override
  _TalentConnectCommunityState createState() => _TalentConnectCommunityState();
}

class _TalentConnectCommunityState extends State<TalentConnectCommunity> {
  Widget buildUserList(
      BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasData) {
      return Scrollbar(
        child: Column(
          children: [
            Expanded(
              child: Center(
                  child: DisplayBox(
                      showIcon: false,
                      content:
                          "Total Community Members:${snapshot.data.docs.length}")),
            ),
            Expanded(
              flex: 8,
              child: ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot user = snapshot.data.docs[index];
                  return ListTile(
                    leading: Text((index + 1).toString()),
                    title: Text(user.get('userName')),
                    subtitle: Text(user.get('userName')),
                    trailing: CircleAvatar(
                      backgroundImage: user.get('userPhoto') != null
                          ? NetworkImage(user.get('userPhoto'))
                          : null,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } else if (snapshot.connectionState == ConnectionState.done &&
        !snapshot.hasData) {
      // Handle no data
      return Center(
        child: Text("No users found."),
      );
    } else {
      // Still loading
      return Center(child: LinearProgressIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: GradientAppBar(content: "Community", appBar: AppBar()),
        body: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('loginData').snapshots(),
            builder: buildUserList));
  }
}
