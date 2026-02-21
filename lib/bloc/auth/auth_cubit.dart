import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'auth_state.dart';
import '../../services/audit_service.dart';

class AuthCubit extends Cubit<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _sub;
  int _session = 0;

  AuthCubit() : super(AuthLoading()) {
    _sub = _auth.idTokenChanges().listen((user) async {
      final mySession = ++_session;

      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Ensure token is ready for Firestore on web
      try {
        await user.getIdToken(true);
      } catch (_) {}

      // If another auth event happened, stop
      if (mySession != _session) return;

      await _emitAuthenticated(user, mySession);
    });
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Force token readiness immediately
      await cred.user?.getIdToken(true);

      // Audit must NOT block login
      try {
        await AuditService.log(
          action: 'LOGIN',
          entity: 'auth',
          entityId: cred.user!.uid,
          description: 'تسجيل دخول',
          by: cred.user!.uid,
        );
      } catch (_) {}

      // Emit authenticated now (don’t wait for stream timing)
      final mySession = _session;
      await _emitAuthenticated(cred.user!, mySession);
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _auth.signOut();
    } catch (_) {}
    emit(AuthUnauthenticated());
  }

  Future<void> _emitAuthenticated(User user, int mySession) async {
    try {
      // If auth changed while we were waiting, stop
      if (mySession != _session) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (mySession != _session) return;

      if (!userDoc.exists) {
        emit(AuthAuthenticated(
          user,
          role: 'user',
          active: true,
        ));
        return;
      }

      final data = userDoc.data()!;
      final active = data['active'] ?? true;
      final role = data['role'] ?? 'user';
      final branchId = data['branchId'];
      final name = data['name']; // 🆕

      if (!active) {
        await _auth.signOut();
        emit(AuthUnauthenticated('الحساب غير مفعل'));
        return;
      }

      String? branchName;
      try {
        final branchDoc = await _firestore
            .collection('branches')
            .doc(branchId)
            .get();
        branchName = branchDoc.data()?['name'];
      } catch (e) {
        print('❌ branch read error: $e');
      }

      emit(AuthAuthenticated(
        user,
        role: role,
        active: active,
        branchId: branchId,
        branchName: branchName,
        name: name, // ⭐
      ));

    } catch (e) {
      // If Firestore fails here, you’ll never “finish login”
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
