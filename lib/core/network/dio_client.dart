import 'package:dio/dio.dart';
import 'api_constants.dart';
import '../auth/auth_session.dart';
import '../storage/token_storage.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        // Render free instances can take time to wake up on first request.
        connectTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.read();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (_shouldRetry(error)) {
            try {
              await Future<void>.delayed(const Duration(seconds: 2));
              final retryResponse = await dio.fetch<dynamic>(error.requestOptions);
              handler.resolve(retryResponse);
              return;
            } catch (_) {
              // Continue to default error handling below.
            }
          }

          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            await TokenStorage.clear();
            AuthSession.notifyUnauthorized();
          }
          handler.next(error);
        },
      ),
    );

    return dio;
  }

  static bool _shouldRetry(DioException error) {
    if (error.requestOptions.extra['retried'] == true) return false;

    final isTransient = error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError;

    if (!isTransient) return false;

    error.requestOptions.extra['retried'] = true;
    return true;
  }
}
