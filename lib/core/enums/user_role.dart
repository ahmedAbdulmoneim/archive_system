enum UserRole {
  superAdmin,
  branchAdmin,
  user,
}

extension UserRoleX on UserRole {
  String get claim {
    switch (this) {
      case UserRole.superAdmin:
        return 'super_admin';
      case UserRole.branchAdmin:
        return 'branch_admin';
      case UserRole.user:
        return 'user';
    }
  }

  String get label {
    switch (this) {
      case UserRole.superAdmin:
        return 'Super Admin';
      case UserRole.branchAdmin:
        return 'Branch Admin';
      case UserRole.user:
        return 'User';
    }
  }

  static UserRole fromClaim(String value) {
    return UserRole.values.firstWhere(
          (e) => e.claim == value,
      orElse: () => UserRole.user,
    );
  }
}
