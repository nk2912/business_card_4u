import 'package:dio/dio.dart';
import '../../../core/network/api_constants.dart';
import '../../vos/request/login_request.dart';
import '../responses/login_response.dart';
import 'auth_api.dart';

class AuthApiImpl implements AuthApi {
  final Dio dio;

  AuthApiImpl(this.dio);

  @override
  Future<LoginResponse> login(LoginRequest request) async {
    final res = await dio.post(
      ApiConstants.login,
      data: request.toJson(),
    );

    return LoginResponse.fromJson(res.data);
  }
}
