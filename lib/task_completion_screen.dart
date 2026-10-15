import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task_model.dart'; // Assuming task model and database logic are in place
import 'database_helper.dart';

class TaskCompletionScreen extends StatefulWidget {
  const TaskCompletionScreen({super.key});

  @override
  State<TaskCompletionScreen> createState() => _TaskCompletionScreenState();
}

class _TaskCompletionScreenState extends State<TaskCompletionScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late DatabaseHelper _dbHelper;
  Map<DateTime, List<Task>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = await _dbHelper.getTasks();
    setState(() {
      _tasksByDate = _groupTasksByDate(tasks);
    });
  }

  Map<DateTime, List<Task>> _groupTasksByDate(List<Task> tasks) {
    Map<DateTime, List<Task>> tasksByDate = {};
    for (var task in tasks) {
      DateTime taskDate =
          DateTime(task.date.year, task.date.month, task.date.day);
      if (tasksByDate[taskDate] == null) {
        tasksByDate[taskDate] = [];
      }
      tasksByDate[taskDate]!.add(task);
    }
    return tasksByDate;
  }

  List<Task> _getTasksForDay(DateTime day) {
    return _tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showTaskPopup(BuildContext context, DateTime day) {
    List<Task> tasks = _getTasksForDay(day);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title:
                  Text('Tasks for ${day.toLocal().toString().split(' ')[0]}'),
              content: tasks.isEmpty
                  ? const Text('No tasks for this day.')
                  : SizedBox(
                      width: double.maxFinite,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          Task task = tasks[index];
                          return ListTile(
                            title: Text(task.name,
                                style: TextStyle(
                                  decoration: task.progress == 100.0
                                      ? TextDecoration.lineThrough
                                      : null,
                                )),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(task.description),
                                Slider(
                                  value: task.progress,
                                  min: 0,
                                  max: 100,
                                  divisions: 10,
                                  label: "${task.progress.toInt()}%",
                                  onChanged: (value) {
                                    setState(() {
                                      task.progress = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                            trailing: Checkbox(
                              value: task.progress == 100.0,
                              onChanged: (value) {
                                setState(() {
                                  task.progress = value! ? 100.0 : 0.0;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    for (var task in tasks) {
                      await _dbHelper.insertTask(task);
                    }
                    Navigator.pop(context);
                    _loadTasks();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Calendar'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2000, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
              _showTaskPopup(context, selectedDay);
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            eventLoader: _getTasksForDay,
            calendarBuilders: CalendarBuilders(
              todayBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
              selectedBuilder: (context, date, _) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    '${date.day}',
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
