import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _db = DatabaseHelper.instance;
  final List<ExerciseEntry> _exercises = [];
  List<String> _exerciseNames = [];
  
  @override
  void initState() {
    super.initState();
    _loadExerciseNames();
  }

  Future<void> _loadExerciseNames() async {
    final names = await _db.getAllExerciseNames();
    setState(() {
      _exerciseNames = names;
    });
  }

  void _addExercise() {
    setState(() {
      _exercises.add(ExerciseEntry());
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final now = DateTime.now().toIso8601String();

    final workoutId = await _db.createWorkout({
      'date': today,
      'created_at': now,
    });

    for (var exercise in _exercises) {
      if (exercise.name.isEmpty || exercise.sets.isEmpty) continue;

      final exerciseId = await _db.createExercise({
        'workout_id': workoutId,
        'name': exercise.name,
      });

      for (int i = 0; i < exercise.sets.length; i++) {
        final set = exercise.sets[i];
        if (set.reps > 0 && set.weight > 0) {
          await _db.createSet({
            'exercise_id': exerciseId,
            'reps': set.reps,
            'weight': set.weight,
            'set_number': i + 1,
          });
        }
      }
    }

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout saved! 💪')),
    );

    setState(() {
      _exercises.clear();
    });
    
    await _loadExerciseNames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Workout'),
        actions: [
          if (_exercises.isNotEmpty)
            TextButton(
              onPressed: _saveWorkout,
              child: const Text('Save', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
      body: _exercises.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 64,
                    color: AppTheme.lightText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to start logging',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.lightText,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _exercises.length,
              itemBuilder: (context, index) {
                return ExerciseCard(
                  key: ValueKey(_exercises[index]),
                  exercise: _exercises[index],
                  exerciseNames: _exerciseNames,
                  onRemove: () => _removeExercise(index),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ExerciseEntry {
  String name = '';
  List<SetEntry> sets = [SetEntry()];
}

class SetEntry {
  int reps = 0;
  double weight = 0.0;
}

class ExerciseCard extends StatefulWidget {
  final ExerciseEntry exercise;
  final List<String> exerciseNames;
  final VoidCallback onRemove;

  const ExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseNames,
    required this.onRemove,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.exercise.name;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addSet() {
    setState(() {
      widget.exercise.sets.add(SetEntry());
    });
  }

  void _removeSet(int index) {
    if (widget.exercise.sets.length > 1) {
      setState(() {
        widget.exercise.sets.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return widget.exerciseNames.where((String option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (String selection) {
                      widget.exercise.name = selection;
                      _nameController.text = selection;
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      controller.text = _nameController.text;
                      controller.selection = _nameController.selection;
                      
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: const InputDecoration(
                          labelText: 'Exercise Name',
                          hintText: 'e.g., Bench Press',
                        ),
                        onChanged: (value) {
                          widget.exercise.name = value;
                          _nameController.text = value;
                        },
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: widget.onRemove,
                  color: Colors.red[300],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                SizedBox(width: 40, child: Text('Set', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 100, child: Text('Reps', style: TextStyle(fontWeight: FontWeight.bold))),
                SizedBox(width: 100, child: Text('Weight (kg)', style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 8),
            ...List.generate(widget.exercise.sets.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: AppTheme.lightText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '10',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) {
                          widget.exercise.sets[index].reps = int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          hintText: '100',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        ),
                        onChanged: (value) {
                          widget.exercise.sets[index].weight = double.tryParse(value) ?? 0.0;
                        },
                      ),
                    ),
                    if (widget.exercise.sets.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 20),
                        onPressed: () => _removeSet(index),
                        color: Colors.red[300],
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _addSet,
              icon: const Icon(Icons.add),
              label: const Text('Add Set'),
            ),
          ],
        ),
      ),
    );
  }
}
