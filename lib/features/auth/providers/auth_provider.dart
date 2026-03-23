import 'package:flutter/foundation.dart';

/// Authentication state management.
///
/// TODO: Wire up to Firebase Auth once google-services.json is configured.
/// For now, provides a local auth state so navigation and UI can be developed.
class AuthProvider extends ChangeNotifier {
  String? _userId;
  String? _email;
  String? _displayName;
  bool _isLoading = false;

  String? get userId => _userId;
  String? get email => _email;
  String? get displayName => _displayName;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _userId != null;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with Firebase Auth
      await Future.delayed(const Duration(milliseconds: 500));
      _userId = 'local-user';
      _email = email;
      _displayName = email.split('@').first;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(String email, String password, String name) async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Replace with Firebase Auth + Firestore user doc
      await Future.delayed(const Duration(milliseconds: 500));
      _userId = 'local-user';
      _email = email;
      _displayName = name;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _userId = null;
    _email = null;
    _displayName = null;
    notifyListeners();
  }
}
