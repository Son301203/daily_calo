import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';

class ProfileController with ChangeNotifier {
  final UserService _userService = UserService();

  UserModel? user;
  DateTime? weightUpdatedAt;
  bool isLoading = false;

  String get userName => user?.name ?? 'Người dùng';
  double get userHeight => user?.height ?? 0;
  double get userWeight => user?.weight ?? 0;
  String get userEmail => user?.gmail ?? '';

  double calculateBMI() {
    if (user == null || user!.height <= 0) return 0;
    double heightInMeters = user!.height / 100;
    return user!.weight / (heightInMeters * heightInMeters);
  }

  int calculateWaterIntake() {
    if (user == null) return 0;
    return (user!.weight * 0.03 * 1000).round();
  }

  Future<void> loadUserProfile() async {
    isLoading = true;
    notifyListeners();

    final result = await _userService.fetchCurrentUserWithWeightUpdate();
    if (result != null) {
      user = result['user'] as UserModel;
      weightUpdatedAt = result['weightUpdatedAt'] as DateTime?;
    } else {
      user = null;
      weightUpdatedAt = null;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _userService.signOut();
  }

  Future<void> updateUserProfile({
    required String name,
    required double height,
    required double weight,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      print('ProfileController: Updating profile: name=$name, height=$height, weight=$weight');

      await _userService.updateUserProfile(
        name: name,
        height: height,
        weight: weight,
      );

      await loadUserProfile();

      print('ProfileController: Profile updated successfully');
    } catch (e) {
      print('ProfileController: Error updating profile: $e');
      throw Exception('Lỗi khi cập nhật hồ sơ: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}