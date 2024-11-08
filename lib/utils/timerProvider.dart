import 'dart:async';
import 'package:flutter/material.dart';

// GPT4 Vision의 call rate limit이 60초 가량 걸리는 문제를 해결하기 위해 60초 타이머 도입 -박준수

class TimerProvider with ChangeNotifier {
  Timer? _timer;
  bool _timerCompleted = true;

  bool get timerCompleted => _timerCompleted;

  void startTimer() {
    _timer?.cancel(); // 기존 타이머가 있다면 취소
    _timerCompleted = false; // 타이머 시작
    notifyListeners();

    _timer = Timer(Duration(seconds: 2), () {
      _timerCompleted = true; // 타이머 완료
      notifyListeners();
    });
  }

  void disposeTimer() {
    _timer?.cancel();
  }
}