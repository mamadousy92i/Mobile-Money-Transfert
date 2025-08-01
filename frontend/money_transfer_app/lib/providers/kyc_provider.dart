// lib/providers/kyc_provider.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../services/kyc_service.dart';

class KycProvider with ChangeNotifier {
  final KycService _kycService;
  KycProvider(this._kycService);

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> submitKycDocument({
    required String documentType,
    required String documentNumber,
    required Uint8List frontImageBytes,
    required String frontImageName,
    Uint8List? backImageBytes,
    String? backImageName,
    required Uint8List selfieImageBytes,
    required String selfieImageName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _kycService.uploadDocument(
        documentType: documentType,
        documentNumber: documentNumber,
        frontImageBytes: frontImageBytes,
        frontImageName: frontImageName,
        backImageBytes: backImageBytes,
        backImageName: backImageName,
        selfieImageBytes: selfieImageBytes,
        selfieImageName: selfieImageName,
      );
      return true;
    } catch (e) {
      _errorMessage = "Échec de l'envoi du document. Veuillez réessayer.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}