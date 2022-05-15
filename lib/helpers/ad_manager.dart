import 'dart:io';

import 'package:firebase_admob/firebase_admob.dart';

class
AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8559543128044506~8623465675";
      // return "ca-app-pub-3940256099942544/3419835294"; //test
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  // static String get bannerAdUnitId {
  //   if (Platform.isAndroid) {
  //     return "ca-app-pub-8559543128044506/2877875477";
  //   } else {
  //     throw new UnsupportedError("Unsupported platform");
  //   }
  // }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8559543128044506/2796423921";
      // return "ca-app-pub-3940256099942544/1033173712"; //test-ad
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-8559543128044506/7938630466";
      // return "ca-app-pub-3940256099942544/5354046379"; //test
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}

MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
  keywords: <String>[
    'education',
    'career',
    'coding',
    'programming',
    'games',
    'sports',
    'technology',
    'tech',
    'interview',
    'entertainment'
  ],
  contentUrl: 'https://flutter.io',
  childDirected: false,
  testDevices: <String>[],
);

InterstitialAd interstitialAd = InterstitialAd(
  adUnitId: AdManager
      .interstitialAdUnitId, //Change to original ad unit id which has'/'
  targetingInfo: targetingInfo,
  listener: (MobileAdEvent event) {
    // print("BannerAd event is $event");
  },
);


// BannerAd myBanner = BannerAd(
//   adUnitId:
//       AdManager.bannerAdUnitId, //Change to original ad unit id which has'/'
//   size: AdSize.smartBanner,
//   targetingInfo: targetingInfo,
//   listener: (MobileAdEvent event) {
//     // print("BannerAd event is $event");
//   },
// );