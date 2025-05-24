import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExerciseController {
  final CollectionReference exCollection = FirebaseFirestore.instance
      .collection('Exercises');
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('Users');
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Get user ID
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  Future<void> addEx(Exercise ex) async {
    final userId = getCurrentUserId();

    await exCollection.add({...ex.toMap(), 'user_id': userId});
  }

  // Update
  Future<void> updateEx(Exercise ex) async {
    await exCollection.doc(ex.id).update(ex.toMap());
  }

  // delete
  Future<void> deleteEx(String exId) async {
    await exCollection.doc(exId).delete();
  }

  //Get
  Future<Exercise?> getEx(String exId) async {
    final doc = await exCollection.doc(exId).get();
    if (doc.exists) {
      return Exercise.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Stream<List<Exercise>> getExercises() {
    final userId = getCurrentUserId();
    return exCollection
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Exercise.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  Future<void> addExerciseIdToDate(String exerciseId) async {
    final userId = getCurrentUserId();
    final currentDate = DateFormat('dd/MM/yy').format(DateTime.now());
    final dateCollection = usersCollection.doc(userId).collection('Date');

    final querySnapshot =
        await dateCollection
            .where('date', isEqualTo: currentDate)
            .limit(1)
            .get();

    if (querySnapshot.docs.isNotEmpty) {
      final docId = querySnapshot.docs.first.id;
      final currentData = querySnapshot.docs.first.data();
      final List<dynamic> currentExercise =
          currentData['exercise_id'] as List<dynamic>? ?? [];
      currentExercise.add(exerciseId);
      await dateCollection.doc(docId).update({'exercise_id': currentExercise});
    } else {
      // Document doesn't exist, create a new one
      await dateCollection.add({
        'date': currentDate,
        'exercise_id': [exerciseId],
        'meal_id': [],
        'quantity_water': 0,
      });
    }
  }
}
