import 'dart:io';

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/agent_model.dart';
import '../models/auth_model.dart';
import '../models/country_response_model.dart';
import '../models/fee_calculation_wrapper_model.dart';
import '../models/international_send_request_model.dart';
import '../models/login_model.dart';
// Importer les futurs modèles
import '../models/notification_model.dart';
import '../models/paginated_response.dart';
import '../models/reception_model.dart';
import '../models/send_money_request_model.dart';
import '../models/service_response_model.dart';
import '../models/transaction_model.dart';
import '../models/beneficiary_model.dart';
import '../models/payment_channel_model.dart';
import '../models/user_profile_model.dart';
import '../models/fee_request_model.dart';
import '../models/fee_response_model.dart';
import '../models/withdrawal_request_model.dart';
import '../models/withdrawal_response_model.dart';
part 'api_client.g.dart';

@RestApi(baseUrl: "https://141456db6fcc.ngrok-free.app/api/")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // --- Authentification (existant) ---
  @POST("/auth/register/")
  Future<AuthResponse> register(@Body() User user);

  @POST("/auth/login/")
  Future<AuthResponse> login(@Body() LoginUser user);

  // --- Transactions ---
  // Endpoint: GET /api/v1/transactions/transactions/
  @GET("/v1/transactions/transactions/")
  Future<List<Transaction>> getTransactions({@Query("status") String? status});

  // --- Bénéficiaires ---
  // Endpoint: GET /api/v1/transactions/beneficiaires/
  @GET("/v1/transactions/beneficiaires/")
  Future<List<Beneficiary>> getBeneficiaries();

  // --- Canaux de paiement ---
  // Endpoint: GET /api/v1/transactions/canaux/
  @GET("/v1/transactions/canaux/")
  Future<PaginatedResponse<PaymentChannel>> getPaymentChannels();


  // Endpoint: GET /api/auth/profile/
  @GET("/auth/profile/")
  Future<UserProfile> getProfile(); // <-- Ajouter cette ligne

  @POST("/v1/transactions/send-money/")
  Future<void> sendMoney(@Body() SendMoneyRequest request);

  // Endpoint: GET /api/v1/transactions/international/pays/
  @GET("/v1/transactions/international/pays/")
  Future<CountryResponse> getAvailableCountries();// On reçoit un objet, pas une liste directe

// Endpoint: GET /api/v1/transactions/international/services/{pays_code}/
  @GET("/v1/transactions/international/pays/{pays_code}/services/")
  Future<ServiceResponse> getServicesForCountry(@Path("pays_code") String countryCode); // <-- MODIFIÉ

  @POST("/v1/transactions/international/calculate-fees/")
  Future<FeeCalculationWrapper> calculateFees(@Body() FeeRequest request); // <-- MODIFIÉ


  @POST("/v1/transactions/international/send-money/")
  Future<void> sendMoneyInternational(@Body() InternationalSendRequest request);


  @GET("/v1/agents/")
  // On change temporairement PaginatedResponse<Agent> en dynamic
  Future<dynamic> getAgents({ // <-- MODIFIÉ
    @Query("lat") double? lat,
    @Query("lon") double? lon,
  });

  @POST("/v1/withdrawals/")
  Future<WithdrawalResponse> requestWithdrawal(@Body() WithdrawalRequest request);

  @GET("/v1/receptions/")
  Future<PaginatedResponse<Reception>> getReceptions({@Query("status") String? status});

  @POST("/v1/receptions/{id}/retrait-digital/")
  Future<void> requestDigitalWithdrawal(@Path("id") int receptionId);

  @PATCH("/auth/profile/")
  Future<UserProfile> updateProfile(@Body() Map<String, dynamic> data);

  @POST("/auth/change-password/")
  Future<void> changePassword(@Body() Map<String, String> data);

  @POST("/kyc/upload/")
  // On ne précise plus @MultiPart ici, Dio le déduira de FormData
  Future<void> uploadKycDocument(@Body() FormData formData);

  @GET("/v1/notifications/")
  Future<PaginatedResponse<NotificationModel>> getNotifications({@Query("status") String? status});

  @GET("/v1/notifications/unread_count/")
  Future<Map<String, int>> getUnreadNotificationCount();

  @POST("/v1/notifications/{id}/mark_as_read/")
  Future<void> markNotificationAsRead(@Path("id") int id);


  @POST("/v1/notifications/delete_multiple/")
  Future<void> deleteNotifications(@Body() Map<String, List<int>> body);
}
