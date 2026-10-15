import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'task_model.dart';

class AdaptScreen extends StatefulWidget {
  const AdaptScreen({Key? key}) : super(key: key);

  @override
  _AdaptScreenState createState() => _AdaptScreenState();
}

class _AdaptScreenState extends State<AdaptScreen> {
  late Future<List<Task>> _dailyTasksFuture;

  // Example of a userPreferences map. You need to replace it with actual data
  Map<String, int> userPreferences = {
    "taskPriority": 1, // Example preference
    "timeManagement": 2 // Example preference
  };

  @override
  void initState() {
    super.initState();
    _loadDailyTasks();
  }

  void _loadDailyTasks() {
    _dailyTasksFuture = _fetchDailyTasks();
  }

  Future<List<Task>> _fetchDailyTasks() async {
    DatabaseHelper dbHelper = DatabaseHelper();
    List<Task> allTasks = await dbHelper.getTasks(); // Fetch all tasks
    return dbHelper.getDailyTasks(
        allTasks, userPreferences); // Pass both tasks and preferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Adapt"),
      ),
      body: FutureBuilder<List<Task>>(
        future: _dailyTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No tasks for today."));
          }

          final tasks = snapshot.data!;
          return Column(
            children: [
              Expanded(
                child: Container(
                  height: MediaQuery.of(context)
                      .size
                      .height, // Using screen height for constraint
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return ListTile(
                        title: Text(task.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize:
                              MainAxisSize.min, // Avoid infinite height
                          children: [
                            Text("${task.date} - ${task.time}"),
                            Text(
                                "Progress: ${task.progress.toStringAsFixed(1)}%"),
                          ],
                        ),
                        trailing: LinearProgressIndicator(
                          value: task.progress / 100, // Convert to 0-1 scale
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
