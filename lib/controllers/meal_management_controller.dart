import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_calo/models/meal.dart';

import 'package:intl/intl.dart';

class MealManagementController {
  final CollectionReference mealsCollection = FirebaseFirestore.instance
      .collection('Meals');
  final FirebaseAuth auth = FirebaseAuth.instance;
    final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('Users');

  // Get user ID
  String? getCurrentUserId() {
    return auth.currentUser?.uid;
  }

  // Add
  Future<void> addMeal(Meal meal) async {
    final userId = getCurrentUserId();

    await mealsCollection.add({
      ...meal.toMap(),
      'user_id': userId,
    });
  }

  // Update
  Future<void> updateMeal(Meal meal) async {
    await mealsCollection.doc(meal.id).update(meal.toMap());
  }

  // delete
  Future<void> deleteMeal(String mealId) async {
    await mealsCollection.doc(mealId).delete();
  }

  // Get mealtype
  Stream<List<Meal>> getMealType(String mealType) {
    final userId = getCurrentUserId();

    return mealsCollection
        .where('user_id', isEqualTo: userId)
        .where('period_time', isEqualTo: mealType)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) => Meal.fromMap(
                      doc.id,
                      doc.data() as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
        );
  }

  //Get meal
  Future<Meal?> getMeal(String mealId) async {
    final doc = await mealsCollection.doc(mealId).get();
    if (doc.exists) {
      return Meal.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }
    return null;
  }


  Future<void> addDishToDate(String mealId) async {
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
      final List<dynamic> currentMeals =
          currentData['meal_id'] as List<dynamic>? ?? [];
      currentMeals.add(mealId);
      await dateCollection.doc(docId).update({
        'meal_id': currentMeals,
      });
    } else {
      await dateCollection.add({
        'date': currentDate,
        'caloriesNeeded': 0,
        'exercise_id': [],
        'meal_id': [mealId],
        'quantityWater': 0,
      });
    }
  }
}
