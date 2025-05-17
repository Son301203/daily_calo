import 'package:daily_calo/utils/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:daily_calo/models/meal.dart';

class ManageMealScreen extends StatefulWidget {
  final Meal? meal;

  const ManageMealScreen({super.key, this.meal});

  @override
  State<ManageMealScreen> createState() => _ManageMealScreenState();
}

class _ManageMealScreenState extends State<ManageMealScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final servingSizeController = TextEditingController();
  final proteinController = TextEditingController();
  final fatController = TextEditingController();
  final carbsController = TextEditingController();
  final caloriesController = TextEditingController();
  String? selectedPeriodTime;

  final List<String> periodTimes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối'];

  @override
  void initState() {
    super.initState();
    if (widget.meal != null) {
      nameController.text = widget.meal!.title;
      servingSizeController.text = widget.meal!.servingSize.toString();
      proteinController.text = widget.meal!.protein.toString();
      fatController.text = widget.meal!.fat.toString();
      carbsController.text = widget.meal!.carbs.toString();
      caloriesController.text = widget.meal!.calo.toString();
      selectedPeriodTime = widget.meal!.periodTime;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    servingSizeController.dispose();
    proteinController.dispose();
    fatController.dispose();
    carbsController.dispose();
    caloriesController.dispose();
    super.dispose();
  }

  InputDecoration inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.meal != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Chỉnh sửa món ăn' : 'Thêm món ăn',
          style: const TextStyle(color: AppColors.whiteText),
        ),
        backgroundColor: AppColors.primary,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              const Text(
                'Thông tin món ăn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: nameController,
                decoration: inputDecoration('Tên món ăn', icon: Icons.fastfood),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập tên món ăn' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: servingSizeController,
                decoration: inputDecoration('Serving size (g)', icon: Icons.scale),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập serving size';
                  if (int.tryParse(value) == null) return 'Serving size phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: proteinController,
                decoration: inputDecoration('Protein (g)', icon: Icons.fitness_center),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập protein';
                  if (int.tryParse(value) == null) return 'Protein phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: inputDecoration('Thời gian bữa ăn', icon: Icons.schedule),
                value: selectedPeriodTime,
                items: periodTimes.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedPeriodTime = value),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn thời gian bữa ăn' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: fatController,
                decoration: inputDecoration('Fat (g)', icon: Icons.oil_barrel),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập fat';
                  if (double.tryParse(value) == null) return 'Fat phải là số';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: carbsController,
                decoration: inputDecoration('Carbs (g)', icon: Icons.cake),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập carbs';
                  if (int.tryParse(value) == null) return 'Carbs phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: caloriesController,
                decoration: inputDecoration('Calo (kcal)', icon: Icons.local_fire_department),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập calo';
                  if (int.tryParse(value) == null) return 'Calo phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: AppColors.whiteText,),
                  label: Text(
                    isEditMode ? 'Lưu chỉnh sửa' : 'Thêm món ăn',
                    style: const TextStyle(fontSize: 16, color: AppColors.whiteText),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final mealData = Meal(
                        id: widget.meal?.id ?? '',
                        title: nameController.text,
                        servingSize: int.parse(servingSizeController.text),
                        protein: int.parse(proteinController.text),
                        periodTime: selectedPeriodTime!,
                        fat: double.parse(fatController.text),
                        carbs: int.parse(carbsController.text),
                        calo: int.parse(caloriesController.text),
                        userId: isEditMode ? widget.meal!.userId : userId,
                      );
                      Navigator.pop(context, mealData);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}