import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/routes/route_page.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ứng dụng quản lý Calo',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.lightText, // Text/icon color
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
