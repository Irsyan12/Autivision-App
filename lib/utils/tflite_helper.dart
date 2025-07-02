// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// class TFLiteHelper {
//   Interpreter? _interpreter;
//   List<String>? _labels;

//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('assets/asd.tflite');
//       print('Model loaded successfully');
//     } catch (e) {
//       print('Failed to load model: $e');
//     }

//     final labelsData = await rootBundle.loadString('assets/label.txt');
//     _labels =
//         labelsData.split('\n').where((element) => element.isNotEmpty).toList();
//   }

//   Future<Map<String, double>> classifyImage(File image) async {
//     if (_interpreter == null || _labels == null) {
//       await loadModel();
//     }

//     var imageBytes = await image.readAsBytes();
//     var input = _processRawImage(imageBytes);

//     var output = List.filled(1, List.filled(_labels!.length, 0.0));
//     _interpreter!.run(input, output);

//     // Get the maximum confidence index
//     int maxIndex = output[0].indexWhere(
//         (value) => value == output[0].reduce((a, b) => a > b ? a : b));

//     // Logging output values for debugging
//     print("Output values: ${output[0]}");
//     print("Max index: $maxIndex");

//     // Create a map to store label and confidence values
//     Map<String, double> results = {};
//     for (int i = 0; i < _labels!.length; i++) {
//       results[_labels![i]] = output[0][i];
//     }

//     return results;
//   }

//   List<List<List<List<double>>>> _processRawImage(Uint8List imageBytes) {
//     final image = img.decodeImage(imageBytes)!;
//     final resizedImage = img.copyResize(image, width: 224, height: 224);
//     var input = List.generate(
//         1,
//         (i) => List.generate(
//             224, (j) => List.generate(224, (k) => List.filled(1, 0.0))));

//     for (int x = 0; x < 224; x++) {
//       for (int y = 0; y < 224; y++) {
//         final pixel = resizedImage.getPixel(x, y);
//         final red = img.getRed(pixel);
//         final green = img.getGreen(pixel);
//         final blue = img.getBlue(pixel);
//         final grayscaleValue = (red + green + blue) / 3.0 / 255.0;
//         input[0][y][x][0] = grayscaleValue;
//       }
//     }

//     return input;
//   }
// }

// asd2.tflite
// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;

// class TFLiteHelper {
//   Interpreter? _interpreter;
//   List<String>? _labels;

//   Future<void> loadModel() async {
//     try {
//       _interpreter = await Interpreter.fromAsset('assets/asd2.tflite');
//       print('Model loaded successfully');
//     } catch (e) {
//       print('Failed to load model: $e');
//     }

//     final labelsData = await rootBundle.loadString('assets/label.txt');
//     _labels =
//         labelsData.split('\n').where((element) => element.isNotEmpty).toList();
//   }

//   Future<Map<String, double>> classifyImage(File image) async {
//     if (_interpreter == null || _labels == null) {
//       await loadModel();
//     }

//     var input = _processRawImage(image);

//     var output = List.filled(1, List.filled(1, 0.0));
//     _interpreter!.run(input, output);

//     // Logging output values for debugging
//     print("Output value: ${output[0][0]}");

//     Map<String, double> results = {
//       _labels![0]: output[0][0]
//     };

//     return results;
//   }

//   Uint8List _processRawImage(File imageFile) {
//     final image = img.decodeImage(imageFile.readAsBytesSync())!;
//     final resizedImage = img.copyResize(image, width: 224, height: 224);

//     var input = Float32List(1 * 224 * 224 * 3);
//     var buffer = Float32List.view(input.buffer);

//     for (int y = 0; y < 224; y++) {
//       for (int x = 0; x < 224; x++) {
//         var idx = (y * 224 + x);

//         var pixel = resizedImage.getPixel(x, y);
//         buffer[idx + 0 * 224 * 224] = img.getRed(pixel) / 255;
//         buffer[idx + 1 * 224 * 224] = img.getGreen(pixel) / 255;
//         buffer[idx + 2 * 224 * 224] = img.getBlue(pixel) / 255;
//       }
//     }

//     return input.buffer.asUint8List();
//   }
// }

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class TFLiteHelper {
  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/asd_model.tflite');
      print('Model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
    }

    final labelsData = await rootBundle.loadString('assets/label.txt');
    _labels =
        labelsData.split('\n').where((element) => element.isNotEmpty).toList();
  }

  Future<Map<String, double>> classifyImage(File image) async {
    if (_interpreter == null || _labels == null) {
      await loadModel();
    }

    var input = _processRawImage(image);

    var output = List.filled(1, List.filled(1, 0.0));
    _interpreter!.run(input, output);

    // Logging output values for debugging
    print("Output values: ${output[0]}");

    double probabilityAutistic = output[0][0];
    double probabilityNonAutistic = 1 - probabilityAutistic;

    Map<String, double> results = {
      _labels![0]: probabilityAutistic,
      _labels![1]: probabilityNonAutistic,
    };

    return results;
  }

  Uint8List _processRawImage(File imageFile) {
    final image = img.decodeImage(imageFile.readAsBytesSync())!;
    final resizedImage = img.copyResize(image, width: 224, height: 224);

    var input = Float32List(1 * 224 * 224 * 3);
    var buffer = Float32List.view(input.buffer);

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        var idx = (y * 224 + x) * 3;

        var pixel = resizedImage.getPixel(x, y);
        buffer[idx] = pixel.r.toDouble() / 255.0; // Nilai Red
        buffer[idx + 1] = pixel.g.toDouble() / 255.0; // Nilai Green
        buffer[idx + 2] = pixel.b.toDouble() / 255.0; // Nilai Blue
      }
    }

    return input.buffer.asUint8List();
  }
}
