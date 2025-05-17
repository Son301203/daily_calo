import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String gmail;
  final String name;
  final double height;
  final double weight;
  final DateTime? weightUpdatedAt;

  UserModel({
    required this.uid,
    required this.gmail,
    required this.name,
    required this.height,
    required this.weight,
    this.weightUpdatedAt,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      gmail: map['gmail'] ?? '',
      name: map['name'] ?? '',
      height: (map['height'] ?? 0).toDouble(),
      weight: (map['weight'] ?? 0).toDouble(),
      weightUpdatedAt: map['weightUpdatedAt'] != null
          ? (map['weightUpdatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gmail': gmail,
      'name': name,
      'height': height,
      'weight': weight,
      'weightUpdatedAt': weightUpdatedAt != null
          ? Timestamp.fromDate(weightUpdatedAt!)
          : null,
    };
  }
}