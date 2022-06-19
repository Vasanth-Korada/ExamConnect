import 'package:share/share.dart';

share({String title, String subject}) async {
  return Share.share(
      title == null
          ? "Exam Connect is an initiative by Vasanth Korada to help talented people unleash their skills and win prizes. We will be hosting different kinds of quizzes or contests targeting multiple audiences with your support."
              "\nDownload Exam Connect mobile app from Google Play:"
              " \nhttps://play.google.com/store/apps/details?id=com.vktech.exam_connect"
          : title +
              "\n\nDownload Exam Connect app from Google Play:\nhttps://play.google.com/store/apps/details?id=com.vktech.exam_connect",
      subject:
          subject == null ? "\nExam Connect App from Google Play" : subject);
}
