import 'package:daily_calo/models/exercise.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ManageExerciseScreen extends StatefulWidget {
  final Exercise? exercise;

  const ManageExerciseScreen({super.key, this.exercise});

  @override
  State<ManageExerciseScreen> createState() => _ManageExerciseScreenState();
}

class _ManageExerciseScreenState extends State<ManageExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _activityController = TextEditingController();
  final _kcalController = TextEditingController();
  final _timeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.exercise != null) {
      _activityController.text = widget.exercise!.activity;
      _kcalController.text = widget.exercise!.kcal.toString();
      _timeController.text = widget.exercise!.time.toString();
    }
  }

  @override
  void dispose() {
    _activityController.dispose();
    _kcalController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.exercise != null;
    return AlertDialog(
      title: Text(
        isEditMode ? 'Chỉnh sửa bài luyện tập' : 'Thêm bài luyện tập',
        style: const TextStyle(color: AppColors.lightText),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _activityController,
                decoration: _inputDecoration(
                  'Hoạt động',
                  icon: Icons.directions_run,
                ),
                validator:
                    (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Vui lòng nhập hoạt động'
                            : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kcalController,
                decoration: _inputDecoration(
                  'kcal',
                  icon: Icons.local_fire_department,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập lượng kcal';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'kcal phải là số nguyên dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _timeController,
                decoration: _inputDecoration(
                  'Thời gian (phút)',
                  icon: Icons.access_time,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập thời gian';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Thời gian phải là số nguyên dương';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: AppColors.whiteText),
                  label: Text(
                    isEditMode ? 'Lưu chỉnh sửa' : 'Thêm bài luyện tập',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.whiteText,
                    ),
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
                      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
                      final exerciseData = Exercise(
                        id: widget.exercise?.id ?? '',
                        activity: _activityController.text,
                        kcal: int.parse(_kcalController.text),
                        time: int.parse(_timeController.text),
                        userId: isEditMode ? widget.exercise!.userId : userId,
                      );
                      Navigator.pop(context, exerciseData);
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
