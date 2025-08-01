import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user_profile_model.dart';
import '../network/api_client.dart';
import '../models/auth_model.dart';
import '../models/login_model.dart';

class AuthService {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._apiClient);

  Future<AuthResponse> register(User user) async {
    print('Sending register data: ${user.toJson()}');
    try {
      final response = await _apiClient.register(user);
      if (response.access != null) {
        await _storage.write(key: 'access_token', value: response.access);
        await _storage.write(key: 'refresh_token', value: response.refresh);
      }
      return response;
    } catch (e) {
      if (e is DioException) {
        print('Error response: ${e.response?.data}');
        return AuthResponse(error: e.response?.data['detail'] ?? e.message);
      }
      return AuthResponse(error: e.toString());
    }
  }

  Future<AuthResponse> login(LoginUser user)  async {
    print('Sending login data: ${user.toJson()}');
    try {
      final response = await _apiClient.login(user);
      if (response.access != null) {
        await _storage.write(key: 'access_token', value: response.access);
        await _storage.write(key: 'refresh_token', value: response.refresh);
      }
      return response;
    } catch (e) {
      if (e is DioException) {
        print('Error response: ${e.response?.data}');
        return AuthResponse(error: e.response?.data['detail'] ?? e.message);
      }
      return AuthResponse(error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
  Future<UserProfile> getProfile() async {
    try {
      return await _apiClient.getProfile();
    } catch (e) {
      print('Erreur service getProfile: $e');
      rethrow;
    }
  }

  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    try {
      return await _apiClient.updateProfile(data);
    } catch (e) {
      print('Erreur service updateProfile: $e');
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final Map<String, String> data = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
      await _apiClient.changePassword(data);
    } catch (e) {
      print('Erreur service changePassword: $e');
      // On relance l'erreur pour que le Provider puisse la gérer
      rethrow;
    }
  }

}