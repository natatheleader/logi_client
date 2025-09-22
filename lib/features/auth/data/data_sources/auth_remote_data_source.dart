import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthTokensModel> exchangeFirebaseToken(String firebaseToken);
  Future<AuthTokensModel> refreshTokens(String refreshToken);
  Future<UserModel> getCurrentUser();
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
  });
  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthTokensModel> exchangeFirebaseToken(String firebaseToken) async {
    try {
      final response = await dio.post(
        '/auth/exchange-token',
        data: {'firebaseToken': firebaseToken},
      );

      return AuthTokensModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: 'Failed to exchange token: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokensModel> refreshTokens(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      return AuthTokensModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: 'Failed to refresh tokens: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: 'Failed to get user: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;

      final response = await dio.patch('/auth/profile', data: data);
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: 'Failed to update profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await dio.delete('/auth/account');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw ServerException(message: 'Failed to delete account: ${e.toString()}');
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(message: 'Request timeout');
      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data?['message'] ?? 'Server error';
        
        if (statusCode == 401) {
          return AuthenticationException(message: message, statusCode: statusCode);
        } else if (statusCode == 403) {
          return AuthenticationException(message: message, statusCode: statusCode);
        } else {
          return ServerException(message: message, statusCode: statusCode);
        }
      default:
        return ServerException(message: 'Unknown error occurred');
    }
  }
}