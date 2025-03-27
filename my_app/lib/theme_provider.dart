import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_ucs_app/constants.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  double _fontSize = 1.0; // 1.0 is normal, 1.2 is large, 0.8 is small
  bool _isHighContrast = false;
  bool _isBoldText = false;
  bool _isScreenReaderOptimized = false;
  bool _reduceMotion = false;
  bool _isLoaded = false;
  
  // Getters
  bool get isDarkMode => _isDarkMode;
  double get fontSize => _fontSize;
  bool get isHighContrast => _isHighContrast;
  bool get isBoldText => _isBoldText;
  bool get isScreenReaderOptimized => _isScreenReaderOptimized;
  bool get reduceMotion => _reduceMotion;
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
      _isHighContrast = prefs.getBool('isHighContrast') ?? false;
      _isBoldText = prefs.getBool('isBoldText') ?? false;
      _isScreenReaderOptimized = prefs.getBool('isScreenReaderOptimized') ?? false;
      _reduceMotion = prefs.getBool('reduceMotion') ?? false;
      
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      // Use defaults if there's an error
      _isDarkMode = false;
      _fontSize = 1.0;
      _isHighContrast = false;
      _isBoldText = false;
      _isScreenReaderOptimized = false;
      _reduceMotion = false;
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
      await prefs.setBool('isHighContrast', _isHighContrast);
      await prefs.setBool('isBoldText', _isBoldText);
      await prefs.setBool('isScreenReaderOptimized', _isScreenReaderOptimized);
      await prefs.setBool('reduceMotion', _reduceMotion);
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
  
  // Toggle high contrast
  void toggleHighContrast() {
    _isHighContrast = !_isHighContrast;
    _savePreferences();
    notifyListeners();
  }
  
  // Toggle bold text
  void toggleBoldText() {
    _isBoldText = !_isBoldText;
    _savePreferences();
    notifyListeners();
  }
  
  // Toggle screen reader optimization
  void toggleScreenReaderOptimized() {
    _isScreenReaderOptimized = !_isScreenReaderOptimized;
    _savePreferences();
    notifyListeners();
  }
  
  // Toggle reduce motion
  void toggleReduceMotion() {
    _reduceMotion = !_reduceMotion;
    _savePreferences();
    notifyListeners();
  }
  
  // Reset all settings to default
  void resetToDefaults() {
    _isDarkMode = false;
    _fontSize = 1.0;
    _isHighContrast = false;
    _isBoldText = false;
    _isScreenReaderOptimized = false;
    _reduceMotion = false;
    _savePreferences();
    notifyListeners();
  }
  
  // Get theme based on current settings
  ThemeData getTheme() {
    final baseTheme = _isDarkMode ? _darkTheme : _lightTheme;
    
    // Apply high contrast if enabled
    if (_isHighContrast) {
      final highContrastColorScheme = _isDarkMode 
        ? const ColorScheme.dark(
            primary: Colors.yellow,      // High visibility primary color
            onPrimary: Colors.black,     // Text on primary (for buttons)
            secondary: Colors.white,     // Highly visible secondary color
            onSecondary: Colors.black,   // Text on secondary
            surface: Colors.black,       // Very dark background
            onSurface: Colors.yellow,    // Text on surface with high contrast
            error: Colors.red,           // Keep error color visible
            onError: Colors.white,       // Text on error
          )
        : const ColorScheme.light(
            primary: Colors.black,      // Black text on light background
            onPrimary: Colors.white,    // Text on primary
            secondary: Colors.black,    // High visibility
            onSecondary: Colors.white,  // Text on secondary
            surface: Colors.white,      // Very light background
            onSurface: Colors.black,    // Text on surface with high contrast
            error: Colors.red,          // Keep error color visible
            onError: Colors.white,      // Text on error
          );
          
      return ThemeData(
        brightness: baseTheme.brightness,
        useMaterial3: true,
        colorScheme: highContrastColorScheme,
        textTheme: _getTextTheme(baseTheme.brightness),
        primaryTextTheme: _getTextTheme(baseTheme.brightness),
        scaffoldBackgroundColor: _isDarkMode ? Colors.black : Colors.white,
        cardTheme: CardTheme(
          color: _isDarkMode ? Colors.black : Colors.white,
          elevation: 8, // Increased elevation for better shadow contrast
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isDarkMode ? Colors.yellow : Colors.black,
              width: 2, // Thicker border for visibility
            ),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _isDarkMode ? Colors.yellow : Colors.black,
            foregroundColor: _isDarkMode ? Colors.black : Colors.white,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: _isDarkMode ? Colors.white : Colors.black,
                width: 1,
              ),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _isDarkMode ? Colors.yellow : Colors.black,
            side: BorderSide(
              color: _isDarkMode ? Colors.yellow : Colors.black,
              width: 2,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _isDarkMode ? Colors.yellow : Colors.black,
          ),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return _isDarkMode ? Colors.yellow : Colors.black;
            }
            return _isDarkMode ? Colors.grey : Colors.grey;
          }),
          trackColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return _isDarkMode ? Colors.yellow.withAlpha(128) : Colors.black.withAlpha(128);
            }
            return _isDarkMode ? Colors.grey.withAlpha(77) : Colors.grey.withAlpha(77);
          }),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return _isDarkMode ? Colors.yellow : Colors.black;
            }
            return Colors.transparent;
          }),
          checkColor: WidgetStateProperty.all(_isDarkMode ? Colors.black : Colors.white),
          side: BorderSide(
            color: _isDarkMode ? Colors.yellow : Colors.black,
            width: 2,
          ),
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) {
              return _isDarkMode ? Colors.yellow : Colors.black;
            }
            return _isDarkMode ? Colors.yellow.withAlpha(128) : Colors.black.withAlpha(128);
          }),
        ),
        dividerTheme: DividerThemeData(
          color: _isDarkMode ? Colors.yellow.withAlpha(128) : Colors.black.withAlpha(128),
          thickness: 2,
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: _isDarkMode ? Colors.black : Colors.white,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _isDarkMode ? Colors.yellow : Colors.black,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _isDarkMode ? Colors.yellow : Colors.black,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: _isDarkMode ? Colors.white : Colors.blue,
              width: 3,
            ),
          ),
          labelStyle: TextStyle(
            color: _isDarkMode ? Colors.yellow : Colors.black,
            fontWeight: _isBoldText ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: _isDarkMode ? Colors.black : Colors.white,
          foregroundColor: _isDarkMode ? Colors.yellow : Colors.black,
          elevation: 4,
          iconTheme: IconThemeData(
            color: _isDarkMode ? Colors.yellow : Colors.black,
          ),
          titleTextStyle: TextStyle(
            color: _isDarkMode ? Colors.yellow : Colors.black,
            fontSize: 20 * _fontSize,
            fontWeight: _isBoldText ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      );
    }
    
    // Apply regular theme with font size and bold text adjustments
    return baseTheme.copyWith(
      textTheme: _getTextTheme(baseTheme.brightness),
      primaryTextTheme: _getTextTheme(baseTheme.brightness),
      pageTransitionsTheme: _reduceMotion ? const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ) : null,
    );
  }
  
  // Create a text theme with the appropriate font size and weight
  TextTheme _getTextTheme(Brightness brightness) {
    // Define a font size for each text style based on our scaling factor
    final double scaleFactor = _fontSize;
    
    // Determine font weights based on bold text setting
    final FontWeight regularWeight = _isBoldText ? FontWeight.w500 : FontWeight.w400;
    final FontWeight mediumWeight = _isBoldText ? FontWeight.w700 : FontWeight.w500;
    final FontWeight lightWeight = _isBoldText ? FontWeight.w400 : FontWeight.w300;
    
    // Create a completely new text theme with explicit font sizes
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 96 * scaleFactor,
        fontWeight: lightWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : -1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 60 * scaleFactor,
        fontWeight: lightWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : -0.5,
      ),
      displaySmall: TextStyle(
        fontSize: 48 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0,
      ),
      headlineLarge: TextStyle(
        fontSize: 40 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.25,
      ),
      headlineMedium: TextStyle(
        fontSize: 34 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0,
      ),
      headlineSmall: TextStyle(
        fontSize: 24 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0,
      ),
      titleLarge: TextStyle(
        fontSize: 20 * scaleFactor,
        fontWeight: mediumWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.15,
      ),
      titleMedium: TextStyle(
        fontSize: 16 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.15,
      ),
      titleSmall: TextStyle(
        fontSize: 14 * scaleFactor,
        fontWeight: mediumWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.1,
      ),
      bodyLarge: TextStyle(
        fontSize: 16 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.5,
        height: _isScreenReaderOptimized ? 1.6 : 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.25,
        height: _isScreenReaderOptimized ? 1.6 : 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 0.4,
        height: _isScreenReaderOptimized ? 1.6 : 1.3,
      ),
      labelLarge: TextStyle(
        fontSize: 14 * scaleFactor,
        fontWeight: mediumWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 1.25,
      ),
      labelMedium: TextStyle(
        fontSize: 12 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white : Colors.black,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10 * scaleFactor,
        fontWeight: regularWeight,
        color: brightness == Brightness.dark ? Colors.white70 : Colors.black54,
        letterSpacing: _isScreenReaderOptimized ? 0.5 : 1.5,
      ),
    );
  }
  
  // Light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    fontFamily: 'Roboto',
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
    fontFamily: 'Roboto',
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