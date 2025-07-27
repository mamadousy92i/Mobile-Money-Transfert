import 'package:dio/dio.dart';
import 'token_service.dart';
import 'api/auth_api.dart';
import '../models/token.dart';

class JwtInterceptor extends Interceptor {
  final TokenService _tokenService;
  final Dio _dio;
  final String _baseUrl;
  bool _isRefreshing = false;

  JwtInterceptor(this._tokenService, this._dio, this._baseUrl);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Ne pas ajouter de token pour les endpoints d'authentification
    if (options.path.contains('login') || options.path.contains('register')) {
      return handler.next(options);
    }

    // Récupérer le token d'accès
    final accessToken = await _tokenService.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Si l'erreur est 401 (non autorisé), essayer de rafraîchir le token
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      try {
        _isRefreshing = true;
        final newTokens = await _refreshToken();
        
        if (newTokens != null) {
          // Mettre à jour les tokens
          await _tokenService.saveTokens(newTokens);
          
          // Refaire la requête originale avec le nouveau token
          final response = await _retryRequest(err.requestOptions, newTokens.accessToken);
          return handler.resolve(response);
        }
      } catch (e) {
        // En cas d'échec du rafraîchissement, déconnecter l'utilisateur
        await _tokenService.clearTokens();
      } finally {
        _isRefreshing = false;
      }
    }
    
    return handler.next(err);
  }

  // Méthode pour rafraîchir le token
  Future<TokenPair?> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      // Créer une nouvelle instance de Dio pour éviter une boucle infinie
      final refreshDio = Dio(BaseOptions(baseUrl: _baseUrl));
      final authApi = AuthApi(refreshDio);
      
      // Appeler l'API de rafraîchissement
      return await authApi.refreshToken({'refresh': refreshToken});
    } catch (e) {
      return null;
    }
  }

  // Méthode pour réessayer la requête avec le nouveau token
  Future<Response> _retryRequest(RequestOptions requestOptions, String accessToken) async {
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        'Authorization': 'Bearer $accessToken',
      },
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
}
