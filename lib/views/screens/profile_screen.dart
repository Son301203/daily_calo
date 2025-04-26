import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout() async {
    try {
      await auth.FirebaseAuth.instance.signOut();
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'Đăng xuất thành công',
        'Bạn đã đăng xuất khỏi ứng dụng.',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi đăng xuất',
        'Đã xảy ra lỗi: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin và cài đặt"),
        actions: [
          TextButton(
            onPressed: _logout,
            child: const Icon(Icons.logout, color: Colors.black),
          ),
        ],
      ),
      body: Center(
        child: OutlinedButton(
          onPressed: _logout,
          child: const Text("Đăng xuất"),
        ),
      ),
    );
  }
}
