// lib/reading_settings.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingSettings with ChangeNotifier {
  // --- Keys for storage ---
  static const String fontSizeKey = 'fontSize';
  static const String backgroundColorKey = 'backgroundColor';

  double _fontSize = 24.0;
  Color _backgroundColor = Colors.white;

  double get fontSize => _fontSize;
  Color get backgroundColor => _backgroundColor;

  // --- Methods to change and SAVE settings ---
  Future<void> setFontSize(double newSize) async {
    _fontSize = newSize;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(fontSizeKey, newSize); 
  }

  Future<void> setBackgroundColor(Color newColor) async {
    _backgroundColor = newColor;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(backgroundColorKey, newColor.value);
  }
  
  // --- Method to LOAD settings on startup ---
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    _fontSize = prefs.getDouble(fontSizeKey) ?? 24.0;

    int? colorValue = prefs.getInt(backgroundColorKey);
    _backgroundColor = colorValue != null ? Color(colorValue) : Colors.white;
    
    notifyListeners();
  }
}