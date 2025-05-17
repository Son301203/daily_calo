import 'package:daily_calo/utils/app_color.dart';
import 'package:flutter/material.dart';

class MealDetailScreen extends StatelessWidget {
  final Map<String, dynamic> dish;

  const MealDetailScreen({super.key, required this.dish});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dish['name'], style: TextStyle(color: AppColors.whiteText)),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                ListTile(
                  leading: const Icon(
                    Icons.restaurant_menu,
                    color: Colors.blue,
                  ),
                  title: const Text(
                    'Tên món ăn',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    dish['name'],
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
                const Divider(),
                // Serving size
                ListTile(
                  leading: const Icon(Icons.fastfood, color: Colors.green),
                  title: const Text(
                    'Serving size',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${dish['serving_size']} g',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
                const Divider(),
                // Protein
                ListTile(
                  leading: const Icon(Icons.fitness_center, color: Colors.red),
                  title: const Text(
                    'Protein',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${dish['protein']} g',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
                const Divider(),
                // Period time
                ListTile(
                  leading: const Icon(Icons.access_time, color: Colors.purple),
                  title: const Text(
                    'Thời gian bữa ăn',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    dish['period_time'],
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
                const Divider(),
                // Fat
                ListTile(
                  leading: const Icon(Icons.local_pizza, color: Colors.orange),
                  title: const Text(
                    'Fat',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${dish['fat']} g',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
                const Divider(),
                // Carbs
                ListTile(
                  leading: const Icon(Icons.bakery_dining, color: Colors.brown),
                  title: const Text(
                    'Carbs',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${dish['carbs']} g',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
                const Divider(),
                // Calories
                ListTile(
                  leading: const Icon(
                    Icons.local_fire_department,
                    color: Colors.redAccent,
                  ),
                  title: const Text(
                    'Calo',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightText,
                    ),
                  ),
                  subtitle: Text(
                    '${dish['calories']} kcal',
                    style: TextStyle(color: AppColors.lightTextSecondary),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
