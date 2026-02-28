import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../core/auth/auth_session.dart';
import '../../core/network/dio_client.dart';
import '../../data/network/data_agents/auth_api_impl.dart';
import '../../data/vos/request/login_request.dart';
import '../../core/storage/token_storage.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isCheckingSession = false;
  bool isLoggedIn = false;
  UserModel? currentUser;

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
    notifyListeners();

    try {
      final res = await _api.login(
        LoginRequest(email: email, password: password),
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

  /// ================= SEND OTP =================
  Future<String?> sendOtp(String email) async {
    isLoading = true;
    notifyListeners();

    try {
      final message = await _api.sendOtp(email);
      return message;
    } catch (e) {
      return e.toString().replaceFirst("Exception: ", "");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// ================= VERIFY OTP ONLY =================
  Future<String?> verifyOtpOnly(String email, String otp) async {
    isLoading = true;
    notifyListeners();

    try {
      final message = await _api.verifyOtp(email, otp);
      return message;
    } on DioException catch (e) {
      return e.response?.data["message"]?.toString() ?? "Something went wrong";
    } catch (e) {
      return "Something went wrong";
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
    notifyListeners();
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
