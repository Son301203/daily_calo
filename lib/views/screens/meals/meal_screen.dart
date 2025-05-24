import 'package:daily_calo/controllers/meal_management_controller.dart';
import 'package:daily_calo/models/meal.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'manage_meal_screen.dart';
import 'meal_detail_screen.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  final List<String> meals = ['Bữa sáng', 'Bữa trưa', 'Bữa tối'];
  int selectedMealIndex = 0;

  final MealManagementController controller = MealManagementController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Bữa ăn',
          style: TextStyle(color: AppColors.whiteText),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            color: AppColors.whiteText,
            onPressed: () async {
              final newMeal = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageMealScreen(),
                ),
              );
              if (newMeal != null) {
                await controller.addMeal(newMeal);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm ${newMeal.title}')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Navigator
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  meals.asMap().entries.map((entry) {
                    int index = entry.key;
                    String meal = entry.value;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedMealIndex = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color:
                                  selectedMealIndex == index
                                      ? AppColors.primary
                                      : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          meal,
                          style: TextStyle(
                            fontWeight:
                                selectedMealIndex == index
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            color:
                                selectedMealIndex == index
                                    ? AppColors.primary
                                    : Colors.black,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
          // List Meal
          Expanded(
            child: StreamBuilder<List<Meal>>(
              stream: controller.getMealType(meals[selectedMealIndex]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Co lỗi xay ra'));
                }
                final dishs = snapshot.data ?? [];
                return ListView.builder(
                  itemCount: dishs.length,
                  itemBuilder: (context, index) {
                    final dish = dishs[index];
                    return ListTile(
                      title: Text(dish.title),
                      subtitle: Text("${dish.periodTime} - ${dish.calo} kcal"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                      icon: const Icon(Icons.add, color: Colors.blue),
                      onPressed: () async {
                        await controller.addDishToDate(dish.id);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Đã thêm ${dish.title} vào ngày hôm nay',
                                ),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                      },
                    ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () async {
                              final updatedMeal = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageMealScreen(meal: dish),
                                ),
                              );
                              if (updatedMeal != null) {
                                await controller.updateMeal(updatedMeal); 
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã cập nhật ${updatedMeal.title}')),
                                  );
                                }
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await controller.deleteMeal(dish.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Đã xóa ${dish.title}')),
                                );
                              }
                            },
                          ),
                        ]
                      ),
                      onTap: (){
                        Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MealDetailScreen(meal: dish) ) 
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
