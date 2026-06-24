import 'dart:async';
import 'package:flutter/material.dart';

class Debounce {
  final Duration duration;
  Timer? _timer;

  Debounce({this.duration = const Duration(milliseconds: 400)});

  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    cancel();
  }
}
