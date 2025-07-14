// lib/services/transaction_service.dart

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

// Modèles
import '../models/transaction.dart';
import '../models/canal_paiement.dart';
import '../models/beneficiaire.dart';
import '../models/responses/send_money_response.dart';
import '../models/responses/transaction_stats_response.dart';
import '../models/responses/exchange_rate_response.dart';
import '../models/responses/transaction_status_response.dart';
import '../models/responses/search_response.dart';

part 'transaction_service.g.dart';

@RestApi()
abstract class TransactionService {
  factory TransactionService(Dio dio) = _TransactionService;

  // 💰 TRANSACTIONS
  @GET('/transactions/')
  Future<List<Transaction>> getTransactions({
    @Query('status') String? status,
  });

  @GET('/transactions/{id}/')
  Future<Transaction> getTransactionById(@Path('id') String id);

  @POST('/transactions/')
  Future<Transaction> createTransaction(@Body() Map<String, dynamic> data);

  @PATCH('/transactions/{id}/update_status/')
  Future<Transaction> updateTransactionStatus(
      @Path('id') String id,
      @Body() Map<String, String> status,
      );

  @GET('/transactions/statistics/')
  Future<TransactionStatsResponse> getStatistics();

  // 🚀 ENVOI D'ARGENT
  @POST('/send-money/')
  Future<SendMoneyResponse> sendMoney(@Body() SendMoneyRequest request);

  // 💳 CANAUX DE PAIEMENT
  @GET('/canaux/')
  Future<List<CanalPaiement>> getCanaux();

  @GET('/canaux/{id}/')
  Future<CanalPaiement> getCanalById(@Path('id') String id);

  @POST('/canaux/')
  Future<CanalPaiement> createCanal(@Body() Map<String, dynamic> data);

  @GET('/canaux/by_country/')
  Future<List<CanalPaiement>> getCanauxByCountry(@Query('country') String country);

  // 👥 BÉNÉFICIAIRES
  @GET('/beneficiaires/')
  Future<List<Beneficiaire>> getBeneficiaires({
    @Query('search') String? search,
  });

  @GET('/beneficiaires/{id}/')
  Future<Beneficiaire> getBeneficiaireById(@Path('id') String id);

  @POST('/beneficiaires/')
  Future<Beneficiaire> createBeneficiaire(@Body() Map<String, dynamic> data);

  @PUT('/beneficiaires/{id}/')
  Future<Beneficiaire> updateBeneficiaire(
      @Path('id') String id,
      @Body() Map<String, dynamic> data,
      );

  @DELETE('/beneficiaires/{id}/')
  Future<void> deleteBeneficiaire(@Path('id') String id);

  // 💱 TAUX DE CHANGE
  @GET('/exchange-rates/')
  Future<ExchangeRateMainResponse> getExchangeRates();

  @GET('/exchange-rates/')
  Future<ExchangeRateSpecificResponse> getSpecificExchangeRate(
      @Query('to') String currency,
      );

  // 🔍 RECHERCHE & UTILITAIRES
  // CORRECTION: Changer le type de retour pour éviter l'erreur dynamic.fromJson
  @GET('/search/')
  Future<SearchResponse> searchTransactions(@Query('q') String query);

  @GET('/code/{code}/')
  Future<Transaction> getTransactionByCode(@Path('code') String code);

  @GET('/status/{code}/')
  Future<TransactionStatusResponse> getTransactionStatus(@Path('code') String code);
}