import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/auth_request.dart';
import '../models/token.dart';
import 'api/auth_api.dart';
import 'token_service.dart';
import 'auth_constants.dart';
import 'jwt_interceptor.dart';

class AuthService {
  late AuthApi _authApi;
  late TokenService _tokenService;
  late Dio _dio;

  // Constructeur
  AuthService() {
    _initService();
  }

  // Initialisation du service
  void _initService() {
    _tokenService = TokenService();
    
    // Configuration de Dio
    _dio = Dio(BaseOptions(
      baseUrl: AuthConstants.baseUrl,
      connectTimeout: Duration(milliseconds: AuthConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: AuthConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Ajout des intercepteurs
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    _dio.interceptors.add(JwtInterceptor(_tokenService, _dio, AuthConstants.baseUrl));

    // Création de l'API
    _authApi = AuthApi(_dio);
  }

  // Connexion utilisateur
  Future<User> login(LoginRequest request) async {
    try {
      // Appel à l'API de connexion
      final tokenPair = await _authApi.login(request);
      
      // Sauvegarde des tokens
      await _tokenService.saveTokens(tokenPair);
      
      // Récupération du profil utilisateur
      final user = await _authApi.getUserProfile();
      
      // Ajout des propriétés supplémentaires
      return User(
        id: user.id,
        firstName: user.firstName,
        lastName: user.lastName,
        phone: user.phone,
        email: user.email,
        kycStatus: user.kycStatus,
        verificationLevel: user.verificationLevel,
        isAuthenticated: true,
        memberSince: user.memberSince,
      );
    } on DioException catch (e) {
      // Gestion des erreurs de l'API
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          final errorMessage = errorData['detail'] ?? 'Erreur d\'authentification';
          throw Exception(errorMessage);
        }
      }
      throw Exception('Erreur de connexion au serveur: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Inscription utilisateur
  Future<User> register(RegisterRequest request) async {
    try {
      // Ajout de la confirmation de mot de passe
      final registerRequest = RegisterRequest(
        firstName: request.firstName,
        lastName: request.lastName,
        phone_number: request.phone_number,
        email: request.email,
        password: request.password,
        passwordConfirm: request.password, // Utilisation du même mot de passe
      );
      
      // Appel à l'API d'inscription
      final user = await _authApi.register(registerRequest);
      
      // Connexion automatique après inscription
      final loginRequest = LoginRequest(
        phone: request.phone_number,
        password: request.password,
      );
      
      return await login(loginRequest);
    } on DioException catch (e) {
      // Gestion des erreurs de l'API
      if (e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          // Extraction du premier message d'erreur
          String errorMessage = 'Erreur d\'inscription';
          errorData.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessage = value.first.toString();
              return;
            }
          });
          throw Exception(errorMessage);
        }
      }
      throw Exception('Erreur de connexion au serveur: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }
  
  // Déconnexion
  Future<void> logout() async {
    try {
      final refreshToken = await _tokenService.getRefreshToken();
      if (refreshToken != null) {
        await _authApi.logout({'refresh': refreshToken});
      }
    } catch (e) {
      // Ignorer les erreurs lors de la déconnexion
    } finally {
      // Toujours effacer les tokens locaux
      await _tokenService.clearTokens();
    }
  }
  
  // Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    return await _tokenService.hasTokens();
  }
  
  // Récupérer le profil utilisateur
  Future<User?> getUserProfile() async {
    try {
      if (await isAuthenticated()) {
        final user = await _authApi.getUserProfile();
        return User(
          id: user.id,
          firstName: user.firstName,
          lastName: user.lastName,
          phone: user.phone,
          email: user.email,
          kycStatus: user.kycStatus,
          verificationLevel: user.verificationLevel,
          isAuthenticated: true,
          memberSince: user.memberSince,
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
