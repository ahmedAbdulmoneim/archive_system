import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../bloc/auth/auth_cubit.dart';
import '../../bloc/auth/auth_state.dart';
import '../../core/responsive/responsive_layout.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _error;

  late AnimationController _controller;
  late Animation<double> _imageFade;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _imageFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _formFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // =========================
  // 🔹 Forgot Password Dialog
  // =========================
  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('إعادة تعيين كلمة المرور'),
        content: TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'البريد الإلكتروني',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: emailController.text.trim(),
                );

                if (!mounted) return;

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم إرسال رابط إعادة تعيين كلمة المرور',
                    ),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_firebaseError(e.code)),
                  ),
                );
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'لا يوجد حساب بهذا البريد الإلكتروني';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      default:
        return 'حدث خطأ، حاول مرة أخرى';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        // 🔥 لو تسجيل الدخول نجح → انتقل للشاشة التالية
        if (state is AuthAuthenticated) {
          Navigator.pushReplacementNamed(context, '/documents');
        }

        // ❌ لو في خطأ → اعرضه
        if (state is AuthError) {
          setState(() {
            _error = state.message;
          });
        }
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [

            // =========================
            // 🖼️ BACKGROUND IMAGE
            // =========================
            FadeTransition(
              opacity: _imageFade,
              child: Image.asset(
                'assets/logo.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // =========================
            // 🌫️ OVERLAY
            // =========================
            Container(
              color: Colors.black.withOpacity(0.45),
            ),

            // =========================
            // 🔐 LOGIN FORM
            // =========================
            FadeTransition(
              opacity: _formFade,
              child: SlideTransition(
                position: _formSlide,
                child: ResponsiveLayout(
                  mobile: _form(double.infinity),
                  tablet: _form(420),
                  desktop: Center(child: _form(420)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _form(double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Text(
            'تسجيل الدخول',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(color: Colors.white),
          ),

          const SizedBox(height: 24),

          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'البريد الإلكتروني',
              filled: true,
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'كلمة المرور',
              filled: true,
            ),
          ),

          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: const TextStyle(color: Colors.red),
            ),
          ],

          const SizedBox(height: 24),

          BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                setState(() {
                  _error = state.message;
                });
              }
            },
            builder: (context, state) {
              final loading = state is AuthLoading;

              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () {
                        context.read<AuthCubit>().login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                      },
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('دخول'),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: _showForgotPasswordDialog,
                    child: const Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
