// lib/services/payment_channel_service.dart
import '../models/payment_channel_model.dart';
import '../network/api_client.dart';

class PaymentChannelService {
  final ApiClient _apiClient;

  PaymentChannelService(this._apiClient);

  Future<List<PaymentChannel>> getChannels() async {
    try {
      // On reçoit la réponse paginée
      final paginatedResponse = await _apiClient.getPaymentChannels();
      // On retourne uniquement la liste des résultats
      return paginatedResponse.results;
    } catch (e) {
      rethrow;
    }
  }
}