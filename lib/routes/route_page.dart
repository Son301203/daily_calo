import 'package:daily_calo/routes/app_routes.dart';
import 'package:daily_calo/views/screens/exercise_screen.dart';
import 'package:daily_calo/views/screens/home_screen.dart';
import 'package:daily_calo/views/screens/meal_screen.dart';
import 'package:daily_calo/views/screens/profile_screen.dart';
import 'package:get/get.dart';


class AppPages{
  static final List<GetPage> pages = [
    GetPage(name: AppRoutes.home, page: () => const HomeScreen()),
    GetPage(name: AppRoutes.meal, page: () => const MealScreen()),
    GetPage(name: AppRoutes.exercise, page: () => const ExerciseScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];

}