
class ApiConstants {
  // 🌐 REMPLACE PAR TON URL NGROK !
  static const String baseUrl = 'https://b27c-154-73-174-41.ngrok-free.app/api/v1/transactions';

  // Endpoints
  static const String transactions = '/transactions/';
  static const String sendMoney = '/send-money/';
  static const String canaux = '/canaux/';
  static const String beneficiaires = '/beneficiaires/';
  static const String exchangeRates = '/exchange-rates/';
  static const String statistics = '/transactions/statistics/';
  static const String search = '/search/';
  static const String transactionByCode = '/code/{code}/';
  static const String transactionStatus = '/status/{code}/';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeouts
  static const int connectTimeout = 30000; // 30 secondes
  static const int receiveTimeout = 30000;
}