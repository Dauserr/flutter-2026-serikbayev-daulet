import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required this.dark, required this.defaultStatus});

  final SharedPreferencesAsync _prefs;
  bool dark;
  String defaultStatus;

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();

    await _prefs.setBool('darkMode', value);
  }

  Future<void> setDefaultStatus(String value) async {
    defaultStatus = value;
    notifyListeners();

    await _prefs.setString('statusFilter', value);
  }
}
