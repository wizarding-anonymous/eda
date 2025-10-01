import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../core/network/api_result.dart';
import '../../../core/error/failures.dart';

@singleton
class ApiClient {
  final Dio _dio;

  ApiClient(this._dio);

  /// GET request
  Future<ApiResult<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data != null) {
        return ApiResult.success(response.data as T);
      } else {
        return ApiResult.failure(
          const ServerFailure('No data received'),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }

  /// POST request
  Future<ApiResult<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data != null) {
        return ApiResult.success(response.data as T);
      } else {
        return ApiResult.failure(
          const ServerFailure('No data received'),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }

  /// PUT request
  Future<ApiResult<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data != null) {
        return ApiResult.success(response.data as T);
      } else {
        return ApiResult.failure(
          const ServerFailure('No data received'),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }

  /// PATCH request
  Future<ApiResult<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data != null) {
        return ApiResult.success(response.data as T);
      } else {
        return ApiResult.failure(
          const ServerFailure('No data received'),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }

  /// DELETE request
  Future<ApiResult<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data != null) {
        return ApiResult.success(response.data as T);
      } else {
        return ApiResult.failure(
          const ServerFailure('No data received'),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }

  /// Handle Dio errors and convert to appropriate failures
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Connection timeout');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ??
            error.response?.statusMessage ??
            'Server error';

        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return ValidationFailure(message);
            case 401:
              return const AuthFailure('Unauthorized');
            case 403:
              return const AuthFailure('Forbidden');
            case 404:
              return const ServerFailure('Not found');
            case 422:
              return ValidationFailure(message);
            case 500:
            case 502:
            case 503:
            case 504:
              return const ServerFailure('Server error');
            default:
              return ServerFailure(message);
          }
        }
        return ServerFailure(message);

      case DioExceptionType.cancel:
        return const NetworkFailure('Request cancelled');

      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');

      case DioExceptionType.badCertificate:
        return const NetworkFailure('Certificate error');

      case DioExceptionType.unknown:
        return NetworkFailure(error.message ?? 'Unknown error');
    }
  }
}

/// Extension to add convenience methods
extension ApiClientExtension on ApiClient {
  /// Upload file
  Future<ApiResult<T>> uploadFile<T>(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fieldName: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<T>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );

      if (response.data != null) {
        return ApiResult.success(response.data as T);
      } else {
        return ApiResult.failure(
          const ServerFailure('No data received'),
        );
      }
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }

  /// Download file
  Future<ApiResult<void>> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      await _dio.download(
        path,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
      );

      return const ApiResult.success(null);
    } on DioException catch (e) {
      return ApiResult.failure(_handleDioError(e));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(e.toString()),
      );
    }
  }
}
