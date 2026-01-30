import 'package:flutter/material.dart';
import '../../core/responsive/responsive_layout.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildForm(context, width: double.infinity),
        tablet: _buildForm(context, width: 400),
        desktop: Center(child: _buildForm(context, width: 420)),
      ),
    );
  }

  Widget _buildForm(BuildContext context, {required double width}) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'تسجيل الدخول',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),
          const TextField(
            decoration: InputDecoration(labelText: 'اسم المستخدم'),
          ),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(labelText: 'كلمة المرور'),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('دخول'),
            ),
          ),
        ],
      ),
    );
  }
}
