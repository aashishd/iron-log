import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('iron_log.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
    CREATE TABLE workouts (
      id $idType,
      date $textType,
      created_at $textType
    )
    ''');

    await db.execute('''
    CREATE TABLE exercises (
      id $idType,
      workout_id $integerType,
      name $textType,
      FOREIGN KEY (workout_id) REFERENCES workouts (id) ON DELETE CASCADE
    )
    ''');

    await db.execute('''
    CREATE TABLE sets (
      id $idType,
      exercise_id $integerType,
      reps $integerType,
      weight $realType,
      set_number $integerType,
      FOREIGN KEY (exercise_id) REFERENCES exercises (id) ON DELETE CASCADE
    )
    ''');
  }

  Future<int> createWorkout(Map<String, dynamic> workout) async {
    final db = await database;
    return await db.insert('workouts', workout);
  }

  Future<int> createExercise(Map<String, dynamic> exercise) async {
    final db = await database;
    return await db.insert('exercises', exercise);
  }

  Future<int> createSet(Map<String, dynamic> set) async {
    final db = await database;
    return await db.insert('sets', set);
  }

  Future<List<Map<String, dynamic>>> getWorkouts() async {
    final db = await database;
    return await db.query('workouts', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getWorkoutDetails(int workoutId) async {
    final db = await database;

    final exercises = await db.query(
      'exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
    );

    List<Map<String, dynamic>> result = [];

    for (var exercise in exercises) {
      final sets = await db.query(
        'sets',
        where: 'exercise_id = ?',
        whereArgs: [exercise['id']],
        orderBy: 'set_number ASC',
      );

      result.add({'exercise': exercise, 'sets': sets});
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory(
    String exerciseName,
  ) async {
    final db = await database;

    final exercises = await db.query(
      'exercises',
      where: 'LOWER(name) = LOWER(?)',
      whereArgs: [exerciseName],
    );

    List<Map<String, dynamic>> history = [];

    for (var exercise in exercises) {
      final workout = await db.query(
        'workouts',
        where: 'id = ?',
        whereArgs: [exercise['workout_id']],
      );

      final sets = await db.query(
        'sets',
        where: 'exercise_id = ?',
        whereArgs: [exercise['id']],
        orderBy: 'set_number ASC',
      );

      if (workout.isNotEmpty) {
        history.add({'date': workout[0]['date'], 'sets': sets});
      }
    }

    history.sort(
      (a, b) => (a['date'] as String).compareTo(b['date'] as String),
    );
    return history;
  }

  Future<List<String>> getAllExerciseNames() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT name FROM exercises ORDER BY name ASC',
    );
    return result.map((e) => e['name'] as String).toList();
  }

  Future<int> deleteWorkout(int workoutId) async {
    final db = await database;
    return await db.delete('workouts', where: 'id = ?', whereArgs: [workoutId]);
  }

  Future<int> updateWorkout(int workoutId, Map<String, dynamic> workout) async {
    final db = await database;
    return await db.update(
      'workouts',
      workout,
      where: 'id = ?',
      whereArgs: [workoutId],
    );
  }

  Future<int> updateExercise(
    int exerciseId,
    Map<String, dynamic> exercise,
  ) async {
    final db = await database;
    return await db.update(
      'exercises',
      exercise,
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<int> updateSet(int setId, Map<String, dynamic> set) async {
    final db = await database;
    return await db.update('sets', set, where: 'id = ?', whereArgs: [setId]);
  }

  Future<int> deleteExercise(int exerciseId) async {
    final db = await database;
    return await db.delete(
      'exercises',
      where: 'id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<int> deleteSetsByExercise(int exerciseId) async {
    final db = await database;
    return await db.delete(
      'sets',
      where: 'exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future close() async {
    final db = await database;
    db.close();
  }

  Future<void> generateDummyData() async {
    final workouts = await getWorkouts();
    if (workouts.isNotEmpty) return;

    final exercises = [
      'Bench Press',
      'Squat',
      'Deadlift',
      'Overhead Press',
      'Barbell Row',
      'Pull-ups',
      'Dips',
      'Leg Press',
      'Lat Pulldown',
      'Bicep Curls',
      'Tricep Extensions',
      'Leg Curls',
      'Calf Raises',
    ];

    final now = DateTime.now();
    final random = DateTime(now.year, now.month, now.day);

    for (int i = 6; i >= 0; i--) {
      final workoutDate = random.subtract(Duration(days: i));
      final formattedDate = DateFormat('yyyy-MM-dd').format(workoutDate);
      final createdAt = DateTime(
        workoutDate.year,
        workoutDate.month,
        workoutDate.day,
        9 + (i % 8),
        (i * 13) % 59,
      ).toIso8601String();

      if (i > 3) continue;

      final workoutId = await createWorkout({
        'date': formattedDate,
        'created_at': createdAt,
      });

      final exercisesCount = 3 + (i % 4);
      final shuffledExercises = (exercises..shuffle())
          .take(exercisesCount)
          .toList();

      for (final exerciseName in shuffledExercises) {
        final exerciseId = await createExercise({
          'workout_id': workoutId,
          'name': exerciseName,
        });

        final setsCount = 3 + (i % 3);
        for (int setNum = 0; setNum < setsCount; setNum++) {
          final baseWeight = _getBaseWeight(exerciseName);
          final weightVariation = (i * 2.5) + (setNum * 2.5);
          final weight = baseWeight + weightVariation;
          final reps = 8 + (setNum * 2) + (i % 3);

          await createSet({
            'exercise_id': exerciseId,
            'reps': reps,
            'weight': weight,
            'set_number': setNum + 1,
          });
        }
      }
    }
  }

  double _getBaseWeight(String exerciseName) {
    switch (exerciseName) {
      case 'Bench Press':
        return 60.0;
      case 'Squat':
        return 80.0;
      case 'Deadlift':
        return 100.0;
      case 'Overhead Press':
        return 40.0;
      case 'Barbell Row':
        return 50.0;
      case 'Pull-ups':
        return 0.0;
      case 'Dips':
        return 10.0;
      case 'Leg Press':
        return 120.0;
      case 'Lat Pulldown':
        return 50.0;
      case 'Bicep Curls':
        return 12.0;
      case 'Tricep Extensions':
        return 15.0;
      case 'Leg Curls':
        return 30.0;
      case 'Calf Raises':
        return 40.0;
      default:
        return 20.0;
    }
  }
}
