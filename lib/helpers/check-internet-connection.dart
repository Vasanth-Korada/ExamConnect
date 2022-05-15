import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

Future<bool> checkInternetConnectivity(BuildContext context) async {
  var connectivityResult = await (new Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    return true;
  }
  return false;
}



ShowDialog({@required BuildContext context, @required String content}) async {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset("assets/images/hugo-no-connection.png"),
          ListTile(
            title: Text(content),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
