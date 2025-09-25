import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';


import '../../../core/error/failures.dart';
import '../../../core/network/api_result.dart';
import '../local/local_storage.dart';

@singleton
class ApiClient {
  final Dio _dio;
  final LocalStorage _localStorage;

  ApiClient(this._dio, this._localStorage) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token to requests
          final token = _localStorage.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle token refresh on 401
          if (error.response?.statusCode == 401) {
            final refreshToken = _localStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final newToken = await _refreshToken(refreshToken);
                await _localStorage.saveAuthToken(newToken);
                
                // Retry original request
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // Refresh failed, clear tokens
                await _localStorage.clearAuthTokens();
              }
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<String> _refreshToken(String refreshToken) async {
    final response = await _dio.post(
      '/auth/refresh',
      data: {'refresh_token': refreshToken},
    );
    return response.data['access_token'];
  }

  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      } else {
        return ApiResult.success(response.data as T);
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      } else {
        return ApiResult.success(response.data as T);
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      } else {
        return ApiResult.success(response.data as T);
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(ServerFailure(e.toString()));
    }
  }

  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      
      if (fromJson != null) {
        return ApiResult.success(fromJson(response.data));
      } else {
        return ApiResult.success(response.data as T);
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(ServerFailure(e.toString()));
    }
  }

  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Превышено время ожидания');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Ошибка сервера';
        return ServerFailure(message, code: statusCode?.toString());
      case DioExceptionType.cancel:
        return const NetworkFailure('Запрос отменен');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Ошибка подключения к интернету');
      default:
        return ServerFailure(error.message ?? 'Неизвестная ошибка');
    }
  }
}