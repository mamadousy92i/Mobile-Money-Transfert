import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../models/auth_request.dart';
import '../../models/user.dart';
import '../../models/token.dart';

part 'auth_api.g.dart';

@RestApi(baseUrl: "https://553da07603d3.ngrok-free.app/api/auth/")
abstract class AuthApi {
  factory AuthApi(Dio dio, {String baseUrl}) = _AuthApi;

  @POST("register/")
  Future<User> register(@Body() RegisterRequest request);

  @POST("login/")
  Future<TokenPair> login(@Body() LoginRequest request);

  @POST("logout/")
  Future<void> logout(@Body() Map<String, String> refreshToken);

  @POST("refresh/")
  Future<TokenPair> refreshToken(@Body() Map<String, String> refreshToken);

  @GET("profile/")
  Future<User> getUserProfile();

  @PUT("profile/")
  Future<User> updateUserProfile(@Body() Map<String, dynamic> userData);

  @PUT("change-password/")
  Future<void> changePassword(@Body() Map<String, String> passwordData);
}
