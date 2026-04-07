import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/utils/calculator_utils.dart';

enum CalculatorState { idle, hasResult, error }

class HistoryEntry {
  final String expression;
  final String result;
  final DateTime timestamp;

  const HistoryEntry({
    required this.expression,
    required this.result,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory HistoryEntry.fromMap(Map<String, dynamic> map) {
    return HistoryEntry(
      expression: map['expression'] ?? '',
      result: map['result'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
    );
  }
}

class CalculatorProvider extends ChangeNotifier {
  String _display = '0';
  String _expression = '';
  double _firstOperand = 0;
  String _currentOperator = '';
  bool _shouldResetDisplay = false;
  bool _justCalculated = false;
  CalculatorState _state = CalculatorState.idle;
  List<HistoryEntry> _history = [];
  bool _isLoadingHistory = false;
  bool _showHistory = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get display => _display;
  String get expression => _expression;
  CalculatorState get state => _state;
  List<HistoryEntry> get history => List.unmodifiable(_history);
  bool get isLoadingHistory => _isLoadingHistory;
  bool get showHistory => _showHistory;

  void toggleHistory() {
    _showHistory = !_showHistory;
    if (_showHistory) {
      _loadHistory();
    }
    notifyListeners();
  }

  Future<void> _loadHistory() async {
    try {
      _isLoadingHistory = true;
      notifyListeners();

      final user = _auth.currentUser;
      if (user == null) {
        _isLoadingHistory = false;
        notifyListeners();
        return;
      }

      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calculation_history')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      _history = snapshot.docs.map((doc) {
        final data = doc.data();
        return HistoryEntry(
          expression: data['expression'] ?? '',
          result: data['result'] ?? '',
          timestamp: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> _saveToHistory(String expression, String result) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calculation_history')
          .add({
        'expression': expression,
        'result': result,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _history.insert(
        0,
        HistoryEntry(
          expression: expression,
          result: result,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      debugPrint('Error saving history: $e');
    }
  }

  void onButtonPressed(String value) {
    switch (value) {
      case 'AC':
        _clear();
        break;
      case '+/-':
        _toggleSign();
        break;
      case '%':
        _percentage();
        break;
      case '+':
      case '-':
      case '×':
      case '÷':
        _handleOperator(value);
        break;
      case '=':
        _calculate();
        break;
      case '.':
        _addDecimal();
        break;
      case '⌫':
        _backspace();
        break;
      default:
        _appendDigit(value);
    }
    notifyListeners();
  }

  void _clear() {
    _display = '0';
    _expression = '';
    _firstOperand = 0;
    _currentOperator = '';
    _shouldResetDisplay = false;
    _justCalculated = false;
    _state = CalculatorState.idle;
  }

  void _toggleSign() {
    if (_display == '0') return;
    try {
      double value = double.parse(_display.replaceAll(',', ''));
      value = -value;
      _display = CalculatorUtils.formatNumber(value);
      _state = CalculatorState.idle;
    } catch (e) {
      debugPrint('Toggle sign error: $e');
    }
  }

  void _percentage() {
    try {
      double value = double.parse(_display.replaceAll(',', ''));
      if (_currentOperator.isNotEmpty && !_shouldResetDisplay) {
        value = _firstOperand * (value / 100);
      } else {
        value = value / 100;
      }
      _display = CalculatorUtils.formatNumber(value);
      _state = CalculatorState.idle;
    } catch (e) {
      debugPrint('Percentage error: $e');
    }
  }

  void _handleOperator(String operator) {
    try {
      if (_currentOperator.isNotEmpty && !_shouldResetDisplay) {
        double second = double.parse(_display.replaceAll(',', ''));
        double result = CalculatorUtils.calculate(_firstOperand, second, _currentOperator);
        _display = CalculatorUtils.formatNumber(result);
        _firstOperand = result;
      } else {
        _firstOperand = double.parse(_display.replaceAll(',', ''));
      }
      _currentOperator = operator;
      _shouldResetDisplay = true;
      _justCalculated = false;
      _expression = '${CalculatorUtils.formatNumber(_firstOperand)} $operator';
      _state = CalculatorState.idle;
    } catch (e) {
      _state = CalculatorState.error;
      _display = 'Error';
    }
  }

  void _calculate() {
    if (_currentOperator.isEmpty) return;
    try {
      double second = double.parse(_display.replaceAll(',', ''));
      String fullExpression = '${CalculatorUtils.formatNumber(_firstOperand)} $_currentOperator ${CalculatorUtils.formatNumber(second)}';
      double result = CalculatorUtils.calculate(_firstOperand, second, _currentOperator);
      String resultStr = CalculatorUtils.formatNumber(result);
      _expression = '$fullExpression =';
      _display = resultStr;
      _currentOperator = '';
      _shouldResetDisplay = true;
      _justCalculated = true;
      _state = CalculatorState.hasResult;
      _saveToHistory(fullExpression, resultStr);
    } catch (e) {
      if (e.toString().contains('Division by zero')) {
        _display = 'Cannot ÷ 0';
      } else {
        _display = 'Error';
      }
      _state = CalculatorState.error;
      _expression = '';
      _currentOperator = '';
    }
  }

  void _appendDigit(String digit) {
    if (_state == CalculatorState.error) {
      _clear();
    }
    if (_shouldResetDisplay || _display == '0') {
      if (_shouldResetDisplay) {
        _display = digit;
        _shouldResetDisplay = false;
      } else {
        _display = digit;
      }
    } else {
      if (_display.replaceAll(',', '').replaceAll('-', '').replaceAll('.', '').length >= 12) return;
      _display = _display + digit;
    }
    if (_justCalculated) {
      _expression = '';
      _justCalculated = false;
    }
    _state = CalculatorState.idle;
  }

  void _addDecimal() {
    if (_state == CalculatorState.error) _clear();
    if (_shouldResetDisplay) {
      _display = '0.';
      _shouldResetDisplay = false;
      return;
    }
    if (!_display.contains('.')) {
      _display = '$_display.';
    }
  }

  void _backspace() {
    if (_state == CalculatorState.error) {
      _clear();
      return;
    }
    if (_justCalculated || _shouldResetDisplay) return;
    if (_display.length <= 1 || (_display.length == 2 && _display.startsWith('-'))) {
      _display = '0';
    } else {
      _display = _display.substring(0, _display.length - 1);
    }
  }

  void useHistoryEntry(String result) {
    _clear();
    _display = result;
    _showHistory = false;
    notifyListeners();
  }

  Future<void> clearHistory() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('calculation_history')
          .get();

      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      _history.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing history: $e');
    }
  }
}
