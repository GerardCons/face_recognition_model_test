import 'dart:io';
import 'package:face_recognition_test/tflitemodel.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart';

void main() {
  runApp(const FaceRecognitionApp());
}

class FaceRecognitionApp extends StatelessWidget {
  const FaceRecognitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FaceRecognitionScreen(),
    );
  }
}

class FaceRecognitionScreen extends StatefulWidget {
  @override
  _FaceRecognitionScreenState createState() => _FaceRecognitionScreenState();
}

class _FaceRecognitionScreenState extends State<FaceRecognitionScreen> {
  late Interpreter _interpreter;
  String _result = "Press the button to run face recognition";

  @override
  void initState() {
    super.initState();
    InterpreterManager().loadModel();
  }

  Future<void> _runFaceRecognition() async {
    try {
      // Load the image from assets
      final ByteData data = await rootBundle.load('assets/obama.jpg');
      final List<int> bytes = data.buffer.asUint8List();
      final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;

      // Resize the image to the model's expected dimensions (e.g., 112x112)
      img.Image resizedImage = img.copyResize(image, width: 112, height: 112);

      // Prepare the input as a 4D tensor [1, height, width, channels]
      List<List<List<List<double>>>> input = [
        List.generate(
          112,
          (y) => List.generate(
            112,
            (x) {
              final int pixel = resizedImage.getPixel(x, y);

              // Extract RGB values from the pixel
              final double r = img.getRed(pixel) / 255.0;
              final double g = img.getGreen(pixel) / 255.0;
              final double b = img.getBlue(pixel) / 255.0;

              return [r, g, b];
            },
          ),
        )
      ];

      // Define the output buffer with the correct shape for the model's output
      var output = List.filled(1 * 192, 0.0).reshape([1, 192]);

      // Get the interpreter from the global InterpreterManager
      _interpreter = InterpreterManager().interpreter;

      // Run the model
      _interpreter.run(input, output);
      print("Face embedding vector:\n${output[0]}");

      // Update state with the result
      setState(() {
        _result = "Face embedding vector:\n${output[0]}";
      });
    } catch (e) {
      print(e);
      setState(() {
        _result = "Error running model: $e";
      });
    }
  }

  @override
  void dispose() {
    _interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Face Recognition Test")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_result, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _runFaceRecognition,
                child: const Text("Run Face Recognition"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
