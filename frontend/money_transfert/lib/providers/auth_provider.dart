import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_request.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  // Initialisation du provider
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Vérifier si l'utilisateur est déjà authentifié via les tokens JWT
      if (await _authService.isAuthenticated()) {
        // Récupérer le profil utilisateur depuis l'API
        _currentUser = await _authService.getUserProfile();
      }
    } catch (e) {
      _error = 'Erreur lors de l\'initialisation: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connexion
  Future<bool> login(String phone, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(
        phone: phone,
        password: password,
      );

      _currentUser = await _authService.login(loginRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Inscription
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String phone_number,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final registerRequest = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        phone_number: phone_number,
        email: email,
        password: password,
        passwordConfirm: password, // Ajout du champ de confirmation
      );

      _currentUser = await _authService.register(registerRequest);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // Déconnexion
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Réinitialiser les erreurs
  void resetError() {
    _error = null;
    notifyListeners();
  }
}
