class Task {
  int? id;
  final String name;
  final String description;
  String priority;
  DateTime date;
  String time; // Add the time field
  double progress; // Add the progress field (0 to 100)

  Task({
    this.id,
    required this.name,
    required this.description,
    required this.priority,
    required this.date,
    required this.time, // Add time as a required parameter
    this.progress = 0.0, // Default progress is 0 (not started)
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'priority': priority,
      'date': date.toIso8601String(),
      'time': time, // Include time in the map
      'progress': progress, // Include progress in the map
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      priority: map['priority'],
      date: DateTime.parse(map['date']),
      time: map['time'] ?? "", // Extract time from the map
      progress: map['progress'] != null
          ? map['progress'] as double
          : 0.0, // Extract progress
    );
  }
}
