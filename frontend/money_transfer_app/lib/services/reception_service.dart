import '../models/reception_model.dart';
import '../network/api_client.dart';

class ReceptionService {
  final ApiClient _apiClient;
  ReceptionService(this._apiClient);

  Future<List<Reception>> getReceptions({String? status}) async {
    try {
      final paginatedResponse = await _apiClient.getReceptions(status: status);
      return paginatedResponse.results;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestDigitalWithdrawal(int receptionId) async {
    try {
      await _apiClient.requestDigitalWithdrawal(receptionId);
    } catch (e) {
      rethrow;
    }
  }
}