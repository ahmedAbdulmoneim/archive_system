import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_state.dart';

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

      await _emitAuthenticated(cred.user!);
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  // 🔹 Shared logic (NEW)
  Future<void> _emitAuthenticated(User user) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(user.uid) // ⚠️ لازم UID
          .get();

      if (!doc.exists) {
        // fallback — عشان ما نكسرش التطبيق
        emit(AuthAuthenticated(user));
        return;
      }

      final data = doc.data()!;
      final active = data['active'] ?? true;

      if (!active) {
        await _auth.signOut();
        emit(AuthError('Account disabled'));
        emit(AuthUnauthenticated());
        return;
      }

      emit(AuthAuthenticated(
        user,
        role: data['role'],   // admin / user
        active: active,
      ));
    } catch (_) {
      // fallback آمن
      emit(AuthAuthenticated(user));
    }
  }

  // 🔹 Logout
  Future<void> logout() async {
    emit(AuthLoading());
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }
}
