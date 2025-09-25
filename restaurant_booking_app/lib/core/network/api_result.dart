import '../error/failures.dart';

sealed class ApiResult<T> {
  const ApiResult();
  
  const factory ApiResult.success(T data) = Success<T>;
  const factory ApiResult.failure(Failure failure) = Error<T>;
  
  TResult when<TResult>({
    required TResult Function(T data) success,
    required TResult Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success<T>(data: final data) => success(data),
      Error<T>(failure: final f) => failure(f),
    };
  }
}

class Success<T> extends ApiResult<T> {
  const Success(this.data);
  final T data;
}

class Error<T> extends ApiResult<T> {
  const Error(this.failure);
  final Failure failure;
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