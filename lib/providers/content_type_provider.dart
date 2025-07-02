import 'package:flutter/material.dart';
import '../models/content_type.dart';

class ContentTypeProvider extends ChangeNotifier {
  ContentType _selected = ContentType.movie;

  ContentType get selected => _selected;

  void setContent(ContentType type) {
    if (_selected != type) {
      _selected = type;
      notifyListeners();
    }
  }
}
