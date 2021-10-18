import 'package:flutter/material.dart';

class ProfileProvider with ChangeNotifier {
  bool _isAuthentificated = false;
  bool get isAuthentificated {
    return _isAuthentificated;
  }

  ProfileProvider(bool isAuthentificated) {
    _isAuthentificated = isAuthentificated;
  }

  set isAuthentificated(bool newVal) {
    _isAuthentificated = newVal;

    notifyListeners();
  }
}
