import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/routes/route_page.dart';
import 'package:daily_calo/services/firebase_options.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ứng dụng quản lý Calo',
      debugShowCheckedModeBanner: false,
      initialRoute:
          auth.FirebaseAuth.instance.currentUser != null &&
                  auth.FirebaseAuth.instance.currentUser!.emailVerified
              ? AppRoutes.home
              : AppRoutes.login,
      getPages: AppPages.pages,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.lightText,
          elevation: 2,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.lightTextSecondary,
          selectedIconTheme: IconThemeData(color: AppColors.primary),
          unselectedIconTheme: IconThemeData(
            color: AppColors.lightTextSecondary,
          ),
        ),
      ),
    );
  }
}
