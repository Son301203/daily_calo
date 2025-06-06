import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:daily_calo/models/user.dart';
import 'package:daily_calo/services/user_service.dart';
import 'package:daily_calo/services/water_service.dart';

class ProfileController with ChangeNotifier {
  static final ProfileController _instance = ProfileController._internal();
  factory ProfileController() => _instance;
  ProfileController._internal();
  final UserService _userService = UserService();
  DateTime _today = DateTime.now();

  DateTime get today => _today;

  final WaterService _waterService = WaterService();

  UserModel? user;
  DateTime? weightUpdatedAt;
  bool isLoading = false;

  void setDate(DateTime date) async {
    _today = date;
    await _waterService.loadWaterData(date: _today);
    notifyListeners();
  }

  void _onWaterServiceChanged() {
    notifyListeners();
  }

  double get currentWater => _waterService.waterIntake.toDouble();
  double get stepWater => _waterService.stepWater;
  double get targetWater => _waterService.waterGoal.toDouble();

  String get userName => user?.name ?? 'Người dùng';
  double get userHeight => user?.height ?? 0;
  double get userWeight => user?.weight ?? 0;
  String get userEmail => user?.gmail ?? '';

  set targetWater(double value) {
    _waterService.waterGoal = value.toInt();
    notifyListeners();
  }

  // Tính BMI
  double calculateBMI() {
    if (user == null || userHeight <= 0) return 0;
    double heightInMeters = userHeight / 100;
    return userWeight / (heightInMeters * heightInMeters);
  }

  // Tính lượng nước cần uống (mL)
  int calculateWaterIntake() {
    if (user == null) return 0;
    return (userWeight * 30).round(); // 30ml/kg
  }

  // Load dữ liệu hồ sơ
  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    final result = await _userService.fetchCurrentUserWithWeightUpdate();
    if (result != null) {
      user = result['user'] as UserModel;
      weightUpdatedAt = result['weightUpdatedAt'] as DateTime?;
      if (user?.weight != null) {
        _waterService.updateWaterGoalByWeight(user!.weight);
      }
    } else {
      user = null;
      weightUpdatedAt = null;
    }
    await _waterService.loadWaterData(date: _today);
    isLoading = false;
    notifyListeners();
  }

  // Đăng xuất
  Future<void> signOut() async {
    await _userService.signOut();
    _waterService.reset();
  }

  // Cập nhật hồ sơ
  Future<void> updateUserProfile({
    required String name,
    required double height,
    required double weight,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _userService.updateUserProfile(
        name: name,
        height: height,
        weight: weight,
      );

      await loadUserProfile();
    } catch (e) {
      throw Exception('Lỗi khi cập nhật hồ sơ: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> decreaseWaterIntake(String userId) async {
    await _waterService.decreaseWaterByCustomStep(date: _today);
    notifyListeners();
  }

  Future<void> increaseWaterIntake(String userId) async {
    await _waterService.increaseWaterByCustomStep(date: _today);
    notifyListeners();
  }

  // Định dạng ngày cập nhật cân nặng
  String formatWeightUpdateDate() {
    if (weightUpdatedAt == null) return "Chưa cập nhật";
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(weightUpdatedAt!);
  }

  // Tính tiến trình uống nước
  double calculateProgress() {
    return _waterService.waterProgress;
  }

  @override
  void dispose() {
    _waterService.removeListener(_onWaterServiceChanged);
    super.dispose();
  }
}
