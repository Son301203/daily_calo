import 'dart:async';
import 'package:async/async.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/models/health.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:daily_calo/models/meal.dart';
import 'package:daily_calo/services/water_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeController {
  final HealthDailyService _service;
  final WaterService _waterService = WaterService();
  late DateTime _today;
  late int _caloriesNeeded;
  late int _baseCaloriesNeeded;
  late int _weightGoal;
  late double _currentWeight;
  late double _previousWeight;
  late DateTime _previousWeightDate;
  late String _formattedDate;
  late String _dynamicHeader;
  final ValueChanged<DateTime>? onDateChanged;
  final ValueChanged<double>? onWeightChanged;
  final ValueChanged<int>? onWaterIntakeChanged;
  final ValueChanged<int>? onCaloriesNeededChanged;
  final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('Users');
  final CollectionReference _exercisesCollection = FirebaseFirestore.instance.collection('Exercises');
  final CollectionReference _mealCollection = FirebaseFirestore.instance.collection('Meals');
  final String? _userId;
  StreamSubscription<DocumentSnapshot>? _weightSubscription;
  StreamSubscription<Map<String, int>>? _caloriesSubscription; // Updated to handle combined stream

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
    _waterService.loadWaterData();
    _weightGoal = data['weightGoal'];
    _currentWeight = data['currentWeight'];
    _previousWeight = data['previousWeight'];
    _previousWeightDate = data['previousWeightDate'];
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);

    if (_userId != null) {
      final userDoc = await _usersCollection.doc(_userId).get();
      if (userDoc.exists) {
        final weight = (userDoc.data() as Map<String, dynamic>)['weight']?.toDouble() ?? _currentWeight;
        _currentWeight = weight;
        _baseCaloriesNeeded = (weight * 24).round();
        _caloriesNeeded = _baseCaloriesNeeded;
        onCaloriesNeededChanged?.call(_caloriesNeeded);
      }
    }
  }

  void _listenToWeightChanges() {
    if (_userId == null) return;
    _weightSubscription = _usersCollection.doc(_userId).snapshots().listen(
      (snapshot) {
        if (snapshot.exists) {
          final weight = (snapshot.data() as Map<String, dynamic>)['weight']?.toDouble() ?? _currentWeight;
          if (weight != _currentWeight) {
            _currentWeight = weight;
            _baseCaloriesNeeded = (weight * 24).round();
            _caloriesNeeded = _baseCaloriesNeeded; 
            onWeightChanged?.call(_currentWeight);
            onCaloriesNeededChanged?.call(_caloriesNeeded);
          }
        }
      },
      onError: (error) {
        print('Error listening to weight changes: $error');
      },
    );
  }

  // Updated method to listen to both calories burned and intake
  void _listenToCaloriesChanges() {
    if (_userId == null) return;
    final combinedStream = StreamGroup.merge([
      getTotalCaloriesBurned(_userId!).map((burned) => {'burned': burned}),
      getTotalCaloriesIntake(_userId!).map((intake) => {'intake': intake}),
    ]).asBroadcastStream();

    int latestBurned = 0;
    int latestIntake = 0;

    _caloriesSubscription = combinedStream.listen(
      (event) {
        if (event.containsKey('burned')) {
          latestBurned = event['burned']!;
        } else if (event.containsKey('intake')) {
          latestIntake = event['intake']!;
        }
        // Update calories needed based on both values
        _caloriesNeeded = _baseCaloriesNeeded - latestIntake + latestBurned;
        onCaloriesNeededChanged?.call(_caloriesNeeded);
      },
      onError: (error) {
        print('Error listening to calories changes: $error');
      },
    );
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

  void updateWeight(double newWeight) async {
    _previousWeight = _currentWeight;
    _previousWeightDate = DateTime.now();
    _currentWeight = newWeight;
    _baseCaloriesNeeded = (newWeight * 24).round();
    _caloriesNeeded = _baseCaloriesNeeded; 

    if (_userId != null) {
      await _usersCollection.doc(_userId).update({
        'weight': newWeight,
        'weightUpdatedAt': Timestamp.fromDate(DateTime.now()),
      });
    }

    onWeightChanged?.call(newWeight);
    onCaloriesNeededChanged?.call(_caloriesNeeded);
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
      builder: (context) => AlertDialog(
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
            final doc = await _mealCollection.doc(mealId).get();
            if (doc.exists && doc['user_id'] == userId) {
              meals.add(
                Meal.fromMap(mealId, doc.data() as Map<String, dynamic>),
              );
            }
          }

          return meals;
        });
  }

  Future<void> removeMeal(String userId, int index) async {
    final currentDate = DateFormat('dd/MM/yy').format(_today);
    final dateCollection = _usersCollection.doc(userId).collection('Date');

    final querySnapshot = await dateCollection.where('date', isEqualTo: currentDate).limit(1).get();

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

    final querySnapshot = await dateCollection.where('date', isEqualTo: currentDate).limit(1).get();

    if (querySnapshot.docs.isEmpty) return;

    final doc = querySnapshot.docs.first;
    final exerciseIds = List<String>.from(doc['exercise_id'] ?? []);

    if (index < 0 || index >= exerciseIds.length) return;

    exerciseIds.removeAt(index);

    await dateCollection.doc(doc.id).update({'exercise_id': exerciseIds});
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