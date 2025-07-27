import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'api_constants.dart';

class RetrofitClient {
  static final RetrofitClient _instance = RetrofitClient._internal();
  factory RetrofitClient() => _instance;
  RetrofitClient._internal();

  late Dio _dio;
  final Logger _logger = Logger();

  Dio get dio => _dio;

  void init() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConstants.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConstants.receiveTimeout),
      headers: ApiConstants.headers,
    ));

    // Intercepteurs pour logging et gestion d'erreurs
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => _logger.d(object),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i(' Request: ${options.method} ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i(' Response: ${response.statusCode} ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e(' Error: ${error.response?.statusCode} ${error.requestOptions.path}');
        _logger.e('Error message: ${error.message}');
        handler.next(error);
      },
    ));
  }

  // Méthode pour changer l'URL de base (utile pour ngrok)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    _logger.i(' Base URL updated to: $newBaseUrl');
  }

  // Méthode pour ajouter des headers d'authentification (pour plus tard)
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    _logger.i(' Auth token set');
  }

  // Méthode pour supprimer l'authentification
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    _logger.i(' Auth token cleared');
  }
}