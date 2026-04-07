class CalculatorUtils {
  CalculatorUtils._();

  static String formatNumber(double value) {
    if (value == value.truncateToDouble()) {
      String intStr = value.truncate().toString();
      if (intStr.length > 15) {
        return value.toStringAsExponential(6);
      }
      return _addThousandSeparators(intStr);
    } else {
      String str = value.toString();
      if (str.length > 15) {
        return value.toStringAsExponential(6);
      }
      List<String> parts = str.split('.');
      parts[0] = _addThousandSeparators(parts[0]);
      return parts.join('.');
    }
  }

  static String _addThousandSeparators(String numStr) {
    bool isNegative = numStr.startsWith('-');
    String digits = isNegative ? numStr.substring(1) : numStr;
    String result = '';
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        result += ',';
      }
      result += digits[i];
    }
    return isNegative ? '-$result' : result;
  }

  static double calculate(double first, double second, String operator) {
    switch (operator) {
      case '+':
        return first + second;
      case '-':
        return first - second;
      case '×':
        return first * second;
      case '÷':
        if (second == 0) throw Exception('Division by zero');
        return first / second;
      default:
        return second;
    }
  }

  static bool isOperator(String value) {
    return value == '+' || value == '-' || value == '×' || value == '÷';
  }
}
