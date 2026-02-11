import '../../vos/request/login_request.dart';
import '../responses/login_response.dart';

abstract class AuthApi {
  Future<LoginResponse> login(LoginRequest request);
}
