import '../models/send_money_request_model.dart';
import '../network/api_client.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final ApiClient _apiClient;

  TransactionService(this._apiClient);

  Future<List<Transaction>> getTransactions({String? status}) async {
    try {
      return await _apiClient.getTransactions(status: status);
    } catch (e) {
      rethrow;
    }
  }
  Future<void> sendMoney(SendMoneyRequest request) async {
    try {
      await _apiClient.sendMoney(request);
    } catch (e) {
      print('Erreur lors de lenvoie de largent: $e');
      rethrow;
    }
  }


}