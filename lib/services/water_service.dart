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
  DateTime _currentDate = DateTime.now();

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

  // Load dữ liệu nước từ Firestore cho ngày cụ thể
  Future<void> loadWaterData({DateTime? date}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final targetDate = date ?? DateTime.now();
      _currentDate = targetDate;
      final currentDate = DateFormat('dd/MM/yy').format(targetDate);
      final dateCollection = _usersCollection.doc(user.uid).collection('Date');

      final querySnapshot = await dateCollection
          .where('date', isEqualTo: currentDate)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        _waterIntake = data['quantityWater'] ?? 0;
      } else {
        _waterIntake = 0;
      }
      notifyListeners();
    } catch (e) {
      print('Error loading water data: $e');
    }
  }

  // Cập nhật lượng nước uống lên Firestore
  Future<void> updateWaterIntake(int newIntake, {DateTime? date}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final targetDate = date ?? _currentDate;
      _waterIntake = newIntake;
      await _updateWaterIntakeInFirestore(user.uid, newIntake, targetDate);
      notifyListeners();
    } catch (e) {
      print('Error updating water intake: $e');
      throw e;
    }
  }

  // Tăng lượng nước theo step (cho home screen) - 1/8 của mục tiêu
  Future<void> increaseWaterByStep({DateTime? date}) async {
    final newIntake = _waterIntake + (_waterGoal ~/ 8);
    final clampedIntake = newIntake > _waterGoal ? _waterGoal : newIntake;
    await updateWaterIntake(clampedIntake, date: date);
  }

  // Giảm lượng nước theo step (cho home screen) - 1/8 của mục tiêu
  Future<void> decreaseWaterByStep({DateTime? date}) async {
    final newIntake = _waterIntake - (_waterGoal ~/ 8);
    final clampedIntake = newIntake < 0 ? 0 : newIntake;
    await updateWaterIntake(clampedIntake, date: date);
  }

  // Tăng lượng nước theo stepWater (cho profile screen)
  Future<void> increaseWaterByCustomStep({DateTime? date}) async {
    final newIntake = _waterIntake + _stepWater.toInt();
    final clampedIntake = newIntake > _waterGoal ? _waterGoal : newIntake;
    await updateWaterIntake(clampedIntake, date: date);
  }

  // Giảm lượng nước theo stepWater (cho profile screen)
  Future<void> decreaseWaterByCustomStep({DateTime? date}) async {
    final newIntake = _waterIntake - _stepWater.toInt();
    final clampedIntake = newIntake < 0 ? 0 : newIntake;
    await updateWaterIntake(clampedIntake, date: date);
  }

  // Reset lượng nước về 0
  Future<void> resetWaterIntake({DateTime? date}) async {
    await updateWaterIntake(0, date: date);
  }
  // Cập nhật mục tiêu nước dựa trên cân nặng
  void updateWaterGoalByWeight(double weight) {
    _waterGoal = (weight * 30).round(); // 30ml/kg
    _stepWater = _waterGoal / 8; 
    notifyListeners();
  }

  // Method để set ngày hiện tại (được gọi từ HomeController)
  void setCurrentDate(DateTime date) {
    _currentDate = date;
    loadWaterData(date: date);
  }

  Future<void> _updateWaterIntakeInFirestore(String userId, int waterIntake, DateTime date) async {
    final currentDate = DateFormat('dd/MM/yy').format(date);
    final dateCollection = _usersCollection.doc(userId).collection('Date');

    final querySnapshot = await dateCollection
        .where('date', isEqualTo: currentDate)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Document đã tồn tại, chỉ update quantityWater
      final docId = querySnapshot.docs.first.id;
      await dateCollection.doc(docId).update({'quantityWater': waterIntake});
    } else {
      await dateCollection.add({
        'date': currentDate,
        'caloriesNeeded': 0,
        'exercise_id': [],
        'meal_id': [],
        'quantityWater': waterIntake,
      });
    }
  }

  // Reset dữ liệu khi đăng xuất
  void reset() {
    _waterIntake = 0;
    _waterGoal = 1950;
    _stepWater = _waterGoal / 8; 
    _currentDate = DateTime.now();
    notifyListeners();
  }
}