import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../vos/request/login_request.dart';
import '../responses/login_response.dart';
import 'auth_api.dart';

class AuthApiImpl implements AuthApi {
  final Dio dio;

  AuthApiImpl(this.dio);

  /// ================= LOGIN =================
  @override
  Future<LoginResponse> login(LoginRequest request) async {
    try {
      final Response res = await dio.post(
        ApiConstants.login,
        data: request.toJson(),
      );

      return LoginResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  /// ================= SEND OTP =================
  @override
  Future<String> sendOtp(String email) async {
    try {
      final response = await dio.post(
        ApiConstants.sendOtp,
        data: {
          "email": email,
        },
      );

      // success message from backend
      return response.data['message'] as String;
    } on DioException catch (e) {
      // error message from backend
      throw Exception(
        e.response?.data['message'] ?? 'Something went wrong',
      );
    }
  }


  /// ================= VERIFY OTP ONLY =================
  @override
  Future<String> verifyOtp(String email, String otp) async {
    final res = await dio.post(
      ApiConstants.verifyOtp,
      data: {
        "email": email,
        "otp": otp,
      },
    );

    return res.data["message"].toString();
  }


  /// ================= COMPLETE REGISTER =================
  @override
  Future<LoginResponse> completeRegister(
      String email,
      String name,
      String password,
      String confirmPassword,
      ) async {
    try {
      final Response res = await dio.post(
        ApiConstants.completeRegister,
        data: {
          "email": email,
          "name": name,
          "password": password,
          "password_confirmation": confirmPassword,
        },
      );

      return LoginResponse.fromJson(res.data);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Registration failed',
      );
    }
  }

  /// ================= LOGOUT =================
  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Logout failed',
      );
    }
  }
}
