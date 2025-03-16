import 'package:flutter/material.dart';

class ThemeToggle extends ChangeNotifier {
  var _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Brightness brightness(BuildContext context) => switch (_mode) {
        ThemeMode.system => MediaQuery.platformBrightnessOf(context),
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
      };

  void toggle(BuildContext context) {
    _mode = switch (brightness(context)) {
      Brightness.light => ThemeMode.dark,
      Brightness.dark => ThemeMode.light,
    };
    notifyListeners();
  }
}
