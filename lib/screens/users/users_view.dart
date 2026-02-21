import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/user/user_cubit.dart';
import '../../core/enums/user_role.dart';

class UsersView extends StatelessWidget {
  final String currentAdminUid;

   const UsersView({required this.currentAdminUid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              final role =
              UserRoleX.fromClaim(user['role'] ?? 'user');

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(user['email'] ?? ''),
                  subtitle: Text('Role: ${role.label}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // 🔁 ROLE DROPDOWN
                      DropdownButton<UserRole>(
                        value: role,
                        items: UserRole.values
                            .map(
                              (r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.label),
                          ),
                        )
                            .toList(),
                        onChanged: user['id'] == currentAdminUid
                            ? null
                            : (newRole) {
                          context.read<UsersCubit>().updateRole(
                            user['id'],
                            newRole!.claim,
                          );
                        },
                      ),

                      // ⛔ ACTIVE SWITCH
                      Switch(
                        value: user['active'] ?? false,
                        onChanged: user['id'] == currentAdminUid
                            ? null
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
    );
  }
}
