import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_state.dart';
import '../../services/audit_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthCubit() : super(AuthInitial());

  // 🔹 Check auth on app start
  Future<void> checkAuthStatus() async {
    final user = _auth.currentUser;

    if (user == null) {
      emit(AuthUnauthenticated());
      return;
    }

    await _emitAuthenticated(user);
  }

  // 🔹 Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // ✅ Audit log
      await AuditService.log(
        action: 'login',
        entity: 'auth',
        description: 'تسجيل دخول',
      );

      await _emitAuthenticated(cred.user!);
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    final user = _auth.currentUser;

    // ✅ Audit log قبل الخروج
    if (user != null) {
      await AuditService.log(
        action: 'logout',
        entity: 'auth',
        description: 'تسجيل خروج',
      );
    }

    emit(AuthLoading());
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  // 🔹 Load role + active safely
  Future<void> _emitAuthenticated(User user) async {
    try {
      final doc =
      await _firestore.collection('users').doc(user.uid).get();

      // fallback لو مفيش document
      if (!doc.exists) {
        emit(AuthAuthenticated(user));
        return;
      }

      final data = doc.data()!;
      final active = data['active'] ?? true;

      if (!active) {
        await AuditService.log(
          action: 'blocked_login',
          entity: 'auth',
          description: 'محاولة دخول لحساب معطّل',
        );

        await _auth.signOut();
        emit(AuthError('الحساب غير مفعل'));
        emit(AuthUnauthenticated());
        return;
      }

      emit(AuthAuthenticated(
        user,
        role: data['role'], // admin / user
        active: active,
      ));
    } catch (e) {
      // fallback آمن
      emit(AuthAuthenticated(user));
    }
  }
}
