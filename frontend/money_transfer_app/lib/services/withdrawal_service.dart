// lib/services/withdrawal_service.dart
import '../models/withdrawal_request_model.dart';
import '../models/withdrawal_response_model.dart';
import '../network/api_client.dart';

class WithdrawalService {
  final ApiClient _apiClient;
  WithdrawalService(this._apiClient);

  Future<WithdrawalResponse> requestWithdrawal(WithdrawalRequest request) async {
    try {
      print("Envoi de la requête WithdrawalRequest: ${request.toJson()}");
      final response = await _apiClient.requestWithdrawal(request);
      print("Réponse WithdrawalResponse: $response");
      return response;
    } catch (e) {
      print("Erreur dans requestWithdrawal: $e");
      rethrow;
    }
  }
}