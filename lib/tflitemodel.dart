import 'package:tflite_flutter/tflite_flutter.dart'; // Make sure to import your TensorFlow Lite Flutter library

class InterpreterManager {
  static final InterpreterManager _instance = InterpreterManager._internal();
  late Interpreter _interpreter;

  // Private constructor
  InterpreterManager._internal();

  factory InterpreterManager() {
    return _instance;
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      print('Model loaded successfully.');
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Interpreter get interpreter {
    return _interpreter;
  }
}
