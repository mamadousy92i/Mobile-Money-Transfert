import 'api_service.dart';
import 'package:logger/logger.dart';

class AppInitializer {
  static final Logger _logger = Logger();

  static Future<void> initialize() async {
    _logger.i('🚀 Initializing app services...');

    // Initialiser les services API
    ApiService().init();

    _logger.i('✅ App services initialized');
  }

  static Future<bool> testApiConnection() async {
    _logger.i('🔍 Testing API connection...');

    final isConnected = await ApiService().testConnection();

    if (isConnected) {
      _logger.i('✅ API connection successful');
    } else {
      _logger.w('❌ API connection failed');
    }

    return isConnected;
  }

  static void updateNgrokUrl(String ngrokUrl) {
    _logger.i('🔄 Updating ngrok URL to: $ngrokUrl');
    ApiService().updateNgrokUrl(ngrokUrl);
  }
}