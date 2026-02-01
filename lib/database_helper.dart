import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
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

      result.add({
        'exercise': exercise,
        'sets': sets,
      });
    }

    return result;
  }

  Future<List<Map<String, dynamic>>> getExerciseHistory(String exerciseName) async {
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
        history.add({
          'date': workout[0]['date'],
          'sets': sets,
        });
      }
    }

    history.sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
    return history;
  }

  Future<List<String>> getAllExerciseNames() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT name FROM exercises ORDER BY name ASC'
    );
    return result.map((e) => e['name'] as String).toList();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
