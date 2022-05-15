import 'package:flutter/material.dart';

class UserModel extends ChangeNotifier {
  int _coins;
  int get coins => _coins;
  set coins(int coins) {
    _coins = coins;
    notifyListeners();
  }

  String _userEmail;
  String get userEmail => _userEmail;
  set userEmail(String userEmail) {
    _userEmail = userEmail;
  }

  String _userPhoto;
  String get userPhoto => _userPhoto;
  set userPhoto(String userPhoto) {
    _userPhoto = userPhoto;
    notifyListeners();
  }

  String _userName;
  String get userName => _userName;
  set userName(String userName) {
    _userName = userName;
    notifyListeners();
  }

  String _userId;
  String get userId => _userId;
  set userId(String userId) {
    _userId = userId;
    notifyListeners();
  }

  Map<String, dynamic> getUserData() {
    Map<String, dynamic> userObj = {};
    userObj["userEmail"] = userEmail;
    userObj["userPhoto"] = userPhoto;
    userObj["userName"] = userName;
    userObj["userId"] = userId;
    userObj["coins"] = coins;
    return userObj;
  }
}
