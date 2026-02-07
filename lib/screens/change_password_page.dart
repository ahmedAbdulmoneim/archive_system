import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    if (_newPasswordController.text !=
        _confirmPasswordController.text) {
      setState(() {
        _error = 'كلمتا المرور غير متطابقتين';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 🔐 إعادة التحقق (مهم أمنيًا)
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: _oldPasswordController.text.trim(),
      );

      await user.reauthenticateWithCredential(credential);

      // 🔁 تغيير كلمة المرور
      await user.updatePassword(
        _newPasswordController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _error = _firebaseError(e.code);
      });
    } catch (_) {
      setState(() {
        _error = 'حدث خطأ غير متوقع';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  String _firebaseError(String code) {
    switch (code) {
      case 'wrong-password':
        return 'كلمة المرور الحالية غير صحيحة';
      case 'weak-password':
        return 'كلمة المرور الجديدة ضعيفة';
      case 'requires-recent-login':
        return 'يرجى تسجيل الدخول مرة أخرى';
      default:
        return 'فشل تغيير كلمة المرور';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تغيير كلمة المرور'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الحالية',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور الجديدة',
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'تأكيد كلمة المرور الجديدة',
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _changePassword,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('تغيير كلمة المرور'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
