import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAuthenticating = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticating => _isAuthenticating;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  void _initializeAuth() {
    _authService.authStateChanges.listen(
      (User? user) {
        _user = user;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to initialize authentication.';
        notifyListeners();
      },
    );
  }

  void _setAuthenticating(bool value) {
    _isAuthenticating = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _clearError();
      _setAuthenticating(true);
      await _authService.signInWithEmail(email, password);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setAuthenticating(false);
    }
  }

  Future<bool> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      _clearError();
      _setAuthenticating(true);
      await _authService.registerWithEmail(email, password, displayName);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setAuthenticating(false);
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _clearError();
      _setAuthenticating(true);
      final result = await _authService.signInWithGoogle();
      return result != null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    } finally {
      _setAuthenticating(false);
    }
  }

  Future<void> signOut() async {
    try {
      _clearError();
      _setAuthenticating(true);
      await _authService.signOut();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    } finally {
      _setAuthenticating(false);
    }
  }
}
