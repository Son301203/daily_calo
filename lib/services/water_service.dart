import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class WaterService extends ChangeNotifier {
  static final WaterService _instance = WaterService._internal();
  factory WaterService() => _instance;
  WaterService._internal();

  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('Users');

  int _waterIntake = 0;
  int _waterGoal = 1950;
  double _stepWater = 0; 

  // Getters
  int get waterIntake => _waterIntake;
  int get waterGoal => _waterGoal;
  double get stepWater => _stepWater;

  // Tính progress cho profile screen
  double get waterProgress => (_waterIntake / _waterGoal).clamp(0.0, 1.0);

  set stepWater(double value) {
    _stepWater = value;
    notifyListeners();
  }

  set waterGoal(int value) {
    _waterGoal = value;
    _stepWater = value / 8; 
    notifyListeners();
  }

  // Load dữ liệu nước từ Firestore cho ngày hiện tại
  Future<void> loadWaterData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final currentDate = DateFormat('dd/MM/yy').format(DateTime.now());
      final dateCollection = _usersCollection.doc(user.uid).collection('Date');

      final querySnapshot = await dateCollection
          .where('date', isEqualTo: currentDate)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
        _waterIntake = data['quantity_water'] ?? 0;
      } else {
        _waterIntake = 0;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading water data: $e');
    }
  }

  // Cập nhật lượng nước uống lên Firestore
  Future<void> updateWaterIntake(int newIntake) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      _waterIntake = newIntake;
      await _updateWaterIntakeInFirestore(user.uid, newIntake);
      notifyListeners();
    } catch (e) {
      print('Error updating water intake: $e');
      throw e;
    }
  }

  // Tăng lượng nước theo step (cho home screen)
  Future<void> increaseWaterByStep() async {
    final newIntake = _waterIntake + (_waterGoal ~/ 8);
    final clampedIntake = newIntake > _waterGoal ? _waterGoal : newIntake;
    await updateWaterIntake(clampedIntake);
  }

  // Tăng lượng nước theo stepWater (cho profile screen)
  Future<void> increaseWaterByCustomStep() async {
    final newIntake = _waterIntake + _stepWater.toInt();
    final clampedIntake = newIntake > _waterGoal ? _waterGoal : newIntake;
    await updateWaterIntake(clampedIntake);
  }

  // Giảm lượng nước theo stepWater (cho profile screen)
  Future<void> decreaseWaterByCustomStep() async {
    final newIntake = _waterIntake - _stepWater.toInt();
    final clampedIntake = newIntake < 0 ? 0 : newIntake;
    await updateWaterIntake(clampedIntake);
  }

  // Cập nhật mục tiêu nước dựa trên cân nặng
  void updateWaterGoalByWeight(double weight) {
    _waterGoal = (weight * 30).round(); // 30ml/kg
    _stepWater = _waterGoal / 8; 
    notifyListeners();
  }

  Future<void> _updateWaterIntakeInFirestore(String userId, int waterIntake) async {
    final currentDate = DateFormat('dd/MM/yy').format(DateTime.now());
    final dateCollection = _usersCollection.doc(userId).collection('Date');

    final querySnapshot = await dateCollection
        .where('date', isEqualTo: currentDate)
        .limit(1)
        .get();

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

  // Reset dữ liệu khi đăng xuất
  void reset() {
    _waterIntake = 0;
    _waterGoal = 1950;
    _stepWater = _waterGoal / 8; 
    notifyListeners();
  }
}