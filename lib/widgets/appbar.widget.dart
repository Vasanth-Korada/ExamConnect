import 'package:flutter/material.dart';
import 'package:exam_connect/widgets/text-widget.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String content;
  final AppBar appBar;
  bool showExamPageActions;
  final Function onExamPageSubmitClicked;
  GradientAppBar(
      {@required this.content,
      @required this.appBar,
      this.showExamPageActions = false,
      this.onExamPageSubmitClicked});
  @override
  Widget build(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: HeaderTextFancyWidget(
        content: content,
        fontSize: 18,
        color: Colors.white,
      ),
      flexibleSpace: new Container(
        decoration: new BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF732BCA), Color(0xFF7A17CE)])),
      ),
      actions: [
        showExamPageActions
            ? PopupMenuButton<String>(
                enabled: true,
                onSelected: (_) => onExamPageSubmitClicked(context),
                itemBuilder: (BuildContext context) {
                  return {'Submit Now'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: PrimaryTextWidget(content: choice, fontSize: 14),
                    );
                  }).toList();
                },
              )
            : Container(),
      ],
    );
  }

  @override
  Size get preferredSize => new Size.fromHeight(appBar.preferredSize.height);
}
