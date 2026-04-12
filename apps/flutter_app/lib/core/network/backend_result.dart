import 'package:rom_tracker_app/core/network/backend_failure.dart';

class BackendResult<T> {
  const BackendResult._({
    this.data,
    this.failure,
  });

  const BackendResult.success(T data) : this._(data: data);

  const BackendResult.failure(BackendFailure failure)
      : this._(failure: failure);

  final T? data;
  final BackendFailure? failure;

  bool get isSuccess => data != null && failure == null;
  bool get isFailure => failure != null;
}
