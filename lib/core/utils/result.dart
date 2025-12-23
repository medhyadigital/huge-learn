import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Type alias for Result pattern using Either from dartz
typedef Result<T> = Either<Failure, T>;
typedef FutureResult<T> = Future<Result<T>>;

/// Extension methods for Result
extension ResultExtension<T> on Result<T> {
  /// Check if result is success
  bool get isSuccess => isRight();
  
  /// Check if result is failure
  bool get isFailure => isLeft();
  
  /// Get value if success, null otherwise
  T? get value => fold((l) => null, (r) => r);
  
  /// Get failure if failure, null otherwise
  Failure? get failure => fold((l) => l, (r) => null);
}






