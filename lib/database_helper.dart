// database_helper.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'task_model.dart';
//import 'user_preferences_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  // Getter for database
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize the SQLite database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'tasks.db');
    return await openDatabase(
      path,
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Handle upgrades if needed
    );
  }

  // Create tables when the database is first created
  Future<void> _onCreate(Database db, int version) async {
    // Create the tasks table
    await db.execute('''
  CREATE TABLE tasks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    description TEXT,
    priority TEXT NOT NULL,
    date TEXT NOT NULL,
    time TEXT,
    progress REAL DEFAULT 0.0
  )
''');

    // Create the user_preferences table
    await db.execute('''
      CREATE TABLE user_preferences (
        type TEXT PRIMARY KEY,
        priority INTEGER NOT NULL
      )
    ''');
  }

  // Upgrade database with changes (done manuualy)
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // if (newVersion == 4) {
    //   // Added time column in the second version of the database
    //   // added progress colum in the third version of the database
    //   await db
    //       .execute('ALTER TABLE tasks ADD COLUMN progress REAL DEFAULT 0.0');

    //    await db.execute('''
    //   UPDATE tasks
    //   SET progress = 0.0
    //   WHERE progress IS NULL
    // ''');
    // }
  }

  // ------------------------------
  // Task Management Methods
  // ------------------------------

  // Insert a new task
  Future<int> insertTask(Task task) async {
    final db = await database;
    return await db.insert('tasks', task.toMap());
  }

  // Retrieve all tasks
  Future<List<Task>> getTasks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('tasks');
    return List.generate(maps.length, (i) => Task.fromMap(maps[i]));
  }

  // Delete a task by its ID
  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Fetch and rank tasks based on user preferences and deadlines
  List<Task> getDailyTasks(List<Task> tasks, Map<String, int> userPreferences) {
    final today = DateTime.now();

    // Helper function to calculate the number of days until a task is due
    int daysUntilDue(DateTime dueDate) {
      return dueDate.difference(today).inDays;
    }

    // Linear regression weights (these can be tuned based on user feedback)
    const double priorityWeight = 0.4;
    const double dueDateWeight = 0.3;
    const double userPreferenceWeight = 0.2;
    const double progressWeight =
        -0.1; // Negative because less progress should have higher importance

    // Calculate importance score for each task
    List<Map<String, dynamic>> scoredTasks = tasks.map((task) {
      // Assign numeric values for priority (e.g., "High" = 3, "Medium" = 2, "Low" = 1)
      int priorityValue = task.priority.toLowerCase() == 'high'
          ? 3
          : task.priority.toLowerCase() == 'medium'
              ? 2
              : 1;

      // Days until the task is due (negative if overdue)
      int daysLeft = daysUntilDue(task.date);

      // Get user preference score for the task type (default to 1 if no preference)
      int userPreferenceScore = userPreferences[task.name] ?? 1;

      // Calculate the importance score using the linear regression formula
      double importanceScore = (priorityWeight * priorityValue) +
          (dueDateWeight *
              (1 / (daysLeft.abs() + 1))) + // Avoid division by zero
          (userPreferenceWeight * userPreferenceScore) +
          (progressWeight * task.progress);

      return {
        'task': task,
        'score': importanceScore,
      };
    }).toList();

    // Sort tasks by importance score in descending order
    scoredTasks.sort((a, b) => b['score'].compareTo(a['score']));

    // Return the top 4 tasks
    return scoredTasks.take(4).map((entry) => entry['task'] as Task).toList();
  }

  Future<int> updateTaskProgress(int taskId, double progress) async {
    final db = await database;
    return await db.update(
      'tasks',
      {'progress': progress},
      where: 'id = ?',
      whereArgs: [taskId],
    );
  }

  // ------------------------------
  // User Preferences Methods
  // ------------------------------

  // Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final db = await database;

    // Clear old preferences
    await db.delete('user_preferences');

    // Insert new preferences
    preferences.forEach((type, priority) async {
      await db.insert(
        'user_preferences',
        {'type': type, 'priority': priority},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  // Retrieve user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('user_preferences');

    // Convert the query result into a map of type to priority
    return {
      for (var map in maps) map['type']: map['priority'],
    };
  }
}
