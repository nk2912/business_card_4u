import 'package:flutter/material.dart';
import '../../core/network/dio_client.dart';
import '../../data/network/data_agents/auth_api_impl.dart';
import '../../data/vos/request/login_request.dart';
import '../../core/storage/token_storage.dart';

class AuthProvider extends ChangeNotifier {
  bool isLoading = false;
  bool isLoggedIn = false;

  final _api = AuthApiImpl(DioClient.create());

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final res = await _api.login(
        LoginRequest(email: email, password: password),
      );

      await TokenStorage.save(res.token);
      isLoggedIn = true;
      return true;
    } catch (e) {
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLogin() async {
    final token = await TokenStorage.read();
    isLoggedIn = token != null;
    notifyListeners();
  }

  Future<void> logout() async {
    await TokenStorage.clear();
    isLoggedIn = false;
    notifyListeners();
  }

  void cancelLoading() {
    isLoading = false;
    notifyListeners();
  }

}
