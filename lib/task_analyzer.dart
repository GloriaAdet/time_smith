// task_analyzer.dart

import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart';

class TaskAnalyzer {
  static Interpreter? _interpreter;
  static List<String>? _labels;

  // Initialize the TFLite model and labels
  static Future<void> initialize() async {
    // Load the TFLite model
    _interpreter = await Interpreter.fromAsset(
        'assets/BERTmodel/createBertModel/taskClassifier.tflite');

    // Load the label encoder JSON
    String labelData = await rootBundle
        .loadString('assets/BERTmodel/createBertModel/labelEncoder.json');
    final Map<String, dynamic> labelMap = jsonDecode(labelData);

    // Extract the keys (labels) into a list
    _labels = List<String>.from(labelMap.keys);
  }

  // Analyze task type using the TFLite model
  static String analyzeTaskType(String taskName, String taskDescription) {
    if (_interpreter == null || _labels == null) {
      throw Exception("TaskAnalyzer not initialized. Call initialize() first.");
    }

    // Combine taskName and taskDescription as input
    String inputText = "$taskName. $taskDescription";

    // Tokenize input (implement tokenization logic here to match vocab.txt)
    List<int> inputIds = _tokenizeInput(inputText);

    // Create input and output tensors
    var input = [inputIds];
    var output =
        List<double>.filled(_labels!.length, 0).reshape([1, _labels!.length]);

    // Run inference
    _interpreter!.run(input, output);

    // Get the predicted label index
    int predictedIndex =
        output[0].indexOf(output[0].reduce((a, b) => a > b ? a : b));

    // Return the corresponding label
    return _labels![predictedIndex];
  }

  // Tokenize the input text to match vocab.txt
  static List<int> _tokenizeInput(String inputText) {
    // Implement tokenization that aligns with your BERT tokenizer's vocab.txt
    // Placeholder logic for demo purposes:
    return List.generate(128, (index) => index); // Replace with real token IDs
  }
}
