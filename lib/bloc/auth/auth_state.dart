import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {
  final String? message;

  AuthUnauthenticated([this.message]);

  @override
  List<Object?> get props => [message];
}

class AuthAuthenticated extends AuthState {
  final User user;
  final String role;
  final bool active;
  final String? branchId;
  final String? branchName;
  final String? name;

   AuthAuthenticated(
      this.user, {
        required this.role,
        required this.active,
        this.branchId,
        this.branchName,
        this.name,
      });
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
