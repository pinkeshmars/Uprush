import 'package:flutter/material.dart';
import 'package:uprush/models/habit.dart';
import 'package:uprush/theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;

  const HabitCard({
    super.key,
    required this.habit,
    this.onTap,
    this.onComplete,
  });

  Color _getHabitColor(BuildContext context, String colorName) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    switch (colorName) {
      case 'blue':
        return isDark ? Colors.lightBlue[300]! : Colors.blue[400]!;
      case 'green':
        return isDark ? DarkModeColors.successGreen : LightModeColors.successGreen;
      case 'purple':
        return isDark ? Colors.deepPurple[300]! : Colors.deepPurple[400]!;
      case 'orange':
        return isDark ? Colors.orange[300]! : Colors.orange[400]!;
      case 'pink':
        return isDark ? Colors.pink[300]! : Colors.pink[400]!;
      case 'teal':
        return isDark ? Colors.teal[300]! : Colors.teal[400]!;
      case 'indigo':
        return isDark ? Colors.indigo[300]! : Colors.indigo[400]!;
      case 'red':
        return isDark ? Colors.red[300]! : Colors.red[400]!;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final habitColor = _getHabitColor(context, habit.color);
    final isCompleted = habit.isCompletedToday();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? DarkModeColors.cardBackground : LightModeColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: isCompleted 
            ? Border.all(color: habitColor, width: 2)
            : Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: habitColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      habit.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        habit.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: habitColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${habit.currentStreak} day streak',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: habitColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (habit.progressPercentage > 0)
                            Container(
                              width: 60,
                              height: 4,
                              decoration: BoxDecoration(
                                color: habitColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: habit.progressPercentage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: habitColor,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: onComplete,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted 
                          ? habitColor 
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCompleted 
                            ? habitColor 
                            : theme.colorScheme.outline.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isCompleted ? Icons.check : Icons.add,
                      size: 20,
                      color: isCompleted 
                          ? Colors.white 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}