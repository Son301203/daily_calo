import 'package:intl/intl.dart';

class HealthDailyService {
  int calculateWaterIntake(int currentIntake, int goal, int increment) {
    final newIntake = currentIntake + increment;
    return newIntake > goal ? goal : newIntake;
  }

  Map<String, dynamic> getInitialData() {
    return {
      'today': DateTime.now(),
      'waterGoal': 1950,
      'waterIntake': 0,
      'caloriesNeeded': 1266,
      'weightGoal': 50,
      'currentWeight': 56.0,
      'previousWeight': 62.0,
      'previousWeightDate': DateTime(2023, 7, 25),
    };
  }

  String getDynamicHeader(DateTime selectedDate) {
    final now = DateTime.now();
    final selectedDateOnly =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final nowDateOnly = DateTime(now.year, now.month, now.day);

    final difference = selectedDateOnly.difference(nowDateOnly).inDays;

    if (difference == 0) return 'Hôm nay';
    if (difference == -1) return 'Hôm qua';
    if (difference == -2) return 'Hôm kia';
    if (difference == 1) return 'Ngày mai';
    if (difference >= -7 && difference < -2) return '${-difference} ngày trước';
    if (difference >= -30 && difference < -7) return '1 tháng trước';
    if (difference > 1) return 'Thời gian tới';
    return DateFormat('d \'th\' M').format(selectedDate);
  }
}