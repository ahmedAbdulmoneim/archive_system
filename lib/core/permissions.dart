import '../bloc/auth/auth_state.dart';

class Permissions {
  static bool isSuperAdmin(AuthState state) {
    return state is AuthAuthenticated &&
        state.role == 'super_admin';
  }

  static bool isBranchAdmin(AuthState state) {
    return state is AuthAuthenticated &&
        state.role == 'branch_admin';
  }

  static bool canManageDocuments(AuthState state) {
    return isSuperAdmin(state) || isBranchAdmin(state);
  }

  static bool canManageUsers(AuthState state) {
    return isSuperAdmin(state);
  }

  static bool canManageTypes(AuthState state) {
    return isSuperAdmin(state);
  }
}
