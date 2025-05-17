import 'package:daily_calo/utils/app_color.dart';
import 'package:flutter/material.dart';

class ManageMealScreen extends StatefulWidget {
  final Map<String, dynamic>? dish;

  const ManageMealScreen({super.key, this.dish});

  @override
  State<ManageMealScreen> createState() => _ManageMealScreenState();
}

class _ManageMealScreenState extends State<ManageMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbsController = TextEditingController();
  final _caloriesController = TextEditingController();
  String? _selectedPeriodTime;

  final List<String> _periodTimes = ['Bữa sáng', 'Bữa trưa', 'Bữa tối'];

  @override
  void initState() {
    super.initState();
    // Điền sẵn dữ liệu nếu dish được truyền vào
    if (widget.dish != null) {
      _nameController.text = widget.dish!['name'];
      _servingSizeController.text = widget.dish!['serving_size'].toString();
      _proteinController.text = widget.dish!['protein'].toString();
      _fatController.text = widget.dish!['fat'].toString();
      _carbsController.text = widget.dish!['carbs'].toString();
      _caloriesController.text = widget.dish!['calories'].toString();
      _selectedPeriodTime = widget.dish!['period_time'];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _proteinController.dispose();
    _fatController.dispose();
    _carbsController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
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
    final isEditMode = widget.dish != null;

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
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Thông tin món ăn',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Tên món ăn', icon: Icons.fastfood),
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Vui lòng nhập tên món ăn' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _servingSizeController,
                decoration: _inputDecoration('Serving size (g)', icon: Icons.scale),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập serving size';
                  if (int.tryParse(value) == null) return 'Serving size phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _proteinController,
                decoration: _inputDecoration('Protein (g)', icon: Icons.fitness_center),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập protein';
                  if (int.tryParse(value) == null) return 'Protein phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDecoration('Thời gian bữa ăn', icon: Icons.schedule),
                value: _selectedPeriodTime,
                items: _periodTimes.map((period) {
                  return DropdownMenuItem(
                    value: period,
                    child: Text(period),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedPeriodTime = value),
                validator: (value) =>
                    value == null ? 'Vui lòng chọn thời gian bữa ăn' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _fatController,
                decoration: _inputDecoration('Fat (g)', icon: Icons.oil_barrel),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập fat';
                  if (double.tryParse(value) == null) return 'Fat phải là số';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _carbsController,
                decoration: _inputDecoration('Carbs (g)', icon: Icons.cake),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Vui lòng nhập carbs';
                  if (int.tryParse(value) == null) return 'Carbs phải là số nguyên';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                decoration: _inputDecoration('Calo (kcal)', icon: Icons.local_fire_department),
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
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditMode ? 'Lưu chỉnh sửa' : 'Thêm món ăn',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final dishData = {
                        'name': _nameController.text,
                        'serving_size': int.parse(_servingSizeController.text),
                        'protein': int.parse(_proteinController.text),
                        'period_time': _selectedPeriodTime,
                        'fat': double.parse(_fatController.text),
                        'carbs': int.parse(_carbsController.text),
                        'calories': int.parse(_caloriesController.text),
                      };
                      Navigator.pop(context, dishData);
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