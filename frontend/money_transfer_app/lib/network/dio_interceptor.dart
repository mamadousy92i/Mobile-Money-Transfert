// lib/network/dio_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DioInterceptor extends Interceptor {
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {

    // On définit les routes qui n'ont pas besoin de token
    final noTokenRoutes = [
      '/auth/login/',
      '/auth/register/',
    ];

    // Si la route actuelle N'EST PAS dans la liste, on ajoute le token
    if (!noTokenRoutes.contains(options.path)) {
      final token = await storage.read(key: 'access_token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        print('✅ Token ajouté à la requête pour : ${options.path}');
      } else {
        print('⚠️ Pas de token trouvé pour : ${options.path}');
      }
    }

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('❌ ERREUR DIO: ${err.requestOptions.path} - ${err.response?.data ?? err.message}');
    super.onError(err, handler);
  }
}