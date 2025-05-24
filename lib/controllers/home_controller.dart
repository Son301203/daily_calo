import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/models/health.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeController {
  final HealthDailyService _service;
  late DateTime _today;
  late int _waterGoal;
  late int _waterIntake;
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
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  HomeController({
    this.onDateChanged,
    this.onWeightChanged,
    this.onWaterIntakeChanged,
  }) : _service = HealthDailyService() {
    final data = _service.getInitialData();
    _today = data['today'];
    _waterGoal = data['waterGoal'];
    _waterIntake = data['waterIntake'];
    _caloriesNeeded = data['caloriesNeeded'];
    _weightGoal = data['weightGoal'];
    _currentWeight = data['currentWeight'];
    _previousWeight = data['previousWeight'];
    _previousWeightDate = data['previousWeightDate'];
    _formattedDate = DateFormat('d \'th\' M').format(_today);
    _dynamicHeader = _service.getDynamicHeader(_today);
  }

  // Getters
  DateTime get today => _today;
  int get waterGoal => _waterGoal;
  int get waterIntake => _waterIntake;
  int get caloriesNeeded => _caloriesNeeded;
  int get weightGoal => _weightGoal;
  double get currentWeight => _currentWeight;
  double get previousWeight => _previousWeight;
  DateTime get previousWeightDate => _previousWeightDate;
  String get formattedDate => _formattedDate;
  String get dynamicHeader => _dynamicHeader;

  Future<void> updateWaterIntake(String userId) async {
    _waterIntake = _service.calculateWaterIntake(
      _waterIntake,
      _waterGoal,
      _waterGoal ~/ 8,
    );
    await _updateWaterIntakeInFirestore(userId, _waterIntake);
    onWaterIntakeChanged?.call(_waterIntake);
  }

  Future<void> _updateWaterIntakeInFirestore(String userId, int waterIntake) async {
    final currentDate = DateFormat('dd/MM/yy').format(_today);
    final dateCollection = _usersCollection.doc(userId).collection('Date');

    final querySnapshot =
        await dateCollection.where('date', isEqualTo: currentDate).limit(1).get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      await dateCollection.doc(docId).update({'quantity_water': waterIntake});
    } else {
      await dateCollection.add({
        'date': currentDate,
        'exercise_id': [],
        'meal_id': [],
        'quantity_water': waterIntake,
      });
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
    TextEditingController weightController =
        TextEditingController(text: _currentWeight.toString());
    double? newWeight;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật cân nặng'),
        content: TextField(
          controller: weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  const SnackBar(content: Text('Vui lòng nhập cân nặng hợp lệ')),
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
}