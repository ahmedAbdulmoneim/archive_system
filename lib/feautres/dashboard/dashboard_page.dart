import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_cubit.dart';
import '../../core/responsive/responsive_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },

          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _content(context),
        tablet: _content(context),
        desktop: Center(
          child: SizedBox(width: 900, child: _content(context)),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً ${user?.email}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _dashboardCard(
                icon: Icons.add_box,
                title: 'إضافة وثيقة',
                onTap: () {},
              ),
              _dashboardCard(
                icon: Icons.search,
                title: 'بحث في الأرشيف',
                onTap: () {},
              ),
              _dashboardCard(
                icon: Icons.folder,
                title: 'عرض الوثائق',
                onTap: () {},
              ),
              _dashboardCard(
                icon: Icons.people,
                title: 'إدارة المستخدمين',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
