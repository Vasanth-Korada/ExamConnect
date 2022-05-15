import 'package:flutter/material.dart';
import 'package:talent_connect/widgets/text-widget.dart';

class AnimatedCount extends ImplicitlyAnimatedWidget {
  final int count;

  AnimatedCount(
      {Key key,
      @required this.count,
      @required Duration duration,
      Curve curve = Curves.linear})
      : super(duration: duration, curve: curve, key: key);

  @override
  ImplicitlyAnimatedWidgetState<ImplicitlyAnimatedWidget> createState() =>
      _AnimatedCountState();
}

class _AnimatedCountState extends AnimatedWidgetBaseState<AnimatedCount> {
  IntTween _count;

  @override
  Widget build(BuildContext context) {
    return new HeaderTextWidget(
      textalign: TextAlign.center,
      fontweight: FontWeight.w700,
      color: Colors.green,
      content: "${_count.evaluate(animation).toString()}",
      fontSize: 26,
    );
  }

  @override
  void forEachTween(TweenVisitor visitor) {
    _count = visitor(
        _count, widget.count, (dynamic value) => new IntTween(begin: value));
  }
}
