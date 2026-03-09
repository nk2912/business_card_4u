import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../vos/request/login_request.dart';
import '../responses/login_response.dart';
import 'auth_api.dart';

class AuthApiImpl implements AuthApi {
  final Dio dio;

  AuthApiImpl(this.dio);

  String _extractErrorMessage(DioException e, {String fallback = 'Something went wrong'}) {
    final data = e.response?.data;

    if (data is Map) {
      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }

      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error;
      }

      final errors = data['errors'];
      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.trim().isNotEmpty) {
              return first;
            }
          }

          if (value is String && value.trim().isNotEmpty) {
            return value;
          }
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return fallback;
  }

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
      throw Exception(_extractErrorMessage(e, fallback: 'Login failed'));
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
        options: Options(
          sendTimeout: const Duration(seconds: 20),
          receiveTimeout: const Duration(seconds: 20),
        ),
      );

      final data = response.data;
      if (data is Map) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return data;
      }

      return 'OTP sent successfully';
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, fallback: 'Failed to send OTP'));
    }
  }


  /// ================= VERIFY OTP ONLY =================
  @override
  Future<String> verifyOtp(String email, String otp) async {
    try {
      final res = await dio.post(
        ApiConstants.verifyOtp,
        data: {
          "email": email,
          "otp": otp,
        },
      );

      final data = res.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
      return 'OTP verified successfully';
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, fallback: 'OTP verification failed'));
    }
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
      throw Exception(_extractErrorMessage(e, fallback: 'Registration failed'));
    }
  }

  /// ================= LOGOUT =================
  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, fallback: 'Logout failed'));
    }
  }

  @override
  Future<String> deactivateAccount(String password) async {
    try {
      final res = await dio.post(
        ApiConstants.deactivateAccount,
        data: {
          'password': password,
        },
      );

      final data = res.data;
      if (data is Map && data['message'] is String) {
        return data['message'] as String;
      }
      return 'Your account has been deactivated.';
    } on DioException catch (e) {
      throw Exception(
        _extractErrorMessage(e, fallback: 'Failed to deactivate account'),
      );
    }
  }

  /// ================= GET PROFILE =================
  @override
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final res = await dio.post(ApiConstants.me);
      return res.data['user'];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, fallback: 'Fetch profile failed'));
    }
  }
}
