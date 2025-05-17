import 'package:daily_calo/controllers/exercise_controller.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'manage_exercise_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final ExerciseController controller = ExerciseController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tập luyện',
          style: TextStyle(color: AppColors.whiteText),
        ),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.whiteText),
            onPressed: () async {
              // Show AlertDialog for adding a new exercise
              final newExercise = await showDialog<Exercise>(
                context: context,
                builder: (context) => const ManageExerciseScreen(),
              );
              if (newExercise != null && context.mounted) {
                await controller.addEx(newExercise);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã thêm ${newExercise.activity}'), backgroundColor: AppColors.success,),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: controller.getExercises(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Có lỗi xảy ra'));
          }
          final exercises = snapshot.data ?? [];
          if (exercises.isEmpty) {
            return const Center(child: Text('Chưa có bài tập nào'));
          }
          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return ListTile(
                title: Text(exercise.activity),
                subtitle: Text('${exercise.time} phút - ${exercise.kcal} kcal'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () async {
                        // Show AlertDialog for editing the exercise
                        final updatedExercise = await showDialog<Exercise>(
                          context: context,
                          builder: (context) => ManageExerciseScreen(exercise: exercise),
                        );
                        if (updatedExercise != null && context.mounted) {
                          await controller.updateEx(updatedExercise);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã cập nhật ${updatedExercise.activity}'), backgroundColor: AppColors.success,),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await controller.deleteEx(exercise.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã xóa ${exercise.activity}'), backgroundColor: AppColors.success,),
                          );
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}