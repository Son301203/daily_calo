// ignore_for_file: public_member_api_docs, sort_constructors_first
class Meal {
  final String id;
  final String title;
  final int calo;
  final int carbs;
  final double fat;
  final String periodTime;
  final int protein;
  final int servingSize;
  final String userId;
  
  Meal({
    required this.id,
    required this.title,
    required this.calo,
    required this.carbs,
    required this.fat,
    required this.periodTime,
    required this.protein,
    required this.servingSize,
    required this.userId,
  });

    Map<String, dynamic> toMap() {
    return {
      'title': title,
      'calo': calo,
      'carbs': carbs,
      'fat': fat,
      'period_time': periodTime,
      'protein': protein,
      'serving_size': servingSize,
      'user_id': userId,
    };
  }

  factory Meal.fromMap(String id, Map<String, dynamic> map) {
    return Meal(
      id: id,
      title: map['title'] ?? '',
      calo: map['calo'] ?? 0,
      carbs: map['carbs'] ?? 0,
      fat: (map['fat'] ?? 0.0).toDouble(),
      periodTime: map['period_time'] ?? '',
      protein: map['protein'] ?? 0,
      servingSize: map['serving_size'] ?? 0,
      userId: map['user_id'] ?? '',
    );
  }
}
