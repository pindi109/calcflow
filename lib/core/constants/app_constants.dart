import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'CalcFlow';
  static const String appVersion = '1.0.0';

  // Colors
  static const Color backgroundColor = Color(0xFF0A0A0F);
  static const Color surfaceColor = Color(0xFF18181B);
  static const Color primaryColor = Color(0xFF7C3AED);
  static const Color primaryLightColor = Color(0xFF8B5CF6);
  static const Color gradientStart = Color(0xFF7C3AED);
  static const Color gradientEnd = Color(0xFF3B82F6);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color borderColor = Color(0xFF27272A);

  // Button Colors
  static const Color numberButtonColor = Color(0xFF1C1C21);
  static const Color operatorButtonColor = Color(0xFF2D1B69);
  static const Color functionButtonColor = Color(0xFF1A1A2E);
  static const Color equalsButtonColor = Color(0xFF7C3AED);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF6D28D9)],
  );

  static const LinearGradient surfaceGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF18181B), Color(0xFF111115)],
  );

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusCircle = 100.0;

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String historyCollection = 'calculation_history';

  // Calculator Operations
  static const String opAdd = '+';
  static const String opSubtract = '-';
  static const String opMultiply = '×';
  static const String opDivide = '÷';
  static const String opPercent = '%';
  static const String opDecimal = '.';
  static const String opEquals = '=';
  static const String opClear = 'AC';
  static const String opToggleSign = '+/-';
  static const String opBackspace = '⌫';
}
