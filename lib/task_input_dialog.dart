// task_input_dialog.dart

import 'package:flutter/material.dart';
import 'task_model.dart';
import 'package:intl/intl.dart';

class TaskInputDialog extends StatefulWidget {
  @override
  State<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends State<TaskInputDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _priority = 'Medium'; // Default priority
  DateTime _dueDate = DateTime.now(); // Default due date
  TimeOfDay _dueTime = TimeOfDay.now(); // Default time

  // Helper functions to format date and time
  String get formattedDate => DateFormat.yMMMd().format(_dueDate);
  String get formattedTime => _dueTime.format(context);

  // Show date picker
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  // Show time picker
  Future<void> _selectTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );

    if (pickedTime != null) {
      setState(() {
        _dueTime = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            DropdownButton<String>(
              value: _priority,
              onChanged: (String? newValue) {
                setState(() {
                  _priority = newValue!;
                });
              },
              items: ['High', 'Medium', 'Low']
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text(formattedDate),
                    onTap: _selectDate,
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text(formattedTime),
                    onTap: _selectTime,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final newTask = Task(
              name: _nameController.text,
              description: _descriptionController.text,
              priority: _priority,
              date: DateTime(
                _dueDate.year,
                _dueDate.month,
                _dueDate.day,
                _dueTime.hour,
                _dueTime.minute,
              ),
              time: _dueTime.format(context), // Pass time here as string
            );
            Navigator.of(context).pop(newTask);
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
