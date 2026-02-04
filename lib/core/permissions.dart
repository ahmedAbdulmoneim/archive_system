import '../bloc/auth/auth_state.dart';

class Permissions {
  static bool isAdmin(AuthState state) {
    return state is AuthAuthenticated && state.role == 'admin';
  }

  static bool isUser(AuthState state) {
    return state is AuthAuthenticated && state.role == 'user';
  }
}
