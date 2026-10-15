// home_screen.dart

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task_model.dart';
import 'task_input_dialog.dart';
import 'user_preferences_model.dart';
//import 'preferences_input_dialog.dart';
import 'package:intl/intl.dart'; // For date formatting

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  UserPreferences? _userPreferences;

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadUserPreferences();
  }

  Future<void> _loadTasks() async {
    // Manually set, if there are no tasks, programmatically add them
    if (true) {
      // Example tasks to add
      List<Task> exampleTasks = [
        Task(
          name: 'Morning Exercise',
          description: 'Go for a 30-minute jog in the park.',
          priority: 'High',
          date: DateTime.now(), // Today's date
          time: '7:00 AM',
          progress: 0,
        ),
        Task(
          name: 'Team Meeting',
          description: 'Attend the project status update meeting.',
          priority: 'Medium',
          date: DateTime.now(),
          time: '10:00 AM',
          progress: 0,
        ),
        Task(
          name: 'Lunch with Sarah',
          description: 'Discuss the new design ideas.',
          priority: 'Low',
          date: DateTime.now(),
          time: '1:00 PM',
          progress: 0,
        ),
        Task(
          name: 'Code Review',
          description: 'Review the new pull requests on GitHub.',
          priority: 'High',
          date: DateTime.now().add(Duration(days: 1)), // Tomorrow's date
          time: '3:00 PM',
          progress: 0,
        ),
        Task(
          name: 'Grocery Shopping',
          description: 'Buy groceries for the week.',
          priority: 'Medium',
          date: DateTime.now().add(Duration(days: 2)), // Day after tomorrow
          time: '6:00 PM',
          progress: 0,
        ),
        Task(
          name: 'Organize Workspace',
          description: 'Declutter desk and organize files',
          priority: 'Low',
          date: DateTime.now().add(Duration(days: 5)), // Day after tomorrow
          time: '9:00 AM',
          progress: 0,
        ),
        Task(
          name: 'Set New Year Goals',
          description: 'Outline personal and professional goals for 2025',
          priority: 'Low',
          date: DateTime.now().add(Duration(days: 30)),
          time: '6:00 PM',
          progress: 0,
        )
      ];

      // Insert tasks into the database
      for (var task in exampleTasks) {
        await _dbHelper.insertTask(task);
        print('Task added: ${task.name}');
      }
    }

    final tasks = await _dbHelper.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  Future<void> _loadUserPreferences() async {
    final preferences = await _dbHelper.getUserPreferences();
    setState(() {
      _userPreferences = UserPreferences.fromMap(preferences);
    });
  }

  // Show Preferences Dialog
  Future<void> _showPreferencesDialog() async {
    final Map<String, String> updatedPreferences = {};

    final predefinedTaskTypes = [
      'Work',
      'Personal',
      'Exercise',
      'Finance',
      'Health'
    ];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set Task Priorities'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: predefinedTaskTypes.map((type) {
                  // Get the current priority as an int value
                  final currentPriority =
                      _userPreferences?.priorityLevels[type];
                  // Convert the int priority to a string
                  String priorityString = _getPriorityString(currentPriority);

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(type),
                      DropdownButton<String>(
                        value: priorityString,
                        items: ['Low', 'Medium', 'High']
                            .map((priority) => DropdownMenuItem<String>(
                                  value: priority,
                                  child: Text(priority),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              updatedPreferences[type] =
                                  newValue; // Update the local map
                            });
                          }
                        },
                      ),
                    ],
                  );
                }).toList(),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without saving
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Convert string preferences back to integers before saving
                final convertedPreferences =
                    _convertPreferences(updatedPreferences);
                await _dbHelper.saveUserPreferences(convertedPreferences);
                _loadUserPreferences(); // Reload preferences
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Helper method to convert integer priorities to strings for the dropdown
  String _getPriorityString(int? priority) {
    if (priority == 1) {
      return 'Low';
    } else if (priority == 3) {
      return 'High';
    }
    return 'Medium'; // Default to Medium
  }

  /// Helper method to convert the updated preferences to the correct format
  Map<String, int> _convertPreferences(Map<String, String> updatedPreferences) {
    final Map<String, int> converted = {};
    updatedPreferences.forEach((key, value) {
      if (value == 'Low') {
        converted[key] = 1;
      } else if (value == 'High') {
        converted[key] = 3;
      } else {
        converted[key] = 2; // Default to Medium
      }
    });
    return converted;
  }

  void _addTask() async {
    final Task? newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return TaskInputDialog();
      },
    );

    if (newTask != null) {
      await _dbHelper.insertTask(newTask);
      _loadTasks();
    }
  }

  void _deleteTask(int id) async {
    await _dbHelper.deleteTask(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showPreferencesDialog,
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(
              child: Text(
                'No tasks available.',
                style: TextStyle(fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                final dueDateTime = task.date;

                return ListTile(
                  title: Text(task.name),
                  subtitle: Text(
                    '${task.description}\nPriority: ${task.priority}\nDue: ${DateFormat.yMMMd().add_jm().format(dueDateTime)}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteTask(task.id!);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
