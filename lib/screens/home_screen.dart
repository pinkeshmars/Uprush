import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uprush/models/habit.dart';
import 'package:uprush/widgets/habit_card.dart';
import 'package:uprush/widgets/greeting_header.dart';
import 'package:uprush/providers/habit_provider.dart';
import 'package:uprush/providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeInAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleHabitCompletion(String habitId) async {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    final habit = habitProvider.habits.firstWhere((h) => h.id == habitId);
    
    await habitProvider.toggleHabitCompletion(habitId, DateTime.now());
    
    // Show a brief celebration animation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.celebration, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                !habit.isCompletedToday() 
                    ? 'Great job! 🎉' 
                    : 'Keep going! 💪',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildStatsOverview(List<Habit> habits) {
    final completedToday = habits.where((h) => h.isCompletedToday()).length;
    final totalHabits = habits.length;
    final completionRate = totalHabits > 0 ? (completedToday / totalHabits) : 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Completed Today',
              '$completedToday/$totalHabits',
              Icons.check_circle,
              Theme.of(context).colorScheme.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Completion Rate',
              '${(completionRate * 100).round()}%',
              Icons.trending_up,
              Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const Spacer(),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysHabits(List<Habit> habits) {
    final width = MediaQuery.of(context).size.width;
    final isLarge = width >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            children: [
              Text(
                'Today\'s Habits',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${habits.length}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (habits.isEmpty)
          Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'No habits yet!',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first habit to start building better routines.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          )
        else if (!isLarge)
          ...habits.asMap().entries.map((entry) {
            final index = entry.key;
            final habit = entry.value;

            return AnimatedBuilder(
              animation: _fadeInAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (1 - _fadeInAnimation.value) * 50),
                  child: Opacity(
                    opacity: _fadeInAnimation.value,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 100)),
                      curve: Curves.easeOutBack,
                      child: HabitCard(
                        habit: habit,
                        onTap: () {
                          // Could navigate to habit detail screen
                        },
                        onComplete: () => _toggleHabitCompletion(habit.id),
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList()
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: habits.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.8,
            ),
            itemBuilder: (context, index) {
              final habit = habits[index];
              return AnimatedBuilder(
                animation: _fadeInAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _fadeInAnimation.value) * 50),
                    child: Opacity(
                      opacity: _fadeInAnimation.value,
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        curve: Curves.easeOutBack,
                        child: HabitCard(
                          habit: habit,
                          onTap: () {
                            // Could navigate to habit detail screen
                          },
                          onComplete: () => _toggleHabitCompletion(habit.id),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        const SizedBox(height: 100),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('UpRush'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).signOut(),
          ),
        ],
      ),
      body: Consumer<HabitProvider>(
        builder: (context, habitProvider, _) {
          if (habitProvider.isLoading && habitProvider.habits.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (habitProvider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${habitProvider.errorMessage}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      habitProvider.clearError();
                      habitProvider.listenToHabits();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: const GreetingHeader(),
                  ),
                  FadeTransition(
                    opacity: _fadeInAnimation,
                    child: _buildStatsOverview(habitProvider.habits),
                  ),
                  const SizedBox(height: 16),
                  _buildTodaysHabits(habitProvider.habits),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fadeInAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fadeInAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: () => _showCreateHabitDialog(context),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Habit',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateHabitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => CreateHabitDialog(),
    );
  }
}

// Simple dialog to create new habits
class CreateHabitDialog extends StatefulWidget {
  @override
  _CreateHabitDialogState createState() => _CreateHabitDialogState();
}

class _CreateHabitDialogState extends State<CreateHabitDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedEmoji = '⭐';
  String _selectedCategory = 'Health';
  String _selectedColor = '#6B73FF';
  int _targetStreak = 7;

  final List<String> _emojis = ['⭐', '🔥', '💪', '🎯', '📚', '💧', '🧘', '🏃', '🎵', '🎨'];
  final List<String> _categories = ['Health', 'Productivity', 'Learning', 'Fitness', 'Mindfulness', 'Creative'];
  final List<String> _colors = ['#6B73FF', '#FF6B6B', '#4ECDC4', '#45B7D1', '#FFA726', '#AB47BC'];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create New Habit'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Habit Title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedEmoji,
              decoration: const InputDecoration(labelText: 'Emoji'),
              items: _emojis.map((emoji) => DropdownMenuItem(
                value: emoji,
                child: Text(emoji, style: const TextStyle(fontSize: 20)),
              )).toList(),
              onChanged: (value) => setState(() => _selectedEmoji = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: _categories.map((category) => DropdownMenuItem(
                value: category,
                child: Text(category),
              )).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            const SizedBox(height: 16),
            Text('Target Streak: $_targetStreak days'),
            Slider(
              value: _targetStreak.toDouble(),
              min: 1,
              max: 30,
              divisions: 29,
              onChanged: (value) => setState(() => _targetStreak = value.round()),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Consumer<HabitProvider>(
          builder: (context, habitProvider, _) {
            return ElevatedButton(
              onPressed: habitProvider.isLoading ? null : () async {
                if (_titleController.text.trim().isEmpty) return;
                
                final habit = Habit(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text.trim(),
                  emoji: _selectedEmoji,
                  description: _descriptionController.text.trim(),
                  color: _selectedColor,
                  targetStreak: _targetStreak,
                  category: _selectedCategory,
                );

                await habitProvider.createHabit(habit);
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: habitProvider.isLoading 
                ? const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Create'),
            );
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}