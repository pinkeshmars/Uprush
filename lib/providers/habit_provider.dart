import 'package:flutter/foundation.dart';
import 'package:uprush/models/habit.dart';
import 'package:uprush/services/habit_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  List<Habit> _habits = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToHabits() {
    _habitService.getUserHabits().listen(
      (habits) {
        _habits = habits;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _setError(error.toString());
        _setLoading(false);
      },
    );
  }

  Future<void> createHabit(Habit habit) async {
    try {
      _setLoading(true);
      _clearError();
      await _habitService.createHabit(habit);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateHabit(String habitId, Habit habit) async {
    try {
      _setLoading(true);
      _clearError();
      await _habitService.updateHabit(habitId, habit);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteHabit(String habitId) async {
    try {
      _setLoading(true);
      _clearError();
      await _habitService.deleteHabit(habitId);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleHabitCompletion(String habitId, DateTime date) async {
    try {
      _clearError();
      final habit = _habits.firstWhere((h) => h.id == habitId);
      final dateString = _dateToString(date);
      
      if (habit.completedDates.contains(dateString)) {
        await _habitService.markHabitUncompleted(habitId, date);
      } else {
        await _habitService.markHabitCompleted(habitId, date);
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<Map<String, dynamic>> getHabitStats(String habitId) async {
    try {
      return await _habitService.getHabitStats(habitId);
    } catch (e) {
      _setError(e.toString());
      return {};
    }
  }

  List<Habit> getHabitsByCategory(String category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}