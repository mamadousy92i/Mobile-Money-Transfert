// lib/services/kyc_service.dart
import 'package:dio/dio.dart';
import 'dart:typed_data';
import '../network/api_client.dart';

class KycService {
  final ApiClient _apiClient;

  KycService(this._apiClient);

  Future<void> uploadDocument({
    required String documentType,
    required String documentNumber,
    required Uint8List frontImageBytes,
    required String frontImageName,
    Uint8List? backImageBytes, // Le verso est optionnel
    String? backImageName,    // Le nom du fichier verso aussi
    required Uint8List selfieImageBytes,
    required String selfieImageName,
  }) async {
    try {
      final formData = FormData.fromMap({
        'document_type': documentType,
        'document_number': documentNumber,
        // Image Recto (obligatoire)
        'document_front_image': MultipartFile.fromBytes(
          frontImageBytes,
          filename: frontImageName,
        ),
        // Image Selfie (obligatoire)
        'selfie_image': MultipartFile.fromBytes(
          selfieImageBytes,
          filename: selfieImageName,
        ),
      });

      // On ajoute l'image Verso seulement si elle a été fournie
      if (backImageBytes != null && backImageName != null) {
        formData.files.add(MapEntry(
          'document_back_image',
          MultipartFile.fromBytes(
            backImageBytes,
            filename: backImageName,
          ),
        ));
      }

      await _apiClient.uploadKycDocument(formData);

    } catch (e) {
      print('Erreur dans KycService: $e');
      rethrow;
    }
  }
}