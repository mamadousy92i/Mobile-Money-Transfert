import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'retrofit_client.dart';
import 'transaction_service.dart';
import '../models/responses/api_error_response.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late TransactionService _transactionService;
  final Logger _logger = Logger();

  TransactionService get transactionService => _transactionService;

  void init() {
    final retrofitClient = RetrofitClient();
    retrofitClient.init();
    _transactionService = TransactionService(retrofitClient.dio);
  }

  // Méthode utilitaire pour gérer les erreurs
  ApiErrorResponse handleError(DioException error) {
    _logger.e('API Error: ${error.message}');

    if (error.response != null) {
      final responseData = error.response!.data;

      if (responseData is Map<String, dynamic>) {
        return ApiErrorResponse.fromJson(responseData);
      }
    }

    // Erreur par défaut
    return ApiErrorResponse(
      error: 'Erreur de connexion',
      message: _getErrorMessage(error.type),
    );
  }

  String _getErrorMessage(DioExceptionType type) {
    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
      case DioExceptionType.badResponse:
        return 'Erreur du serveur. Veuillez réessayer plus tard.';
      case DioExceptionType.cancel:
        return 'Requête annulée.';
      case DioExceptionType.unknown:
      default:
        return 'Erreur de connexion. Vérifiez votre connexion internet.';
    }
  }

  // Méthode pour tester la connexion
  Future<bool> testConnection() async {
    try {
      await _transactionService.getCanaux();
      return true;
    } catch (e) {
      _logger.e('Connection test failed: $e');
      return false;
    }
  }

  // Méthode pour changer l'URL ngrok
  void updateNgrokUrl(String ngrokUrl) {
    final fullUrl = '$ngrokUrl/api/v1/transactions';
    RetrofitClient().updateBaseUrl(fullUrl);
    _logger.i('🔄 Ngrok URL updated to: $fullUrl');
  }

  // Méthodes d'authentification (pour plus tard avec Dev 1)
  void setAuthToken(String token) {
    RetrofitClient().setAuthToken(token);
  }

  void clearAuthToken() {
    RetrofitClient().clearAuthToken();
  }
}
