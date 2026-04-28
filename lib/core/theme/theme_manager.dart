import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_colors.dart';

class ThemeManager with ChangeNotifier {
  static const String _themeKey = 'user_theme_mode';
  static const String _askedKey = 'has_been_asked_theme';
  final SharedPreferences _prefs;

  static ThemeData get lightTheme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: ThemeColors.backgroundLight,
    primaryColor: ThemeColors.burgundy,
    colorScheme: ColorScheme.light(
      primary: ThemeColors.burgundy,
      secondary: ThemeColors.burgundyLight,
      surface: ThemeColors.surfaceLight,
      background: ThemeColors.backgroundLight,
    ),
    textTheme: GoogleFonts.outfitTextTheme(),
  );

  static ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: ThemeColors.backgroundDark,
    primaryColor: ThemeColors.burgundyLight,
    colorScheme: ColorScheme.dark(
      primary: ThemeColors.burgundyLight,
      secondary: ThemeColors.burgundy,
      surface: ThemeColors.surfaceDark,
      background: ThemeColors.backgroundDark,
    ),
    textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
  );

  ThemeManager(this._prefs) {
    _loadTheme();
  }

  ThemeMode _themeMode = ThemeMode.system;
  bool _hasBeenAsked = false;

  ThemeMode get themeMode => _themeMode;
  bool get hasBeenAsked => _hasBeenAsked;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  void _loadTheme() {
    final savedTheme = _prefs.getString(_themeKey);
    _hasBeenAsked = _prefs.getBool(_askedKey) ?? false;
    
    if (savedTheme == 'light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    String value = 'system';
    if (mode == ThemeMode.light) value = 'light';
    if (mode == ThemeMode.dark) value = 'dark';
    
    await _prefs.setString(_themeKey, value);
    await markAsAsked();
    notifyListeners();
  }

  Future<void> markAsAsked() async {
    _hasBeenAsked = true;
    await _prefs.setBool(_askedKey, true);
    notifyListeners();
  }
}
