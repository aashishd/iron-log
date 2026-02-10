import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database_helper.dart';
import '../theme.dart';

class WorkoutEditScreen extends StatefulWidget {
  final int workoutId;
  final String date;
  final String createdAt;
  final List<Map<String, dynamic>> details;

  const WorkoutEditScreen({
    super.key,
    required this.workoutId,
    required this.date,
    required this.createdAt,
    required this.details,
  });

  @override
  State<WorkoutEditScreen> createState() => _WorkoutEditScreenState();
}

class _WorkoutEditScreenState extends State<WorkoutEditScreen> {
  final _db = DatabaseHelper.instance;
  final List<EditExerciseEntry> _exercises = [];
  List<String> _exerciseNames = [];
  DateTime _selectedDate;
  String _createdAt;

  _WorkoutEditScreenState()
    : _selectedDate = DateTime.now(),
      _createdAt = DateTime.now().toIso8601String();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.date);
    _createdAt = widget.createdAt;
    _loadExerciseNames();
    _initializeExercises();
  }

  Future<void> _loadExerciseNames() async {
    final names = await _db.getAllExerciseNames();
    setState(() {
      _exerciseNames = names;
    });
  }

  void _initializeExercises() {
    for (var item in widget.details) {
      final exercise = item['exercise'] as Map<String, dynamic>;
      final sets = item['sets'] as List<Map<String, dynamic>>;

      final entry = EditExerciseEntry(
        id: exercise['id'] as int?,
        name: exercise['name'] as String,
      );

      for (var set in sets) {
        entry.sets.add(
          EditSetEntry(
            id: set['id'] as int?,
            reps: set['reps'] as int,
            weight: (set['weight'] as num).toDouble(),
            setNumber: set['set_number'] as int,
          ),
        );
      }

      _exercises.add(entry);
    }
  }

  void _addExercise() {
    setState(() {
      _exercises.add(EditExerciseEntry());
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveWorkout() async {
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')),
      );
      return;
    }

    final formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);

    await _db.updateWorkout(widget.workoutId, {
      'date': formattedDate,
      'created_at': _createdAt,
    });

    for (var exercise in _exercises) {
      if (exercise.name.isEmpty || exercise.sets.isEmpty) continue;

      if (exercise.id != null) {
        await _db.updateExercise(exercise.id!, {
          'workout_id': widget.workoutId,
          'name': exercise.name,
        });

        await _db.deleteSetsByExercise(exercise.id!);
      } else {
        exercise.id = await _db.createExercise({
          'workout_id': widget.workoutId,
          'name': exercise.name,
        });
      }

      for (int i = 0; i < exercise.sets.length; i++) {
        final set = exercise.sets[i];
        if (set.reps > 0 && set.weight > 0) {
          await _db.createSet({
            'exercise_id': exercise.id!,
            'reps': set.reps,
            'weight': set.weight,
            'set_number': i + 1,
          });
        }
      }
    }

    if (!mounted) return;

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
        actions: [
          TextButton(
            onPressed: _saveWorkout,
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Date: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                TextButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: Text(DateFormat('MMMM d, yyyy').format(_selectedDate)),
                ),
              ],
            ),
          ),
          Expanded(
            child: _exercises.isEmpty
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
                          'Tap + to add exercises',
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
                      return EditExerciseCard(
                        key: ValueKey(_exercises[index]),
                        exercise: _exercises[index],
                        exerciseNames: _exerciseNames,
                        onRemove: () => _removeExercise(index),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class EditExerciseEntry {
  int? id;
  String name;
  List<EditSetEntry> sets;

  EditExerciseEntry({this.id, this.name = '', List<EditSetEntry>? sets})
    : sets = sets ?? [EditSetEntry()];
}

class EditSetEntry {
  int? id;
  int reps;
  double weight;
  int setNumber;

  EditSetEntry({this.id, this.reps = 0, this.weight = 0.0, this.setNumber = 0});
}

class EditExerciseCard extends StatefulWidget {
  final EditExerciseEntry exercise;
  final List<String> exerciseNames;
  final VoidCallback onRemove;

  const EditExerciseCard({
    super.key,
    required this.exercise,
    required this.exerciseNames,
    required this.onRemove,
  });

  @override
  State<EditExerciseCard> createState() => _EditExerciseCardState();
}

class _EditExerciseCardState extends State<EditExerciseCard> {
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
      widget.exercise.sets.add(EditSetEntry());
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
                        return option.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    onSelected: (String selection) {
                      widget.exercise.name = selection;
                      _nameController.text = selection;
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
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
                SizedBox(
                  width: 40,
                  child: Text(
                    'Set',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Reps',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Weight (kg)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
                        controller: TextEditingController(
                          text: widget.exercise.sets[index].reps > 0
                              ? widget.exercise.sets[index].reps.toString()
                              : '',
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: '10',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          widget.exercise.sets[index].reps =
                              int.tryParse(value) ?? 0;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 100,
                      child: TextField(
                        controller: TextEditingController(
                          text: widget.exercise.sets[index].weight > 0
                              ? widget.exercise.sets[index].weight.toString()
                              : '',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: '100',
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          widget.exercise.sets[index].weight =
                              double.tryParse(value) ?? 0.0;
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
