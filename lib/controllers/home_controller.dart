import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/models/health.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:daily_calo/models/meal.dart';
import 'package:daily_calo/services/water_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeController {
  final HealthDailyService _service;
  final WaterService _waterService = WaterService();
  late DateTime _today;
  late int _caloriesNeeded;
  late int _weightGoal;
  late double _currentWeight;
  late double _previousWeight;
  late DateTime _previousWeightDate;
  late String _formattedDate;
  late String _dynamicHeader;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onWaterIntakeChanged;
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('Users');
  final CollectionReference _exercisesCollection = FirebaseFirestore.instance
      .collection('Exercises');
  final CollectionReference _mealCollection = FirebaseFirestore.instance
      .collection('Meals');


  HomeController({
    this.onDateChanged,
    this.onWeightChanged,
    this.onWaterIntakeChanged,
  }) : _service = HealthDailyService() {
    final data = _service.getInitialData();
    _today = data['today'];
    _waterService.loadWaterData();
    _waterService.addListener(_onWaterServiceChanged);
    _caloriesNeeded = data['caloriesNeeded'];
    _weightGoal = data['weightGoal'];
    _currentWeight = data['currentWeight'];
    _previousWeight = data['previousWeight'];
    _previousWeightDate = data['previousWeightDate'];
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);
  }

   void _onWaterServiceChanged() {
    onWaterIntakeChanged?.call(_waterService.waterIntake);
  }

  // Getters
  DateTime get today => _today;
  int get waterGoal => _waterService.waterGoal;
  int get waterIntake => _waterService.waterIntake;
  int get caloriesNeeded => _caloriesNeeded;
  int get weightGoal => _weightGoal;
  double get currentWeight => _currentWeight;
  double get previousWeight => _previousWeight;
  DateTime get previousWeightDate => _previousWeightDate;
  String get formattedDate => _formattedDate;
  String get dynamicHeader => _dynamicHeader;

  Future<void> updateWaterIntake(String userId) async {
    try {
      await _waterService.increaseWaterByStep();
    } catch (e) {
      print('Error updating water intake: $e');
      throw e;
    }
  }

  void updateWeight(double newWeight) {
    _previousWeight = _currentWeight;
    _previousWeightDate = DateTime.now();
    _currentWeight = newWeight;
    onWeightChanged?.call(newWeight);
  }

  void setDate(DateTime date) {
    _today = date;
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);
    onDateChanged?.call(_today);
  }

  Future<DateTime?> showDatePickerDialog(BuildContext context) async {
    return showDatePicker(
      context: context,
      initialDate: _today,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<double?> showWeightDialog(BuildContext context) async {
    TextEditingController weightController = TextEditingController(
      text: _currentWeight.toString(),
    );
    double? newWeight;

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cập nhật cân nặng'),
            content: TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Cân nặng (kg)',
                border: OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () {
                  final weight = double.tryParse(weightController.text);
                  if (weight != null && weight > 0) {
                    newWeight = weight;
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vui lòng nhập cân nặng hợp lệ'),
                      ),
                    );
                  }
                },
                child: const Text('Xác nhận'),
              ),
            ],
          ),
    );

    return newWeight;
  }
  void dispose() {
    _waterService.removeListener(_onWaterServiceChanged);
  }


  Stream<List<Meal>> getMealForCurrentDate(String userId) {
    final currentDate = DateFormat('dd/MM/yy').format(_today);
    return _usersCollection
        .doc(userId)
        .collection('Date')
        .where('date', isEqualTo: currentDate)
        .limit(1)
        .snapshots()
        .asyncMap((dateSnapshot) async {
          if (dateSnapshot.docs.isEmpty) return <Meal>[];

          final dateDoc = dateSnapshot.docs.first;
          final mealIds = List<String>.from(dateDoc['meal_id'] ?? []);

          if (mealIds.isEmpty) return <Meal>[];

          final List<Meal> meals = [];
          for (final mealId in mealIds) {
            final doc = await _mealCollection.doc(mealId).get();
            if (doc.exists && doc['user_id'] == userId) {
              meals.add(
                Meal.fromMap(
                  mealId,
                  doc.data() as Map<String, dynamic>,
                ),
              );
            }
          }

          return meals;
        });
  }

  Future<void> removeMeal(String userId, int index) async {
    final currentDate = DateFormat('dd/MM/yy').format(_today);
    final dateCollection = _usersCollection.doc(userId).collection('Date');

    final querySnapshot =
        await dateCollection
            .where('date', isEqualTo: currentDate)
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) return;

    final doc = querySnapshot.docs.first;
    final mealIds = List<String>.from(doc['meal_id'] ?? []);

    if (index < 0 || index >= mealIds.length) return;

    mealIds.removeAt(index);

    await dateCollection.doc(doc.id).update({'meal_id': mealIds});
  }

  Stream<List<Exercise>> getExercisesForCurrentDate(String userId) {
    final currentDate = DateFormat('dd/MM/yy').format(_today);
    return _usersCollection
        .doc(userId)
        .collection('Date')
        .where('date', isEqualTo: currentDate)
        .limit(1)
        .snapshots()
        .asyncMap((dateSnapshot) async {
          if (dateSnapshot.docs.isEmpty) return <Exercise>[];

          final dateDoc = dateSnapshot.docs.first;
          final exerciseIds = List<String>.from(dateDoc['exercise_id'] ?? []);

          if (exerciseIds.isEmpty) return <Exercise>[];

          final List<Exercise> exercises = [];
          for (final exerciseId in exerciseIds) {
            final doc = await _exercisesCollection.doc(exerciseId).get();
            if (doc.exists && doc['user_id'] == userId) {
              exercises.add(
                Exercise.fromMap(
                  exerciseId,
                  doc.data() as Map<String, dynamic>,
                ),
              );
            }
          }

          return exercises;
        });
  }

  Future<void> removeExercise(String userId, int index) async {
    final currentDate = DateFormat('dd/MM/yy').format(_today);
    final dateCollection = _usersCollection.doc(userId).collection('Date');

    final querySnapshot =
        await dateCollection
            .where('date', isEqualTo: currentDate)
            .limit(1)
            .get();

    if (querySnapshot.docs.isEmpty) return;

    final doc = querySnapshot.docs.first;
    final exerciseIds = List<String>.from(doc['exercise_id'] ?? []);

    if (index < 0 || index >= exerciseIds.length) return;

    // Remove the exercise_id at the specified index
    exerciseIds.removeAt(index);

    // Update the Firestore document with the modified exercise_ids array
    await dateCollection.doc(doc.id).update({'exercise_id': exerciseIds});
  }
}
