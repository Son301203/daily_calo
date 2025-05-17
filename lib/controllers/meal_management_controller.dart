import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_calo/models/meal.dart';

class MealManagementController {
  final CollectionReference mealsCollection = FirebaseFirestore.instance
      .collection('Meals');
  final FirebaseAuth auth = FirebaseAuth.instance;

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
}
