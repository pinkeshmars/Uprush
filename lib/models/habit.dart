class Habit {
  final String id;
  final String title;
  final String emoji;
  final String description;
  final List<String> completedDates;
  final String color;
  final int targetStreak;
  final String category;

  Habit({
    required this.id,
    required this.title,
    required this.emoji,
    required this.description,
    this.completedDates = const [],
    required this.color,
    this.targetStreak = 7,
    required this.category,
  });

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completedDates.contains(todayString);
  }

  int get currentStreak {
    if (completedDates.isEmpty) return 0;
    
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 365; i++) {
      final checkDate = today.subtract(Duration(days: i));
      final dateString = '${checkDate.year}-${checkDate.month.toString().padLeft(2, '0')}-${checkDate.day.toString().padLeft(2, '0')}';
      
      if (completedDates.contains(dateString)) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }

  double get progressPercentage => (currentStreak / targetStreak).clamp(0.0, 1.0);

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'emoji': emoji,
    'description': description,
    'completed_dates': completedDates,
    'color': color,
    'target_streak': targetStreak,
    'category': category,
  };

  factory Habit.fromJson(Map<String, dynamic> json) => Habit(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    emoji: json['emoji'] ?? '',
    description: json['description'] ?? '',
    completedDates: List<String>.from(json['completed_dates'] ?? []),
    color: json['color'] ?? '',
    targetStreak: json['target_streak'] ?? 7,
    category: json['category'] ?? '',
  );

  Habit copyWith({
    String? id,
    String? title,
    String? emoji,
    String? description,
    List<String>? completedDates,
    String? color,
    int? targetStreak,
    String? category,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      emoji: emoji ?? this.emoji,
      description: description ?? this.description,
      completedDates: completedDates ?? this.completedDates,
      color: color ?? this.color,
      targetStreak: targetStreak ?? this.targetStreak,
      category: category ?? this.category,
    );
  }
}