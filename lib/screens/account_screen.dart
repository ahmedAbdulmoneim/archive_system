import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/theme_cubit/theme_cubit.dart';
import 'change_password_page.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return BlocListener<AuthCubit, AuthState>(
      listenWhen: (previous, current) =>
      current is AuthUnauthenticated,
      listener: (context, state) {
        // 🔥 عند الخروج نغلق كل الشاشات
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الحساب'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [

            // =========================
            // 👤 USER INFO
            // =========================
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: Text(
                    user?.email?[0].toUpperCase() ?? '?',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(user?.email ?? ''),
                subtitle: const Text('حساب المستخدم'),
              ),
            ),

            const SizedBox(height: 32),

            // =========================
            // 🔐 CHANGE PASSWORD
            // =========================
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock),
                title: const Text('تغيير كلمة المرور'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // =========================
            // 🚪 LOGOUT
            // =========================
            Card(
              child: ListTile(
                leading: Icon(Icons.logout,
                    color: theme.colorScheme.error),
                title: Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('تسجيل الخروج'),
                      content:
                      const Text('هل تريد تسجيل الخروج؟'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text('إلغاء'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context.read<AuthCubit>().logout();
                            Navigator.pop(context); // close dialog
                          },
                          child: const Text('خروج'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),

            // =========================
            // 🌙 DARK MODE
            // =========================
            ListTile(
              leading: const Icon(Icons.dark_mode),
              title: const Text('الوضع الليلي'),
              trailing: Switch(
                value:
                Theme.of(context).brightness == Brightness.dark,
                onChanged: (_) {
                  context.read<ThemeCubit>().toggleTheme();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
