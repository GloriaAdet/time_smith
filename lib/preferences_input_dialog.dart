// preferences_input_dialog.dart

import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'user_preferences_model.dart';

class PreferencesInputDialog extends StatefulWidget {
  @override
  State<PreferencesInputDialog> createState() => _PreferencesInputDialogState();
}

class _PreferencesInputDialogState extends State<PreferencesInputDialog> {
  final TextEditingController _taskTypeController = TextEditingController();
  List<String> _preferredTaskTypes = [];
  final Map<String, int> _priorityLevels = {'High': 1, 'Medium': 2, 'Low': 3};
  String _selectedPriority = 'Medium'; // Default priority

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Preferences'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Task Type Input
            TextField(
              controller: _taskTypeController,
              decoration: const InputDecoration(labelText: 'Task Type'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_taskTypeController.text.isNotEmpty) {
                  setState(() {
                    _preferredTaskTypes.add(_taskTypeController.text);
                    _taskTypeController.clear();
                  });
                }
              },
              child: const Text('Add Task Type'),
            ),
            if (_preferredTaskTypes.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _preferredTaskTypes
                    .map((type) => ListTile(
                          title: Text(type),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _preferredTaskTypes.remove(type);
                              });
                            },
                          ),
                        ))
                    .toList(),
              ),
            const SizedBox(height: 16),
            // Priority Dropdown
            DropdownButton<String>(
              value: _selectedPriority,
              onChanged: (String? value) {
                setState(() {
                  _selectedPriority = value!;
                });
              },
              items: _priorityLevels.keys
                  .map((priority) => DropdownMenuItem(
                        value: priority,
                        child: Text(priority),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final preferences = UserPreferences(
              preferredTaskTypes: _preferredTaskTypes,
              priorityLevels: _priorityLevels,
            );
            await DatabaseHelper().saveUserPreferences(preferences.toMap());
            Navigator.of(context).pop(preferences);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
