// user_preferences_model.dart

import 'dart:convert'; // For JSON decoding

class UserPreferences {
  final List<String> preferredTaskTypes;
  final Map<String, int> priorityLevels;

  UserPreferences({
    required this.preferredTaskTypes,
    required this.priorityLevels,
  });

  Map<String, dynamic> toMap() {
    return {
      'preferredTaskTypes': preferredTaskTypes
          .join(','), // Convert list to a comma-separated string
      'priorityLevels':
          json.encode(priorityLevels), // Convert map to JSON string
    };
  }

  factory UserPreferences.fromMap(Map<String, dynamic> map) {
    // Parse preferredTaskTypes safely
    final types = (map['preferredTaskTypes'] as String?)?.split(',') ?? [];

    // Parse priorityLevels safely
    final priorities = _parsePriorityLevels(map['priorityLevels']);

    return UserPreferences(
      preferredTaskTypes: types,
      priorityLevels: priorities,
    );
  }

  /// Helper method to parse priority levels
  static Map<String, int> _parsePriorityLevels(dynamic priorityLevels) {
    if (priorityLevels == null) {
      return <String, int>{};
    }
    if (priorityLevels is String) {
      // Try parsing as JSON
      try {
        return Map<String, int>.from(
          json.decode(priorityLevels) as Map<String, dynamic>,
        );
      } catch (e) {
        // If not JSON, handle the Dart Map-like string
        final regex = RegExp(r'(\w+)=([0-9]+)'); // Matches "key=value"
        return Map.fromEntries(
          regex.allMatches(priorityLevels).map(
              (match) => MapEntry(match.group(1)!, int.parse(match.group(2)!))),
        );
      }
    }
    if (priorityLevels is Map<String, dynamic>) {
      return Map<String, int>.from(priorityLevels);
    }
    return <String, int>{}; // Default to empty map
  }
}
