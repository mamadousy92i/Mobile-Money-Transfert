class AuthConstants {
  // URL de base pour l'API d'authentification
  static const String baseUrl = 'https://553da07603d3.ngrok-free.app/api/auth/';
  
  // Endpoints d'authentification
  static const String login = 'login/';
  static const String register = 'register/';
  static const String logout = 'logout/';
  static const String refresh = 'refresh/';
  static const String profile = 'profile/';
  static const String changePassword = 'change-password/';
  
  // Clés pour le stockage local
  static const String userKey = 'user_data';
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  
  // Timeouts
  static const int connectTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;
}
