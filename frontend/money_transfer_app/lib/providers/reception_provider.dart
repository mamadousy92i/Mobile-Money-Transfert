import 'package:flutter/material.dart';
import '../models/reception_model.dart';
import '../services/reception_service.dart';

class ReceptionProvider with ChangeNotifier {
  final ReceptionService _receptionService;
  ReceptionProvider(this._receptionService);

  List<Reception> _receptions = [];
  bool _isLoading = false;

  List<Reception> get receptions => _receptions;
  bool get isLoading => _isLoading;

  String? _activeFilter;
  String? get activeFilter => _activeFilter;

  Future<void> fetchReceptions({String? status}) async {
    _isLoading = true;
    _activeFilter = status; // On mémorise le filtre actif pour l'UI
    notifyListeners();
    try {
      _receptions = await _receptionService.getReceptions(status: status);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> requestDigitalWithdrawal(int receptionId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _receptionService.requestDigitalWithdrawal(receptionId);
      // Si le retrait réussit, on rafraîchit la liste pour que la réception disparaisse
      await fetchReceptions();
      return true;
    } catch (e) {
      print("Erreur requestDigitalWithdrawal: $e");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}