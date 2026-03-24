import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../core/network/dio_client.dart';
import '../../data/network/data_agents/auth_api_impl.dart';
import '../../data/vos/request/login_request.dart';
import '../../core/storage/token_storage.dart';
import '../../data/models/user_model.dart';

class AuthActionResult {
  final bool success;
  final String? message;

  const AuthActionResult({
    required this.success,
    this.message,
  });
}

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isCheckingSession = false;
  bool isLoggedIn = false;
  UserModel? currentUser;
  String? pendingMessage;
  String? lastErrorMessage;

  final _api = AuthApiImpl(DioClient.create());
  late final VoidCallback _unauthorizedListener;

  AuthProvider() {
    _unauthorizedListener = () {
      if (isLoggedIn || currentUser != null) {
        logout();
      }
    };
    AuthSession.unauthorizedTick.addListener(_unauthorizedListener);
  }

  /// ================= LOGIN =================
  Future<bool> login(String email, String password) async {
    isLoading = true;
    lastErrorMessage = null;
    notifyListeners();

    try {
      final res = await _api.login(
        LoginRequest(email: email, password: password),
      );

      await TokenStorage.save(res.token);
      currentUser = UserModel.fromJson(res.user);
      pendingMessage = res.message;
      isLoggedIn = true;
      return true;
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      lastErrorMessage = message.isEmpty ? 'Login failed' : message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================= SEND OTP =================
  Future<AuthActionResult> sendOtp(String email) async {
    isLoading = true;
    notifyListeners();

    try {
      final message = await _api.sendOtp(email);
      return AuthActionResult(success: true, message: message);
    } on DioException catch (e) {
      final data = e.response?.data;

      if (data is Map) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return AuthActionResult(success: false, message: message);
        }

        final errors = data['errors'];
        if (errors is Map) {
          for (final value in errors.values) {
            if (value is List && value.isNotEmpty && value.first is String) {
              return AuthActionResult(
                success: false,
                message: value.first as String,
              );
            }

            if (value is String && value.trim().isNotEmpty) {
              return AuthActionResult(success: false, message: value);
            }
          }
        }
      }

      if (data is String && data.trim().isNotEmpty) {
        return AuthActionResult(success: false, message: data);
      }

      return const AuthActionResult(success: false, message: 'Failed to send OTP');
    } catch (e) {
      final message = e.toString().replaceFirst("Exception: ", "").trim();
      return AuthActionResult(
        success: false,
        message: message.isEmpty ? 'Failed to send OTP' : message,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================= VERIFY OTP ONLY =================
  Future<AuthActionResult> verifyOtpOnly(String email, String otp) async {
    isLoading = true;
    notifyListeners();

    try {
      final message = await _api.verifyOtp(email, otp);
      return AuthActionResult(success: true, message: message);
    } on DioException catch (e) {
      final data = e.response?.data;
      if (data is Map && data['message'] is String) {
        return AuthActionResult(success: false, message: data['message'] as String);
      }
      return const AuthActionResult(success: false, message: 'OTP verification failed');
    } catch (e) {
      return const AuthActionResult(success: false, message: 'Something went wrong');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================= COMPLETE REGISTER =================
  Future<bool> completeRegister(
    String email,
    String name,
    String password,
    String confirmPassword,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await _api.completeRegister(
        email,
        name,
        password,
        confirmPassword,
      );

      await TokenStorage.save(res.token);
      currentUser = UserModel.fromJson(res.user);
      isLoggedIn = true;
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================= CHECK LOGIN =================
  Future<void> checkLogin() async {
    isCheckingSession = true;
    notifyListeners();

    try {
      final token = await TokenStorage.read();
      if (token == null) {
        isLoggedIn = false;
        currentUser = null;
        return;
      }

      final userMap = await _api.getProfile();
      currentUser = UserModel.fromJson(userMap);
      isLoggedIn = true;
    } catch (e) {
      await TokenStorage.clear();
      isLoggedIn = false;
      currentUser = null;
    } finally {
      isCheckingSession = false;
      notifyListeners();
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await TokenStorage.clear();
    isLoggedIn = false;
    currentUser = null;
    pendingMessage = 'Logged out successfully';
    lastErrorMessage = null;
    notifyListeners();
  }

  Future<AuthActionResult> deactivateAccount(String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final message = await _api.deactivateAccount(password);
      return AuthActionResult(success: true, message: message);
    } catch (e) {
      final message = e.toString().replaceFirst('Exception: ', '').trim();
      return AuthActionResult(
        success: false,
        message: message.isEmpty
            ? 'Failed to deactivate account'
            : message,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> completeDeactivatedLogout(String message) async {
    await TokenStorage.clear();
    isLoggedIn = false;
    currentUser = null;
    pendingMessage = message;
    lastErrorMessage = null;
    notifyListeners();
  }

  Future<void> clearSessionSilently() async {
    await TokenStorage.clear();
    isLoggedIn = false;
    currentUser = null;
    pendingMessage = null;
    lastErrorMessage = null;
  }

  Future<void> prepareDeactivatedSession(String message) async {
    await TokenStorage.clear();
    isLoggedIn = false;
    currentUser = null;
    pendingMessage = message;
    lastErrorMessage = null;
  }

  String? consumePendingMessage() {
    final message = pendingMessage;
    pendingMessage = null;
    return message;
  }

  void cancelLoading() {
    isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    AuthSession.unauthorizedTick.removeListener(_unauthorizedListener);
    super.dispose();
  }
}
