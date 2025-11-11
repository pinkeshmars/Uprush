import 'package:uprush/models/habit.dart';

class SampleHabits {
  static List<Habit> getDefaultHabits() {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    
    // Helper function to format date
    String formatDate(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    return [
      Habit(
        id: '1',
        title: 'Drink 8 Glasses of Water',
        emoji: '💧',
        description: 'Stay hydrated throughout the day',
        completedDates: [formatDate(yesterday), formatDate(twoDaysAgo)],
        color: 'blue',
        targetStreak: 7,
        category: 'Health',
      ),
      Habit(
        id: '2',
        title: 'Morning Meditation',
        emoji: '🧘‍♀️',
        description: '10 minutes of mindfulness to start the day',
        completedDates: [formatDate(yesterday)],
        color: 'purple',
        targetStreak: 14,
        category: 'Wellness',
      ),
      Habit(
        id: '3',
        title: 'Daily Exercise',
        emoji: '🏃‍♂️',
        description: '30 minutes of physical activity',
        completedDates: [formatDate(twoDaysAgo)],
        color: 'green',
        targetStreak: 21,
        category: 'Fitness',
      ),
      Habit(
        id: '4',
        title: 'Read for 30 Minutes',
        emoji: '📚',
        description: 'Expand knowledge through reading',
        completedDates: [formatDate(yesterday), formatDate(twoDaysAgo)],
        color: 'orange',
        targetStreak: 30,
        category: 'Learning',
      ),
      Habit(
        id: '5',
        title: 'Practice Gratitude',
        emoji: '🙏',
        description: 'Write 3 things you are grateful for',
        completedDates: [],
        color: 'pink',
        targetStreak: 7,
        category: 'Wellness',
      ),
      Habit(
        id: '6',
        title: 'Learn Something New',
        emoji: '🧠',
        description: 'Dedicate time to learn a new skill',
        completedDates: [formatDate(yesterday)],
        color: 'teal',
        targetStreak: 14,
        category: 'Learning',
      ),
      Habit(
        id: '7',
        title: 'Get 8 Hours of Sleep',
        emoji: '😴',
        description: 'Prioritize quality rest',
        completedDates: [formatDate(yesterday), formatDate(twoDaysAgo)],
        color: 'indigo',
        targetStreak: 7,
        category: 'Health',
      ),
      Habit(
        id: '8',
        title: 'Eat 5 Servings of Fruits/Veggies',
        emoji: '🥗',
        description: 'Nourish your body with healthy foods',
        completedDates: [],
        color: 'green',
        targetStreak: 21,
        category: 'Health',
      ),
    ];
  }

  static Map<String, String> get categoryColors => {
    'Health': 'green',
    'Wellness': 'purple',
    'Fitness': 'blue',
    'Learning': 'orange',
    'Productivity': 'red',
  };
}