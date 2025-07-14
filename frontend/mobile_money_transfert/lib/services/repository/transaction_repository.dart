import '../transaction_service.dart';
import '../api_service.dart';
import '../../models/transaction.dart';
import '../../models/canal_paiement.dart';
import '../../models/beneficiaire.dart';
import '../../models/responses/send_money_response.dart';
import '../../models/responses/transaction_stats_response.dart';
import '../../models/responses/exchange_rate_response.dart';
import '../../models/responses/transaction_status_response.dart';
import '../../models/responses/search_response.dart';
import '../../models/responses/api_error_response.dart';
import 'package:dio/dio.dart';

class TransactionRepository {
  final TransactionService _service = ApiService().transactionService;

  // 🚀 ENVOI D'ARGENT (méthode principale)
  Future<Result<SendMoneyResponse>> sendMoney({
    required String beneficiairePhone,
    required double montant,
    required String canalPaiementId,
    String deviseEnvoi = 'XOF',
    String deviseReception = 'XOF',
  }) async {
    try {
      final request = SendMoneyRequest(
        beneficiairePhone: beneficiairePhone,
        montant: montant,
        canalPaiement: canalPaiementId,
        deviseEnvoi: deviseEnvoi,
        deviseReception: deviseReception,
      );

      final response = await _service.sendMoney(request);
      return Result.success(response);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // 📋 TRANSACTIONS
  Future<Result<List<Transaction>>> getTransactions({String? status}) async {
    try {
      final transactions = await _service.getTransactions(status: status);
      return Result.success(transactions);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  Future<Result<Transaction>> getTransactionById(String id) async {
    try {
      final transaction = await _service.getTransactionById(id);
      return Result.success(transaction);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  Future<Result<Transaction>> updateTransactionStatus(String id, String status) async {
    try {
      final transaction = await _service.updateTransactionStatus(
          id,
          {'statusTransaction': status}
      );
      return Result.success(transaction);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // 💳 CANAUX DE PAIEMENT
  Future<Result<List<CanalPaiement>>> getCanaux() async {
    try {
      final canaux = await _service.getCanaux();
      return Result.success(canaux);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  Future<Result<List<CanalPaiement>>> getCanauxByCountry(String country) async {
    try {
      final canaux = await _service.getCanauxByCountry(country);
      return Result.success(canaux);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // 👥 BÉNÉFICIAIRES
  Future<Result<List<Beneficiaire>>> getBeneficiaires({String? search}) async {
    try {
      final beneficiaires = await _service.getBeneficiaires(search: search);
      return Result.success(beneficiaires);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  Future<Result<Beneficiaire>> createBeneficiaire({
    required String firstName,
    required String lastName,
    required String phone,
  }) async {
    try {
      final data = {
        'first_name': firstName,
        'last_name': lastName,
        'phone': phone,
      };
      final beneficiaire = await _service.createBeneficiaire(data);
      return Result.success(beneficiaire);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // 📊 STATISTIQUES
  Future<Result<TransactionStatsResponse>> getStatistics() async {
    try {
      final stats = await _service.getStatistics();
      return Result.success(stats);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // 💱 TAUX DE CHANGE
  Future<Result<ExchangeRateMainResponse>> getExchangeRates() async {
    try {
      final rates = await _service.getExchangeRates();
      return Result.success(rates);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  Future<Result<ExchangeRateSpecificResponse>> getSpecificExchangeRate(String currency) async {
    try {
      final rate = await _service.getSpecificExchangeRate(currency);
      return Result.success(rate);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // 🔍 RECHERCHE & UTILITAIRES
  Future<Result<Transaction>> getTransactionByCode(String code) async {
    try {
      final transaction = await _service.getTransactionByCode(code);
      return Result.success(transaction);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  Future<Result<TransactionStatusResponse>> getTransactionStatus(String code) async {
    try {
      final status = await _service.getTransactionStatus(code);
      return Result.success(status);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }

  // CORRECTION: Utiliser SearchResponse au lieu de Map<String, dynamic>
  Future<Result<SearchResponse>> searchTransactions(String query) async {
    try {
      final results = await _service.searchTransactions(query);
      return Result.success(results);
    } on DioException catch (e) {
      final error = ApiService().handleError(e);
      return Result.error(error);
    }
  }
}

// Classe utilitaire pour gérer les résultats
class Result<T> {
  final T? data;
  final ApiErrorResponse? error;
  final bool isSuccess;

  Result.success(this.data) : error = null, isSuccess = true;
  Result.error(this.error) : data = null, isSuccess = false;

  // Méthodes utilitaires
  bool get isError => !isSuccess;
  String get errorMessage => error?.displayMessage ?? 'Erreur inconnue';
}