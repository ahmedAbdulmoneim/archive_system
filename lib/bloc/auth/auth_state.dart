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

  // ✅ OPTIONAL (مش إجباري)
  final String? role;
  final bool? active;

  AuthAuthenticated(
      this.user, {
        this.role,
        this.active,
      });
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
