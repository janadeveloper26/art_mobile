import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({required String message, this.statusCode})
    : super(message: message);

  @override
  List<Object> get props => [message, statusCode ?? 0];
}

class NetworkFailure extends Failure {
  const NetworkFailure({required String message}) : super(message: message);
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message: message);
}

class ValidationFailure extends Failure {
  const ValidationFailure({required String message}) : super(message: message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required String message})
    : super(message: message);
}

class AuthorizationFailure extends Failure {
  const AuthorizationFailure({required String message})
    : super(message: message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({required String message}) : super(message: message);
}

class ConflictFailure extends Failure {
  const ConflictFailure({required String message}) : super(message: message);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure({required String message}) : super(message: message);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure({required String message}) : super(message: message);
}
