// lib/providers/international_provider.dart
import 'package:flutter/material.dart';
import 'package:money_transfer_app/providers/transaction_provider.dart';
import '../models/country_model.dart';
import '../models/fee_request_model.dart';
import '../models/fee_response_model.dart';
import '../models/international_send_request_model.dart';
import '../models/payment_service_model.dart';
import '../services/international_service.dart';

class InternationalProvider with ChangeNotifier {
  final InternationalService _internationalService;
  List<Country> _countries = [];
  List<PaymentService> _services = []; // <-- Ajouter
  FeeResponse? _feeResponse; // <-- Ajouter pour stocker le devis


  bool _isLoading = false;

  InternationalProvider(this._internationalService);

  List<Country> get countries => _countries;
  List<PaymentService> get services => _services; // <-- Ajouter
  FeeResponse? get feeResponse => _feeResponse; // <-- Ajouter le getter




  bool get isLoading => _isLoading;

  Future<void> fetchCountries({String? userCountryCode}) async {
    _isLoading = true;
    notifyListeners();
    try {
      // On récupère la liste complète depuis le service
      final allCountries = await _internationalService.getAvailableCountries();

      if (userCountryCode != null) {
        // On filtre la liste pour exclure le pays de l'utilisateur
        _countries = allCountries
            .where((country) => country.code != userCountryCode)
            .toList();
      } else {
        // Comportement par défaut si aucun code pays n'est fourni
        _countries = allCountries;
      }

    } catch (e) {
      print("Erreur fetchCountries: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<void> fetchServicesForCountry(String countryCode) async {
    _isLoading = true;
    _services = []; // Vider la liste précédente
    notifyListeners();
    try {
      _services = await _internationalService.getServicesForCountry(countryCode);
    } catch (e) {
      print("Erreur fetchServicesForCountry: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> calculateFees(FeeRequest request) async {
    _isLoading = true;
    _feeResponse = null;
    notifyListeners();
    try {
      _feeResponse = await _internationalService.calculateFees(request);
      _isLoading = false;
      notifyListeners();
      return true; // Succès
    } catch (e) {
      print("Erreur calculateFees: $e");
      _isLoading = false;
      notifyListeners();
      return false; // Échec
    }
  }
  Future<bool> sendMoneyInternational(
      InternationalSendRequest request,
      TransactionProvider transactionProvider, // <-- On le passe en paramètre
      ) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _internationalService.sendMoneyInternational(request);

      // Si le succès, on rafraîchit la liste des transactions sur l'écran d'accueil !
      await transactionProvider.fetchTransactions();

      _isLoading = false;
      notifyListeners();
      return true; // Succès
    } catch (e) {
      print("Erreur sendMoneyInternational: $e");
      _isLoading = false;
      notifyListeners();
      return false; // Échec
    }
  }
}