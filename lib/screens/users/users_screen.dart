import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_cubit.dart';
import 'users_view.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    // 🔐 حماية الشاشة (Super Admin فقط)
    if (authState is! AuthAuthenticated ||
        authState.role != 'super_admin') {
      return const Scaffold(
        body: Center(
          child: Text('غير مصرح لك بالدخول'),
        ),
      );
    }

    final currentAdminUid = authState.user.uid;

    return BlocProvider(
      create: (_) => UsersCubit()..fetchUsers(),
      child: UsersView(currentAdminUid: currentAdminUid),
    );
  }
}
