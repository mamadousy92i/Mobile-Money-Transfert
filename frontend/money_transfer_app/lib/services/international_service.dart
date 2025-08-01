// lib/services/international_service.dart
import '../models/country_model.dart';
import '../models/country_response_model.dart'; // On peut retirer cet import si on veut
import '../models/fee_request_model.dart';
import '../models/fee_response_model.dart';
import '../models/international_send_request_model.dart';
import '../models/payment_service_model.dart';
import '../network/api_client.dart';

class InternationalService {
  final ApiClient _apiClient;

  InternationalService(this._apiClient);

  Future<List<Country>> getAvailableCountries() async {
    try {
      final response = await _apiClient.getAvailableCountries();
      final countries = response.pays;

      // ----- AJOUTER CE BLOC DE DÉBOGAGE -----
      print('--- VÉRIFICATION DES PRÉFIXES DANS LE SERVICE ---');
      for (var country in countries) {
        print('Pays: ${country.nom}, Préfixe lu: ${country.prefixeTel}');
      }
      print('--------------------------------------------------');
      // ---------------------------------------------

      return countries;
    } catch (e) {
      print('ERREUR DANS LE SERVICE getAvailableCountries: $e'); // Utile aussi
      rethrow;
    }
  }

  Future<List<PaymentService>> getServicesForCountry(String countryCode) async {
    try {
      // Reçoit directement l'objet ServiceResponse bien typé
      final response = await _apiClient.getServicesForCountry(countryCode);
      // Retourne la liste de services qu'il contient
      return response.services;
    } catch (e) {
      rethrow;
    }
  }


  Future<FeeResponse> calculateFees(FeeRequest request) async {
    try {
      // Reçoit l'objet "enveloppe"
      final wrapper = await _apiClient.calculateFees(request);
      // Retourne l'objet "calculs" qui est à l'intérieur
      return wrapper.calculs;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendMoneyInternational(InternationalSendRequest request) async {
    try {
      await _apiClient.sendMoneyInternational(request);
    } catch (e) {
      rethrow;
    }
  }
}