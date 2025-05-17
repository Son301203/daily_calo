import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_calo/models/exercise.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExerciseController {
  final CollectionReference exCollection = FirebaseFirestore.instance
      .collection('Exercises');
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
}
