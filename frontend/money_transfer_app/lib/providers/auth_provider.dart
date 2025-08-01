import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile_model.dart';
import '../services/auth_service.dart';
import '../models/auth_model.dart';
import '../models/login_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  String? _errorMessage;
  UserProfile? _userProfile;

  AuthProvider(this._authService);

  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile; // <-- Getter pour le profil


  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  Future<void> fetchUserProfile({bool forceRefresh = false}) async {
    try {
      // On récupère le profil s'il n'est pas déjà chargé OU si on force le rafraîchissement
      if (_userProfile == null || forceRefresh) {
        _userProfile = await _authService.getProfile();
        notifyListeners();
      }
    } catch (e) {
      print("Erreur lors de la récupération du profil: $e");
    }
  }
  Future<bool> get isAuthenticated async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }

  Future register(User user) async {
    final response = await _authService.register(user);
    setErrorMessage(response.error);
  }

  Future<bool> login(LoginUser user) async {
    final response = await _authService.login(user);
    setErrorMessage(response.error);

    if (response.access != null) {
      await fetchUserProfile(); // <-- Appeler la récupération du profil ici
      return true;
    }
    return false;
  }

  Future logout() async {
    await _authService.logout();
    _userProfile = null; // <-- Vider le profil
    clearError();
    await _storage.deleteAll(); // Nettoyage après logout

  }

  Future<bool> updateUserProfile(Map<String, dynamic> data) async {
    try {
      // On appelle le service pour mettre à jour les données
      final updatedProfile = await _authService.updateProfile(data);
      // On met à jour le profil local avec les nouvelles informations
      _userProfile = updatedProfile;
      // On notifie les widgets qui écoutent pour qu'ils se reconstruisent
      notifyListeners();
      return true;
    } catch (e) {
      print("Erreur lors de la mise à jour du profil: $e");
      // On pourrait définir un message d'erreur ici si nécessaire
      return false;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _authService.changePassword(oldPassword, newPassword);
      return true;
    } catch (e) {
      // Ici, on pourrait extraire le message d'erreur de la réponse de l'API
      // pour l'afficher à l'utilisateur, par exemple "Ancien mot de passe incorrect".
      print("Erreur Provider changePassword: $e");
      setErrorMessage("Échec du changement de mot de passe. Vérifiez votre ancien mot de passe.");
      return false;
    }
  }
}
