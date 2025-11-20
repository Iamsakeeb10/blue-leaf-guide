import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  User? _currentUser;
  Map<String, dynamic>? _userData;

  // Temp storage for signup flow
  String? _pendingEmail;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  Map<String, dynamic>? get userData => _userData;
  String? get pendingEmail => _pendingEmail;

  AuthProvider() {
    _currentUser = _authService.currentUser;
    if (_currentUser != null) {
      _loadUserData();
    }
  }

  // Load user data from Firestore
  Future<void> _loadUserData() async {
    if (_currentUser != null) {
      _userData = await _authService.getUserData(_currentUser!.uid);
      notifyListeners();
    }
  }

  // Send OTP for signup
  Future<bool> sendSignUpOTP(String email) async {
    _isLoading = true;
    _errorMessage = null;
    _pendingEmail = email;
    notifyListeners();

    try {
      final result = await _authService.sendOTP(email, type: 'signup');
      _isLoading = false;

      if (!result) {
        _errorMessage = 'Failed to send OTP. Please try again.';
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    if (_pendingEmail == null) {
      _errorMessage = 'Email not found. Please start again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.verifyOTP(_pendingEmail!, otp);
      _isLoading = false;

      if (!result) {
        _errorMessage = 'Invalid or expired OTP. Please try again.';
      }

      notifyListeners();
      return result;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Complete signup with user details
  Future<bool> completeSignUp({
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    if (_pendingEmail == null) {
      _errorMessage = 'Email not found. Please start again.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.createAccount(
        email: _pendingEmail!,
        firstName: firstName,
        lastName: lastName,
        password: password,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        await _loadUserData();
        _pendingEmail = null; // Clear pending email
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.signIn(
        email: email,
        password: password,
      );

      _isLoading = false;

      if (result['success']) {
        _currentUser = result['user'];
        await _loadUserData();
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'An error occurred. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _currentUser = null;
    _userData = null;
    _pendingEmail = null;
    notifyListeners();
  }

  // Check if logged in
  Future<bool> checkLoginStatus() async {
    return await _authService.isLoggedIn();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
