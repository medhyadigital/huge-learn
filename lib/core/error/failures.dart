import 'package:equatable/equatable.dart';

/// Base class for all failures
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Server failure - API errors
class ServerFailure extends Failure {
  final int? statusCode;
  
  const ServerFailure(super.message, {this.statusCode});
  
  @override
  List<Object> get props => statusCode != null ? [message, statusCode!] : [message];
}

/// Network failure - connectivity issues
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Cache failure - local storage errors
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Authentication failure
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Validation failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Unknown failure
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

