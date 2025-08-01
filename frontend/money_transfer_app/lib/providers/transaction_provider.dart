import 'package:flutter/material.dart';
import '../models/send_money_request_model.dart';
import '../models/transaction_model.dart';
import '../services/transaction_service.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionService _transactionService;

  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  String? _activeFilter;
  String? get activeFilter => _activeFilter;



  TransactionProvider(this._transactionService);

  // Getters
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;




  // Méthode pour récupérer les transactions
  Future<void> fetchTransactions({String? status}) async { // Accepte un statut
    _isLoading = true;
    _activeFilter = status; // Mémorise le filtre actif
    notifyListeners();

    try {
      _transactions = await _transactionService.getTransactions(status: status);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMoney(SendMoneyRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // NOTE: Pour le moment, on ne gère pas la réponse, mais on pourrait la récupérer
      await _transactionService.sendMoney(request);

      // Si l'envoi réussit, on rafraîchit la liste des transactions !
      await fetchTransactions();

      _isLoading = false;
      notifyListeners();
      return true; // Succès
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Échec
    }
  }

}