import 'package:freezed_annotation/freezed_annotation.dart';
import '../error/failures.dart';

part 'api_result.freezed.dart';

@freezed
class ApiResult<T> with _$ApiResult<T> {
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.failure(Failure failure) = Error<T>;
}

extension ApiResultX<T> on ApiResult<T> {
  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Error<T>;
  
  T? get dataOrNull => when(
    success: (data) => data,
    failure: (_) => null,
  );
  
  Failure? get failureOrNull => when(
    success: (_) => null,
    failure: (failure) => failure,
  );
}