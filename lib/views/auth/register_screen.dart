import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:daily_calo/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );
        User? user = userCredential.user;
        if (user != null) {
          // Save user data to Firestore
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(user.uid)
              .set({
                'gmail': _emailController.text.trim(),
                'name': _usernameController.text.trim(),
                'height': 0.0,
                'weight': 0.0,
              });

          // Send email verification
          await user.sendEmailVerification();
          Get.snackbar(
            'Đăng ký tài khoản thành công',
            'Hãy xác thực tài khoản trước khi đăng nhập.',
            backgroundColor: AppColors.success,
            colorText: AppColors.lightText,
          );
          Get.offAllNamed(AppRoutes.login);
        }
      } on FirebaseAuthException catch (e) {
        setState(() {
          _errorMessage = e.message;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng ký')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Tên tài khoản',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator.validateFullName,
              ),
              const SizedBox(height: 16),

              // Password
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu',
                  border: OutlineInputBorder(),
                ),
                validator: FormValidator.validatePassword,
                obscureText: true,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Xác nhận mật khẩu',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => FormValidator.validateConfirmPassword(
                      value,
                      _passwordController.text,
                    ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              if (_errorMessage != null)
                Text(_errorMessage!, style: TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                    onPressed: _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.lightText,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Đăng ký'),
                  ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Get.toNamed(AppRoutes.login);
                },
                child: const Text('Bạn đã có tài khoản? Đăng nhập'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
