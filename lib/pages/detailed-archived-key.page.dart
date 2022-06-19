import 'package:flutter/material.dart';
import 'package:exam_connect/widgets/appbar.widget.dart';
import 'package:exam_connect/widgets/text-widget.dart';

class DetailedArchivedKeyPage extends StatelessWidget {
  String question = "";
  dynamic answer;
  List<dynamic> options = [];
  bool isDescriptive = false;
  String explanation;
  DetailedArchivedKeyPage(
      {@required this.question,
      @required this.answer,
      @required this.options,
      @required this.explanation}) {
    if (options == null) {
      isDescriptive = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(explanation);
    return Scaffold(
      appBar: GradientAppBar(
        appBar: AppBar(),
        content: "Key",
      ),
      body: Scrollbar(
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    children: [
                      HeaderTextFancyWidget(
                        content: "Question",
                      ),
                      SizedBox(height: 10),
                      HeaderTextWidget(
                        content: question,
                        textalign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Divider(),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: Column(
                    children: [
                      HeaderTextFancyWidget(
                        content: "Answer",
                      ),
                      !isDescriptive
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: options.map((option) {
                                if (answer is List) {
                                  return ListTile(
                                    title: PrimaryTextWidget(
                                      content: option,
                                      color: answer.contains(option)
                                          ? Colors.green
                                          : Colors.redAccent,
                                      fontSize: 12,
                                    ),
                                  );
                                }

                                return ListTile(
                                  title: HeaderTextWidget(
                                    content: option,
                                    color: option == answer
                                        ? Colors.green
                                        : Colors.redAccent,
                                  ),
                                );
                              }).toList())
                          : ListTile(
                              title: HeaderTextWidget(
                                  content: answer, color: Colors.green),
                            ),
                      Divider(),
                      explanation != null
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(14.0),
                                  child: HeaderTextFancyWidget(
                                    content: "Explanation",
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: PrimaryTextWidget(
                                      content: explanation, fontSize: 14),
                                )
                              ],
                            )
                          : Container()
                    ],
                  ),
                ),
                Image.asset(
                  "assets/images/key-image.png",
                  height: 240,
                  width: 280,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
