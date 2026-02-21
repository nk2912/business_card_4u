import '../../vos/request/login_request.dart';
import '../responses/login_response.dart';

abstract class AuthApi {

  /// ================= LOGIN =================
  Future<LoginResponse> login(LoginRequest request);

  /// ================= SEND OTP =================
  Future<String> sendOtp(String email);

  /// ================= VERIFY OTP ONLY =================
  Future<String> verifyOtp(String email, String otp);

  /// ================= COMPLETE REGISTER =================
  Future<LoginResponse> completeRegister(
      String email,
      String name,
      String password,
      String confirmPassword,
      );

  /// ================= LOGOUT =================
  Future<void> logout();
}
