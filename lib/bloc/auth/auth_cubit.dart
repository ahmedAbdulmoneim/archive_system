import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial());

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login(String email, String password) async {
    emit(AuthLoading());

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      emit(AuthAuthenticated(result.user!));
    } on FirebaseAuthException catch (e) {
      emit(AuthUnauthenticated(e.message));
    } catch (_) {
      emit(const AuthUnauthenticated('حدث خطأ غير متوقع'));
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    emit(const AuthUnauthenticated());
  }

  void checkAuthStatus() {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }
}
