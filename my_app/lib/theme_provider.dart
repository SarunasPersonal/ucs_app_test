import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ucs_app/constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 1.0; // 1.0 is normal, 1.2 is large, 0.8 is small
  bool _isLoaded = false;
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  bool get isLoaded => _isLoaded;
  
  // Constructor loads saved preferences
  ThemeProvider() {
    _loadPreferences();
  }
  
  // Load saved preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load values
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _fontSize = prefs.getDouble('fontSize') ?? 1.0;
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      // Use defaults if there's an error
      _isDarkMode = false;
      _fontSize = 1.0;
      _isLoaded = true;
      notifyListeners();
    }
  }
  
  // Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setDouble('fontSize', _fontSize);
    } catch (e) {
      // Handle error silently
    }
  }
  
  // Toggle dark mode
  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }
  
  // Set font size
  void setFontSize(double size) {
    _fontSize = size;
    _savePreferences();
    notifyListeners();
  }
  
  // Get theme based on current settings
  ThemeData getTheme() {
    final baseTheme = _isDarkMode ? _darkTheme : _lightTheme;
    
    // Simply create a copy of the base theme
    // We'll use a simpler approach that doesn't modify text styles directly
    return baseTheme.copyWith(
      textTheme: _getTextTheme(baseTheme.brightness),
      primaryTextTheme: _getTextTheme(baseTheme.brightness),
    );
  }
  
  // Create a text theme with the appropriate font size
  TextTheme _getTextTheme(Brightness brightness) {
    // Define a font size for each text style based on our scaling factor
    final double scaleFactor = _fontSize;
    
    // Create a completely new text theme with explicit font sizes
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 96 * scaleFactor,
        fontWeight: FontWeight.w300,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 60 * scaleFactor,
        fontWeight: FontWeight.w300,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      displaySmall: TextStyle(
        fontSize: 48 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      headlineLarge: TextStyle(
        fontSize: 40 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      headlineMedium: TextStyle(
        fontSize: 34 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      headlineSmall: TextStyle(
        fontSize: 24 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      titleLarge: TextStyle(
        fontSize: 20 * scaleFactor,
        fontWeight: FontWeight.w500,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      titleSmall: TextStyle(
        fontSize: 14 * scaleFactor,
        fontWeight: FontWeight.w500,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scaleFactor,
        fontWeight: FontWeight.w500,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
      ),
      labelSmall: TextStyle(
        fontSize: 10 * scaleFactor,
        fontWeight: FontWeight.w400,
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
      ),
    );
  }
  
  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: primaryColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: secondaryColor,
    ),
  );
  
  // Dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: Color(0xFF121212),
    ),
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: primaryColor,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: const Color(0xFF1E1E1E),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: secondaryColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      fillColor: const Color(0xFF2C2C2C),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    ),
  );
}