import 'package:cloud_firestore/cloud_firestore.dart';

/// Defines the Firestore data schema for the UpRush habit tracker app
class FirestoreSchema {
  static const String usersCollection = 'users';
  static const String habitsCollection = 'habits';
  static const String habitCompletionsCollection = 'habit_completions';
}

/// User document structure in Firestore
class FirestoreUser {
  final String id;
  final String email;
  final String? displayName;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreUser({
    required this.id,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'display_name': displayName,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  factory FirestoreUser.fromJson(Map<String, dynamic> json) => FirestoreUser(
    id: json['id'] ?? '',
    email: json['email'] ?? '',
    displayName: json['display_name'],
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );
}

/// Habit document structure in Firestore
class FirestoreHabit {
  final String id;
  final String ownerId;
  final String title;
  final String emoji;
  final String description;
  final String color;
  final int targetStreak;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreHabit({
    required this.id,
    required this.ownerId,
    required this.title,
    required this.emoji,
    required this.description,
    required this.color,
    required this.targetStreak,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'title': title,
    'emoji': emoji,
    'description': description,
    'color': color,
    'target_streak': targetStreak,
    'category': category,
    'created_at': Timestamp.fromDate(createdAt),
    'updated_at': Timestamp.fromDate(updatedAt),
  };

  factory FirestoreHabit.fromJson(Map<String, dynamic> json) => FirestoreHabit(
    id: json['id'] ?? '',
    ownerId: json['owner_id'] ?? '',
    title: json['title'] ?? '',
    emoji: json['emoji'] ?? '',
    description: json['description'] ?? '',
    color: json['color'] ?? '',
    targetStreak: json['target_streak'] ?? 7,
    category: json['category'] ?? '',
    createdAt: (json['created_at'] as Timestamp).toDate(),
    updatedAt: (json['updated_at'] as Timestamp).toDate(),
  );
}

/// Habit completion document structure in Firestore
class FirestoreHabitCompletion {
  final String id;
  final String ownerId;
  final String habitId;
  final DateTime completedDate;
  final DateTime createdAt;

  FirestoreHabitCompletion({
    required this.id,
    required this.ownerId,
    required this.habitId,
    required this.completedDate,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'owner_id': ownerId,
    'habit_id': habitId,
    'completed_date': Timestamp.fromDate(completedDate),
    'created_at': Timestamp.fromDate(createdAt),
  };

  factory FirestoreHabitCompletion.fromJson(Map<String, dynamic> json) => FirestoreHabitCompletion(
    id: json['id'] ?? '',
    ownerId: json['owner_id'] ?? '',
    habitId: json['habit_id'] ?? '',
    completedDate: (json['completed_date'] as Timestamp).toDate(),
    createdAt: (json['created_at'] as Timestamp).toDate(),
  );
}