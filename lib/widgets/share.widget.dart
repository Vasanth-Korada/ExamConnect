import 'package:share/share.dart';

share({String title, String subject}) async {
  return Share.share(
      title == null
          ? "Talent Connect is an initiative by Vasanth Korada to help talented people unleash their skills and win prizes. We will be hosting different kinds of quizzes or contests targeting multiple audiences with your support."
              "\nDownload Talent Connect mobile app from Google Play:"
              " \nhttps://play.google.com/store/apps/details?id=com.vktech.talent_connect"
          : title +
              "\n\nDownload Talent Connect app from Google Play:\nhttps://play.google.com/store/apps/details?id=com.vktech.talent_connect",
      subject:
          subject == null ? "\nTalent Connect App from Google Play" : subject);
}
