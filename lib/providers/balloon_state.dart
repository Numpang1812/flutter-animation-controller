import 'package:flutter/material.dart';

class BalloonState extends ChangeNotifier {
  bool _firstBalloonPopped = false;
  
  bool get firstBalloonPopped => _firstBalloonPopped;

  void popFirstBalloon() {
    _firstBalloonPopped = true;
    notifyListeners();
  }

  void reset() {
    _firstBalloonPopped = false;
    notifyListeners();
  }
}
