import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:exam_connect/classes/UserModel.dart';

class CrudMethods {
  final FirebaseFirestore _database = FirebaseFirestore.instance;

  Future settleUserActivity() async {
    var testRef = await _database.collection('tests');
    var loginRef = await _database.collection('loginData');
    // await testRef.getdocs().then((ds) {
    //   ds.docs.forEach((testDoc) async {
    //     await testDoc.reference
    //         .collection('participants')
    //         .getdocs()
    //         .then((partEmailDocRef) => {
    //               partEmailDocRef.docs.forEach((partEmailDoc) async {
    //                 print(partEmailDoc.docID);
    //                 await loginRef.getdocs().then((loginDataRef) => {
    //                       loginDataRef.docs.forEach((loginEmailDoc) {
    //                         if (partEmailDoc.docID ==
    //                             loginEmailDoc.docID) {
    //                           var dupRef = loginEmailDoc.reference
    //                               .collection('myActivity')
    //                               .doc(testDoc.docID);

    //                           dupRef.setData({
    //                             "marks": partEmailDoc["marks"],
    //                             "submit_time": partEmailDoc["submit_time"],
    //                             "exam_name": testDoc["exam_name"],
    //                             "date_posted": testDoc["date_posted"],
    //                             "contest_img_url": testDoc["contest_img_url"],
    //                             "exam_id": testDoc["exam_id"],
    //                             "exam_marks": testDoc["exam_marks"],
    //                           });
    //                         }
    //                       })
    //                     });
    //               })
    //             });
    //   });
    // });

    // Adding Users to Login Data Collection
    // await testRef.getdocs().then((ds) {
    //   ds.docs.forEach((testDoc)async {
    //     await testDoc.reference.collection('participants')
    //     .getdocs()
    //     .then((partRef) => {
    //           partRef.docs.forEach((participant) async {
    //             var ref = await _database
    //                 .collection('loginData')
    //                 .doc(participant.docID);

    //             ref.get().then((doc) async {
    //               print(doc.exists);
    //               if (doc.exists) {
    //                 print(doc.docID);
    //               } else {
    //                 await ref
    //                     .setData({
    //                       "userName": participant["userName"],
    //                       "userPhoto": participant["profilePic"]
    //                     })
    //                     .then((value) => {print("Doc Created")})
    //                     .catchError((err) => {print("Error Creating Doc")});
    //               }
    //             });
    //           })
    //         });
    //   });
    // });

    // Checker
    // var ref = await _database
    //     .collection('loginData').getdocs();

    // print(ref.docs.length);

    // ref.get().then((doc) async {
    //     print(doc.exists);
    //     if(doc.exists){
    //       print(doc.docID);
    //       print(doc.data);
    //     }
    //     else{
    //       print("Not Found");
    //     }
    // });
  }

  addtoLoginDataCollection(
      {@required String email,
      @required String uid,
      @required String userName,
      @required String userPhoto}) async {
    var docRef = _database.collection('loginData').doc(email);
    docRef.get().then((doc) async => {
          if (!doc.exists)
            {
              await docRef.set({
                "uid": uid,
                "userName": userName,
                "userPhoto": userPhoto,
                "coins": 0
              })
            }
        });
  }

  Future<void> addToken(data) async {
    _database.runTransaction((Transaction crudTransaction) async {
      CollectionReference reference = _database.collection('pushtokens');
      reference.add(data);
    });
  }

  getContests() async {
    return await _database
        .collection('tests')
        .orderBy("date_posted", descending: false)
        .snapshots();
  }

  Future userAttemptedContest(
      Map userObj, Map contestInfoObj, Map orgObj) async {
    var ref = await _database
        .collection("tests")
        .doc(contestInfoObj["exam_id"].toString())
        .collection("participants")
        .doc(userObj["email"]);

    ref.get().then((doc) async {
      if (doc.exists) {
        await ref.update({
          "userName": userObj["displayName"],
          "profilePic": userObj["photoUrl"],
          "isAttempted": true,
          "isSubmitted": false,
          "remaining_attempts": FieldValue.increment(-1),
          "marks": null,
          "attempt_time": FieldValue.serverTimestamp(),
        });
      } else {
        if (orgObj != null) {
          await ref.set({
            "userName": userObj["displayName"],
            "profilePic": userObj["photoUrl"],
            "isAttempted": true,
            "isSubmitted": false,
            "remaining_attempts": contestInfoObj["max_attempts"] - 1,
            "marks": null,
            "attempt_time": FieldValue.serverTimestamp(),
            "gift_earned": false,
            "regd_no": orgObj["regdNo"],
            "branch": orgObj["branch"],
            "section": orgObj["section"]
          });
        } else {
          await ref.set({
            "userName": userObj["displayName"],
            "profilePic": userObj["photoUrl"],
            "isAttempted": true,
            "isSubmitted": false,
            "remaining_attempts": contestInfoObj["max_attempts"] - 1,
            "marks": null,
            "attempt_time": FieldValue.serverTimestamp(),
            "gift_earned": false,
          });
        }
      }
    });
  }

  Future userSubmittedContest(int score, Map userObj, var examID, Map orgObj,
      Map userRes, bool storeUserRes) async {
    var ref = await _database
        .collection("tests")
        .doc(examID.toString())
        .collection("participants")
        .doc(userObj["email"]);

    Map<String, String> userResMap = new Map<String, String>(); //keys as String

    userRes.forEach((key, value) {
      userResMap.putIfAbsent(key.toString(), () => value);
    });

    if (storeUserRes == true) {
      await ref.update({
        "isSubmitted": true,
        "isAttempted": true,
        "marks": score,
        "userRes": userResMap,
        "submit_time": FieldValue.serverTimestamp(),
      }).catchError((e) {
        print(e);
      });
    } else {
      await ref.update({
        "isSubmitted": true,
        "isAttempted": true,
        "marks": score,
        "submit_time": FieldValue.serverTimestamp()
      }).catchError((e) {
        print(e);
      });
    }

    if (orgObj != null) {
      await ref.update({
        "regd_no": orgObj["regdNo"],
        "branch": orgObj["branch"],
        "section": orgObj["section"]
      }).catchError((e) {
        print(e);
      });
    }
    var loginDataRef =
        await _database.collection('loginData').doc(userObj["email"]);

    loginDataRef
        .collection('myActivity')
        .doc(examID.toString())
        .set({"marks": score, "submit_time": FieldValue.serverTimestamp()});
  }

  Future<int> checkAvailableAttempts(Map examObj, String email) async {
    int avaiableAttempts;
    var ref = await _database
        .collection("tests")
        .doc(examObj["exam_id"].toString())
        .collection("participants")
        .doc(email);
    await ref.get().then((doc) {
      if (doc.exists) {
        avaiableAttempts = doc.data()["remaining_attempts"];
      } else {
        avaiableAttempts = examObj["max_attempts"];
      }
    }).catchError((e) async {
      print(e);
      await ref.update({
        "remaining_attempts": examObj["max_attempts"],
      });
      avaiableAttempts = examObj["max_attempts"];
    });
    print("Available Attempts:" + avaiableAttempts.toString());
    return avaiableAttempts;
  }

  fetchAnnouncements() async {
    return await _database
        .collection("announcements")
        .orderBy('date_posted', descending: true)
        .snapshots();
  }

  fetchUserCoinsActivity({@required String email}) async {
    print(email);
    return await _database
        .collection("loginData")
        .doc(email)
        .collection("coinsActivity")
        .snapshots();
  }

  fetchAssets() async {
    return await _database.collection("assets").doc("assets").get();
  }

  Future<bool> checkForContestPIN(Map contestInfoObj) async {
    bool isRequired;
    var ref =
        await _database.collection("tests").doc(contestInfoObj["exam_id"]);
    await ref.get().then((doc) {
      isRequired = doc.data()["contest_pin_required"];
      print("Contest PIN Required:" + isRequired.toString());
      return isRequired;
    }).catchError((e) {
      isRequired = false;
    });
    return isRequired;
  }

  CollectionReference getUserActivity(String userEmail) {
    return _database
        .collection("loginData")
        .doc(userEmail)
        .collection("myActivity");
  }

  DocumentReference getQuizInfo(String quizId) {
    return _database.collection("tests").doc(quizId);
  }

  DocumentReference getQuizPerformance(String quizId, String userEmail) {
    return _database
        .collection("tests")
        .doc(quizId)
        .collection("participants")
        .doc(userEmail);
  }

  DocumentReference getUserInfo(String email) {
    return _database.collection("loginData").doc(email);
  }

  void purchaseAttempt(
      {@required String contestId,
      @required String email,
      @required int debitCoins}) async {
    var ref1 = await _database.collection("loginData").doc(email);

    await ref1
        .update({"coins": FieldValue.increment(-debitCoins)})
        .then((value) => {print("Attempt Purchased")})
        .catchError((err) => print(err));
    ;
    var ref = await _database
        .collection("tests")
        .doc(contestId)
        .collection("participants")
        .doc(email);
    await ref
        .update({"remaining_attempts": FieldValue.increment(1)})
        .then((value) => {print("Attempt Purchased")})
        .catchError((err) => print(err));
  }

  Future modifyUserCoins(
      {@required String email,
      @required int coins,
      @required BuildContext context}) async {
    var ref = await _database.collection("loginData").doc(email);
    await ref.update({
      "coins": FieldValue.increment(coins),
    });
    await ref.get().then((data) {
      Provider.of<UserModel>(context, listen: false).coins = data["coins"];
      print(Provider.of<UserModel>(context).coins.toString());
    });
    return;
  }

  Future modifyGiftEarnedStatus(
      {@required String email, @required String contestId}) async {
    var ref1 = await _database
        .collection("tests")
        .doc(contestId)
        .collection("participants");
    await ref1.doc(email).update({"gift_earned": true});
  }

  Future addToCoinsActivity(
      {@required String email,
      @required DateTime transacDate,
      @required String transacType,
      @required int coins,
      @required String reason}) async {
    var ref = await _database
        .collection("loginData")
        .doc(email)
        .collection("coinsActivity");
    await ref.doc(transacDate.toString()).set(
        {"transacType": transacType, "coins": coins, "reason": reason});
  }

  Future<bool> isGiftEarned(
      {@required String contestId, @required String email}) async {
    var ref = await _database
        .collection("tests")
        .doc(contestId)
        .collection("participants")
        .doc(email);

    return ref.get().then((doc) => doc.data()["gift_earned"]);
  }

  void addToKeysUnlockArray(
      {@required String email, @required String contestId}) async {
    await _database.collection("loginData").doc(email).update({
      "keys_unlocked": FieldValue.arrayUnion([contestId])
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<bool> checkIfKeyUnlocked(
      {@required String email, @required String contestId}) async {
    var ref = await _database.collection("loginData").doc(email).get();
    if ((ref.data()["keys_unlocked"]).contains(contestId)) {
      return true;
    } else {
      return false;
    }
  }

// inititateCoinsField() async {
//   CollectionReference ref = await _database.collection("loginData");
//   ref.getdocs().then((ds) => {
//         if (ds != null)
//           {
//             ds.docs.forEach((doc) {
//               doc.reference.update({
//                 "coins": 0,
//               });
//             })
//           }
//       }).catchError((err)=>{
//         debugPrint(err)
//       });
//   print("Initiate Coins Task Completed");
// }

// Future<bool> isUserAttempted(var examID, String email) async {
//   bool userAttempStatus;
//   var ref = await _database
//       .collection("tests")
//       .doc(examID.toString())
//       .collection("participants")
//       .doc(email);
//   await ref.get().then((doc) {
//     userAttempStatus = doc.data["isAttempted"];
//   });
//   print(userAttempStatus.toString());
//   return userAttempStatus;
// }
}
