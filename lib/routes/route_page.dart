import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/views/auth/login_screen.dart';
import 'package:daily_calo/views/auth/register_screen.dart';
import 'package:daily_calo/views/screens/exercises/exercise_screen.dart';
import 'package:daily_calo/views/screens/home/home_screen.dart';
import 'package:daily_calo/views/screens/meals/meal_screen.dart';
import 'package:daily_calo/views/screens/profile/profile_screen.dart';
import 'package:get/get.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.register, page: () => const RegisterScreen()),
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.meal, page: () => const MealScreen()),
    GetPage(name: AppRoutes.exercise, page: () => const ExerciseScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];
}