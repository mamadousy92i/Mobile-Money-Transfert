// lib/providers/withdrawal_provider.dart
import 'package:flutter/material.dart';
import '../models/withdrawal_request_model.dart';
import '../models/withdrawal_response_model.dart';
import '../services/withdrawal_service.dart';

class WithdrawalProvider with ChangeNotifier {
  final WithdrawalService _withdrawalService;
  WithdrawalProvider(this._withdrawalService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<WithdrawalResponse> createWithdrawal(WithdrawalRequest request) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await _withdrawalService.requestWithdrawal(request);
      if (response == null) {
        throw Exception("La réponse de l'API est nulle.");
      }
      print("Réponse WithdrawalResponse: $response");
      return response;
    } catch (e) {
      print("Erreur createWithdrawal: $e");
      throw Exception("Échec de la création du retrait: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}