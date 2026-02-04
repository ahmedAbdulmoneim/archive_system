import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/user/user_cubit.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    final currentAdminUid =
    authState is AuthAuthenticated ? authState.user.uid : '';
    return BlocProvider(
      create: (_) => UsersCubit()..fetchUsers(),
      child: Scaffold(
        appBar: AppBar(title: const Text('إدارة المستخدمين')),
        body: BlocBuilder<UsersCubit, List<Map<String, dynamic>>>(
          builder: (context, users) {
            if (users.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (_, i) {
                final user = users[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(user['email'] ?? ''),
                    subtitle: Text('Role: ${user['role']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 🔁 Role
                        DropdownButton<String>(
                          value: user['role'],
                          items: const [
                            DropdownMenuItem(value: 'admin', child: Text('admin')),
                            DropdownMenuItem(value: 'user', child: Text('user')),
                          ],
                          onChanged: user['id'] == currentAdminUid
                              ? null // ❌ يمنع تعديل نفسه
                              : (v) {
                            context.read<UsersCubit>().updateRole(
                              user['id'],
                              v!,
                            );
                          },
                        ),


                        // ⛔ Active
                        Switch(
                          value: user['active'] ?? false,
                          onChanged: user['id'] == currentAdminUid
                              ? null // ❌ يمنع تعطيل نفسه
                              : (v) {
                            context.read<UsersCubit>().toggleActive(
                              uid: user['id'],
                              active: v,
                              adminUid: currentAdminUid,
                            );
                          },
                        ),


                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
