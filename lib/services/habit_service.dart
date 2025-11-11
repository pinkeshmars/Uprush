import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uprush/firestore/firestore_data_schema.dart';
import 'package:uprush/models/habit.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // Create a new habit
  Future<String> createHabit(Habit habit) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final now = DateTime.now();
    final docRef = _firestore.collection(FirestoreSchema.habitsCollection).doc();
    
    final firestoreHabit = FirestoreHabit(
      id: docRef.id,
      ownerId: userId,
      title: habit.title,
      emoji: habit.emoji,
      description: habit.description,
      color: habit.color,
      targetStreak: habit.targetStreak,
      category: habit.category,
      createdAt: now,
      updatedAt: now,
    );

    await docRef.set(firestoreHabit.toJson());
    return docRef.id;
  }

  // Get user's habits stream
  Stream<List<Habit>> getUserHabits() {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(FirestoreSchema.habitsCollection)
        .where('owner_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Habit> habits = [];
      
      for (final doc in snapshot.docs) {
        final firestoreHabit = FirestoreHabit.fromJson(doc.data());
        final completedDates = await _getHabitCompletions(doc.id);
        
        habits.add(Habit(
          id: firestoreHabit.id,
          title: firestoreHabit.title,
          emoji: firestoreHabit.emoji,
          description: firestoreHabit.description,
          completedDates: completedDates,
          color: firestoreHabit.color,
          targetStreak: firestoreHabit.targetStreak,
          category: firestoreHabit.category,
        ));
      }
      
      return habits;
    });
  }

  // Get habits by category
  Stream<List<Habit>> getUserHabitsByCategory(String category) {
    final userId = _currentUserId;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection(FirestoreSchema.habitsCollection)
        .where('owner_id', isEqualTo: userId)
        .where('category', isEqualTo: category)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .asyncMap((snapshot) async {
      final List<Habit> habits = [];
      
      for (final doc in snapshot.docs) {
        final firestoreHabit = FirestoreHabit.fromJson(doc.data());
        final completedDates = await _getHabitCompletions(doc.id);
        
        habits.add(Habit(
          id: firestoreHabit.id,
          title: firestoreHabit.title,
          emoji: firestoreHabit.emoji,
          description: firestoreHabit.description,
          completedDates: completedDates,
          color: firestoreHabit.color,
          targetStreak: firestoreHabit.targetStreak,
          category: firestoreHabit.category,
        ));
      }
      
      return habits;
    });
  }

  // Update habit
  Future<void> updateHabit(String habitId, Habit habit) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection(FirestoreSchema.habitsCollection).doc(habitId).update({
      'title': habit.title,
      'emoji': habit.emoji,
      'description': habit.description,
      'color': habit.color,
      'target_streak': habit.targetStreak,
      'category': habit.category,
      'updated_at': Timestamp.now(),
    });
  }

  // Delete habit
  Future<void> deleteHabit(String habitId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    // Delete habit completions first
    final completions = await _firestore
        .collection(FirestoreSchema.habitCompletionsCollection)
        .where('owner_id', isEqualTo: userId)
        .where('habit_id', isEqualTo: habitId)
        .get();

    final batch = _firestore.batch();
    for (final doc in completions.docs) {
      batch.delete(doc.reference);
    }

    // Delete the habit
    batch.delete(_firestore.collection(FirestoreSchema.habitsCollection).doc(habitId));
    
    await batch.commit();
  }

  // Mark habit as completed for a specific date
  Future<void> markHabitCompleted(String habitId, DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final dateString = _dateToString(date);
    final completionId = '${habitId}_$dateString';

    final completion = FirestoreHabitCompletion(
      id: completionId,
      ownerId: userId,
      habitId: habitId,
      completedDate: date,
      createdAt: DateTime.now(),
    );

    await _firestore
        .collection(FirestoreSchema.habitCompletionsCollection)
        .doc(completionId)
        .set(completion.toJson());
  }

  // Mark habit as uncompleted for a specific date
  Future<void> markHabitUncompleted(String habitId, DateTime date) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final dateString = _dateToString(date);
    final completionId = '${habitId}_$dateString';

    await _firestore
        .collection(FirestoreSchema.habitCompletionsCollection)
        .doc(completionId)
        .delete();
  }

  // Get habit completions (returns list of date strings)
  Future<List<String>> _getHabitCompletions(String habitId) async {
    final userId = _currentUserId;
    if (userId == null) return [];

    final snapshot = await _firestore
        .collection(FirestoreSchema.habitCompletionsCollection)
        .where('owner_id', isEqualTo: userId)
        .where('habit_id', isEqualTo: habitId)
        .orderBy('completed_date', descending: true)
        .limit(365) // Get last year of completions
        .get();

    return snapshot.docs
        .map((doc) {
          final completion = FirestoreHabitCompletion.fromJson(doc.data());
          return _dateToString(completion.completedDate);
        })
        .toList();
  }

  // Helper method to convert DateTime to string format
  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get habit statistics
  Future<Map<String, dynamic>> getHabitStats(String habitId) async {
    final userId = _currentUserId;
    if (userId == null) throw Exception('User not authenticated');

    final completionsSnapshot = await _firestore
        .collection(FirestoreSchema.habitCompletionsCollection)
        .where('owner_id', isEqualTo: userId)
        .where('habit_id', isEqualTo: habitId)
        .get();

    final totalCompletions = completionsSnapshot.docs.length;
    final completedDates = completionsSnapshot.docs
        .map((doc) => FirestoreHabitCompletion.fromJson(doc.data()).completedDate)
        .toList();

    // Calculate current streak
    int currentStreak = 0;
    if (completedDates.isNotEmpty) {
      completedDates.sort((a, b) => b.compareTo(a));
      final today = DateTime.now();
      
      for (int i = 0; i < 365; i++) {
        final checkDate = today.subtract(Duration(days: i));
        final hasCompletion = completedDates.any((date) => 
            date.year == checkDate.year && 
            date.month == checkDate.month && 
            date.day == checkDate.day);
        
        if (hasCompletion) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return {
      'total_completions': totalCompletions,
      'current_streak': currentStreak,
      'completed_dates': completedDates.map((date) => _dateToString(date)).toList(),
    };
  }
}