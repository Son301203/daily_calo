// ignore_for_file: public_member_api_docs, sort_constructors_first
class Exercise {
  final String id;
  final String activity;
  final int kcal;
  final int time;
  final String userId;
  
  Exercise({
    required this.id,
    required this.activity,
    required this.kcal,
    required this.time,
    required this.userId,
  });

     Map<String, dynamic> toMap() {
    return {
      'activity': activity,
      'kcal': kcal,
      'time': time,
      'user_id': userId,
    };
  }

  factory Exercise.fromMap(String id, Map<String, dynamic> map) {
    return Exercise(
      id: id,
      activity: map['activity'] ?? '',
      kcal: map['kcal'] ?? 0,
      time: map['time'] ?? 0,
      userId: map['user_id'] ?? '',
    );
  }
  
}
