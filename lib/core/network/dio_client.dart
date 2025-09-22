import 'package:dio/dio.dart';
import '../services/storage_service.dart';

class AuthInterceptor extends Interceptor {
  final StorageService storageService;

  AuthInterceptor(this.storageService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = storageService.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle token refresh on 401
    if (err.response?.statusCode == 401) {
      final refreshToken = storageService.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Attempt to refresh token
          final dio = Dio();
          final response = await dio.post(
            '/auth/refresh',
            data: {'refreshToken': refreshToken},
          );

          if (response.statusCode == 200) {
            final newAccessToken = response.data['data']['accessToken'];
            final newRefreshToken = response.data['data']['refreshToken'];
            
            await storageService.setAccessToken(newAccessToken);
            await storageService.setRefreshToken(newRefreshToken);

            // Retry original request
            final requestOptions = err.requestOptions;
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            
            final retryResponse = await dio.fetch(requestOptions);
            handler.resolve(retryResponse);
            return;
          }
        } catch (e) {
          // Refresh failed, clear tokens
          await storageService.clearAuthData();
        }
      }
    }
    handler.next(err);
  }
}