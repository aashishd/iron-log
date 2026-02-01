class Workout {
  final int? id;
  final String date;
  final String createdAt;

  Workout({
    this.id,
    required this.date,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'created_at': createdAt,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      date: map['date'],
      createdAt: map['created_at'],
    );
  }
}

class Exercise {
  final int? id;
  final int workoutId;
  final String name;

  Exercise({
    this.id,
    required this.workoutId,
    required this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'workout_id': workoutId,
      'name': name,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      workoutId: map['workout_id'],
      name: map['name'],
    );
  }
}

class ExerciseSet {
  final int? id;
  final int exerciseId;
  final int reps;
  final double weight;
  final int setNumber;

  ExerciseSet({
    this.id,
    required this.exerciseId,
    required this.reps,
    required this.weight,
    required this.setNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'reps': reps,
      'weight': weight,
      'set_number': setNumber,
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'],
      exerciseId: map['exercise_id'],
      reps: map['reps'],
      setNumber: map['set_number'],
      weight: (map['weight'] as num).toDouble(),
    );
  }
}
