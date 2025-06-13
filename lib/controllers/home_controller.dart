import 'dart:async';
import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/models/health.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:daily_calo/models/meal.dart';
import 'package:daily_calo/services/water_service.dart';
import 'package:daily_calo/utils/app_color.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeController {
  final HealthDailyService _service;
  final WaterService _waterService = WaterService();
  late DateTime _today;
  late int _caloriesNeeded;
  late int _baseCaloriesNeeded;
  late double _currentWeight;
  late double _previousWeight;
  late DateTime _previousWeightDate;
  late String _formattedDate;
  late String _dynamicHeader;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onWaterIntakeChanged;
  final ValueChanged<int>? onCaloriesNeededChanged;
  final CollectionReference _usersCollection = FirebaseFirestore.instance
      .collection('Users');
  final CollectionReference _exercisesCollection = FirebaseFirestore.instance
      .collection('Exercises');
  final CollectionReference _mealCollection = FirebaseFirestore.instance
      .collection('Meals');
  final String? _userId;
  StreamSubscription<DocumentSnapshot>? _weightSubscription;
  StreamSubscription<Map<String, int>>? _caloriesSubscription;

  HomeController({
    this.onDateChanged,
    this.onWeightChanged,
    this.onWaterIntakeChanged,
    this.onCaloriesNeededChanged,
    String? userId,
  }) : _service = HealthDailyService(),
       _userId = userId ?? FirebaseAuth.instance.currentUser?.uid {
    _waterService.addListener(_onWaterServiceChanged);
    _listenToWeightChanges();
    _initializeData().then((_) {
      _listenToCaloriesChanges();
    });
  }

  Future<void> _initializeData() async {
    final data = await _service.getInitialData();
    _today = data['today'];
    _caloriesNeeded = 0;
    _waterService.loadWaterData();
    _currentWeight = data['currentWeight'];
    _previousWeight = data['previousWeight'];
    _previousWeightDate = data['previousWeightDate'];
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);

    if (_userId != null) {
      final userDoc = await _usersCollection.doc(_userId).get();
      if (userDoc.exists) {
        final weight =
            (userDoc.data() as Map<String, dynamic>)['weight']?.toDouble() ??
            _currentWeight;
        _currentWeight = weight;
        _baseCaloriesNeeded = (weight * 24).round();
        await _getCaloriesNeededDaily(_today);
      } else {
        _baseCaloriesNeeded = (_currentWeight * 24).round();
        _caloriesNeeded = _baseCaloriesNeeded;
        onCaloriesNeededChanged?.call(_caloriesNeeded);
      }
    }
  }

  void _listenToWeightChanges() {
    if (_userId == null) return;
    _weightSubscription = _usersCollection.doc(_userId).snapshots().listen((
      snapshot,
    ) async {
      if (snapshot.exists) {
        final weight =
            (snapshot.data() as Map<String, dynamic>)['weight']?.toDouble() ??
            _currentWeight;
        if (weight != _currentWeight) {
          _currentWeight = weight;
          _baseCaloriesNeeded = (weight * 24).round();
          await _getCaloriesNeededDaily(_today);
          onWeightChanged?.call(_currentWeight);
        }
      }
    });
  }

  void _listenToCaloriesChanges() {
    if (_userId == null) return;
    final combinedStream =
        StreamGroup.merge([
          getTotalCaloriesBurned(_userId).map((burned) => {'burned': burned}),
          getTotalCaloriesIntake(_userId).map((intake) => {'intake': intake}),
        ]).asBroadcastStream();

    int latestBurned = 0;
    int latestIntake = 0;

    _caloriesSubscription = combinedStream.listen((event) async {
      if (event.containsKey('burned')) {
        latestBurned = event['burned']!;
      } else if (event.containsKey('intake')) {
        latestIntake = event['intake']!;
      }
      _caloriesNeeded = _baseCaloriesNeeded - latestIntake + latestBurned;
      await _saveCaloriesNeededDaily(_today, _caloriesNeeded);
      onCaloriesNeededChanged?.call(_caloriesNeeded);
    });
  }

  Future<void> _getCaloriesNeededDaily(DateTime date) async {
    if (_userId == null) return;
    final currentDate = DateFormat('dd/MM/yy').format(date);
    final dateCollection = _usersCollection.doc(_userId).collection('Date');

    final querySnapshot =
        await dateCollection
            .where('date', isEqualTo: currentDate)
            .limit(1)
            .get();
    int totalIntake = 0;
    int totalBurned = 0;

    if (querySnapshot.docs.isNotEmpty) {
      final doc = querySnapshot.docs.first;
      final mealIds = List<String>.from(doc['meal_id'] ?? []);
      final exerciseIds = List<String>.from(doc['exercise_id'] ?? []);

      // Calculate total calories intake
      for (final mealId in mealIds) {
        final mealDoc = await _mealCollection.doc(mealId).get();
        if (mealDoc.exists && mealDoc['user_id'] == _userId) {
          final meal = Meal.fromMap(
            mealId,
            mealDoc.data() as Map<String, dynamic>,
          );
          totalIntake += meal.calo;
        }
      }

      // Calculate total calories burned
      for (final exerciseId in exerciseIds) {
        final exerciseDoc = await _exercisesCollection.doc(exerciseId).get();
        if (exerciseDoc.exists && exerciseDoc['user_id'] == _userId) {
          final exercise = Exercise.fromMap(
            exerciseId,
            exerciseDoc.data() as Map<String, dynamic>,
          );
          totalBurned += exercise.kcal;
        }
      }

      // Calculate calories needed
      final calculatedCaloriesNeeded =
          _baseCaloriesNeeded - totalIntake + totalBurned;
      _caloriesNeeded = calculatedCaloriesNeeded;

      // Update Firestore
      if (doc['caloriesNeeded']?.toInt() != calculatedCaloriesNeeded) {
        await _saveCaloriesNeededDaily(date, _caloriesNeeded);
      }
    } else {
      _caloriesNeeded = _baseCaloriesNeeded;
      await dateCollection.add({
        'date': currentDate,
        'caloriesNeeded': _caloriesNeeded,
        'meal_id': [],
        'exercise_id': [],
        'quantityWater': 0,
      });
    }
    onCaloriesNeededChanged?.call(_caloriesNeeded);
  }

  Future<void> _saveCaloriesNeededDaily(
    DateTime date,
    int caloriesNeeded,
  ) async {
    if (_userId == null) return;
    final currentDate = DateFormat('dd/MM/yy').format(date);
    final dateCollection = _usersCollection.doc(_userId).collection('Date');

    final querySnapshot =
        await dateCollection
            .where('date', isEqualTo: currentDate)
            .limit(1)
            .get();
    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await dateCollection.doc(docId).update({
        'caloriesNeeded': caloriesNeeded,
      });
    } else {
      await dateCollection.add({
        'date': currentDate,
        'caloriesNeeded': caloriesNeeded,
        'meal_id': [],
        'exercise_id': [],
        'quantityWater': 0,
      });
    }
  }

  void _onWaterServiceChanged() {
    onWaterIntakeChanged?.call(_waterService.waterIntake);
  }

  // Getters
  DateTime get today => _today;
  int get waterGoal => _waterService.waterGoal;
  int get waterIntake => _waterService.waterIntake;
  int get caloriesNeeded => _caloriesNeeded;
  double get currentWeight => _currentWeight;
  double get previousWeight => _previousWeight;
  DateTime get previousWeightDate => _previousWeightDate;
  String get formattedDate => _formattedDate;
  String get dynamicHeader => _dynamicHeader;



  Future<void> decreaseWaterIntake(String userId) async {
    try {
      await _waterService.decreaseWaterByCustomStep(date: _today);
    } catch (e, stackTrace) {
      print('Error decreasing water intake: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
  Future<void> increaseWaterIntake(String userId) async {
    try {
      await _waterService.increaseWaterByCustomStep(date: _today);
    } catch (e, stackTrace) {
      print('Error increasing water intake: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> resetWaterIntake(String userId) async {
    try {
      await _waterService.resetWaterIntake(date: _today);
    } catch (e, stackTrace) {
      print('Error resetting water intake: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  void updateWeight(double newWeight) async {
    _previousWeight = _currentWeight;
    _previousWeightDate = DateTime.now();
    _currentWeight = newWeight;
    _baseCaloriesNeeded = (newWeight * 24).round();
    await _getCaloriesNeededDaily(_today);

    if (_userId != null) {
      try {
        await _usersCollection.doc(_userId).update({
          'weight': newWeight,
          'weightUpdatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } catch (e) {
        throw e;
      }
    }

    onWeightChanged?.call(_currentWeight);
  }

void setDate(DateTime date) async {
  _today = date;
  _formattedDate = DateFormat('d \'th\' M').format(_today);
  _dynamicHeader = _service.getDynamicHeader(_today);
  await _getCaloriesNeededDaily(_today);
  await _waterService.loadWaterData(date: _today);
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
                        backgroundColor: AppColors.error,
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
    _weightSubscription?.cancel();
    _caloriesSubscription?.cancel();
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
            try {
              final doc = await _mealCollection.doc(mealId).get();
              if (doc.exists && doc['user_id'] == userId) {
                meals.add(
                  Meal.fromMap(mealId, doc.data() as Map<String, dynamic>),
                );
              }
            } catch (e) {
              print('Error fetching meal $mealId: $e');
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
    await _getCaloriesNeededDaily(_today);
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
            try {
              final doc = await _exercisesCollection.doc(exerciseId).get();
              if (doc.exists && doc['user_id'] == userId) {
                exercises.add(
                  Exercise.fromMap(
                    exerciseId,
                    doc.data() as Map<String, dynamic>,
                  ),
                );
              }
            } catch (e) {
              print('Error fetching exercise $exerciseId: $e');
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

    exerciseIds.removeAt(index);
    await dateCollection.doc(doc.id).update({'exercise_id': exerciseIds});
    await _getCaloriesNeededDaily(_today);
  }

  Stream<int> getTotalCaloriesBurned(String userId) {
    return getExercisesForCurrentDate(userId).map((exercises) {
      return exercises.fold(0, (sum, exercise) => sum + exercise.kcal);
    });
  }

  Stream<int> getTotalCaloriesIntake(String userId) {
    return getMealForCurrentDate(userId).map((meals) {
      return meals.fold(0, (sum, meal) => sum + meal.calo);
    });
  }
}
