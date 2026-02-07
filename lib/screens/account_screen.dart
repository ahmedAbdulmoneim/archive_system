import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../bloc/auth/auth_cubit.dart';
import '../bloc/theme_cubit/theme_cubit.dart';
import 'change_password_page.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;

    double contentWidth;
    if (width < 600) {
      contentWidth = double.infinity;
    } else if (width < 1024) {
      contentWidth = 600;
    } else {
      contentWidth = 720;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الحساب'),
      ),
      body: Center(
        child: Container(
          width: contentWidth,
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [

              // =========================
              // 👤 USER INFO CARD
              // =========================
              Card(
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      user?.email?[0].toUpperCase() ?? '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user?.email ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('حساب المستخدم'),
                ),
              ),

              const SizedBox(height: 32),

              // =========================
              // 🔐 SECURITY SECTION
              // =========================
              Text(
                'الأمان',
                style: theme.textTheme.titleMedium!
                    .copyWith(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 12),

              Card(
                child: ListTile(
                  leading: Icon(Icons.lock,
                      color: theme.colorScheme.primary),
                  title: const Text('تغيير كلمة المرور'),
                  subtitle:
                  const Text('تحديث كلمة المرور الخاصة بك'),
                  trailing:
                  const Icon(Icons.arrow_forward_ios, size: 16),
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
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: const Text('خروج'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // dark mode
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('الوضع الليلي'),
                trailing: Switch(
                  value: Theme.of(context).brightness == Brightness.dark,
                  onChanged: (_) {
                    context.read<ThemeCubit>().toggleTheme();
                  },
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
