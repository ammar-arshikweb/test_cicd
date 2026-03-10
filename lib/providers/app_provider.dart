import 'package:flutter/material.dart';

class AppProvider with ChangeNotifier {
  String? _appLanguage;
  bool _isDark = false;

  String? get appLanguage {
    if (_appLanguage == null) {
      getLanguage();
    }
    return _appLanguage;
  }

  bool get isDark => _isDark;

  Future<void> setLanguage(String languageToBeSet) async {
    getLanguage();
    notifyListeners();
  }

  Future<void> getLanguage() async {}

  Future<void> setDark(bool isDark) async {
    _isDark = isDark;
    notifyListeners();
  }
}
