import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  SettingsModel(this._prefs, {required this.dark, this.city});

  final SharedPreferencesAsync _prefs;
  bool dark;
  String? city;

  Future<void> setDark(bool value) async {
    dark = value;
    notifyListeners();

    await _prefs.setBool('darkMode', value);
  }

  Future<void> setCity(String? value) async {
    city = value;
    notifyListeners();

    if (value == null) {
      await _prefs.remove('cityFilter');
      return;
    }

    await _prefs.setString('cityFilter', value);
  }
}
