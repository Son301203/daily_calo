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
  final List<String> _meals = ['Bữa sáng', 'Bữa trưa', 'Bữa tối'];
  int _selectedMealIndex = 0;

  final List<Map<String, dynamic>> _dishes = [
    {
      'name': 'Cháo yến mạch',
      'serving_size': 200,
      'protein': 5,
      'period_time': 'Bữa sáng',
      'fat': 2.5,
      'carbs': 27,
      'calories': 150,
    },
    {
      'name': 'Cháo',
      'serving_size': 250,
      'protein': 6,
      'period_time': 'Bữa sáng',
      'fat': 3.0,
      'carbs': 30,
      'calories': 250,
    },
    {
      'name': 'Cơm chiên trứng',
      'serving_size': 300,
      'protein': 10,
      'period_time': 'Bữa trưa',
      'fat': 12.0,
      'carbs': 40,
      'calories': 300,
    },
    {
      'name': 'Salad rau củ',
      'serving_size': 150,
      'protein': 2,
      'period_time': 'Bữa tối',
      'fat': 1.0,
      'carbs': 15,
      'calories': 100,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDishes = _dishes.where((dish) => dish['period_time'] == _meals[_selectedMealIndex]).toList();

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
              final newDish = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ManageMealScreen()),
              );
              if (newDish != null) {
                setState(() {
                  _dishes.add(newDish);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm ${newDish['name']}')),
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
              children: _meals.asMap().entries.map((entry) {
                int index = entry.key;
                String meal = entry.value;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMealIndex = index;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _selectedMealIndex == index ? AppColors.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Text(
                      meal,
                      style: TextStyle(
                        fontWeight: _selectedMealIndex == index ? FontWeight.bold : FontWeight.normal,
                        color: _selectedMealIndex == index ? AppColors.primary : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // List Meal
          Expanded(
            child: ListView.builder(
              itemCount: filteredDishes.length,
              itemBuilder: (context, index) {
                final dish = filteredDishes[index];
                return ListTile(
                  title: Text(dish['name']),
                  subtitle: Text("${dish['period_time']} - ${dish['calories']} kcal"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final updatedDish = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ManageMealScreen(dish: dish),
                            ),
                          );
                          if (updatedDish != null) {
                            setState(() {
                              final dishIndex = _dishes.indexWhere((item) => item['name'] == dish['name']);
                              if (dishIndex != -1) {
                                _dishes[dishIndex] = updatedDish;
                              }
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Đã cập nhật ${updatedDish['name']}')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _dishes.removeWhere((item) => item['name'] == dish['name']);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã xóa ${dish['name']}')),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailScreen(dish: dish),
                      ),
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