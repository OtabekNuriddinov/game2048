import 'package:flutter/material.dart';

class Tile {
  final int x;
  final int y;
  int val;

  late Animation<double> animatedX;
  late Animation<double> animatedY;
  late Animation<int> animatedVal;
  late Animation<double> scale;

  Tile({required this.x, required this.y, required this.val}) {
    resetAnimation();
  }

  void resetAnimation() {
    animatedX = AlwaysStoppedAnimation(x.toDouble());
    animatedY = AlwaysStoppedAnimation(y.toDouble());
    animatedVal = AlwaysStoppedAnimation(val);
    scale = AlwaysStoppedAnimation(1.0);
  }

  void moveTo(Animation<double> parent, int x, int y) {
    animatedX = Tween(begin: this.x.toDouble(), end: x.toDouble()).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0, .5),
      ),
    );

    animatedY = Tween(begin: this.y.toDouble(), end: y.toDouble()).animate(
      CurvedAnimation(
        parent: parent,
        curve: Interval(0, .5),
      ),
    );
  }

  void bounce(Animation<double> parent) {
    scale = TweenSequence([
      TweenSequenceItem<double>(
          tween: Tween(begin: 1.0, end: 1.2), weight: 1.0),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 1.0)
    ]).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(.5, 1.0),
    ));
  }

  void appear(Animation<double> parent) {
    scale = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(.5, 1.0),
    ));
  }

  void changeNumber(Animation<double> parent, int newVal) {
    animatedVal = TweenSequence([
      TweenSequenceItem(tween: ConstantTween(val), weight: .01),
      TweenSequenceItem(tween: ConstantTween(newVal), weight: .99)
    ]).animate(CurvedAnimation(
      parent: parent,
      curve: Interval(.5, 1.0),
    ));
  }
}
