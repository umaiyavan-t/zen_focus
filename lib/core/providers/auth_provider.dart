import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUser();
  }

  void _loadUser() {
    _currentUser = _authService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final success = await _authService.login(username, password);
    if (success) {
      _currentUser = _authService.getCurrentUser();
    }

    _isLoading = false;
    notifyListeners();
    return success;
  }

  void logout() {
    _authService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
