
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';

/// Classifier
abstract class Classifier {

  ///Interpreter for the classifier
  late Interpreter _interpreter;

  ///Set of labels for the classifier
  late List<String> _labels;

  Classifier._create(
      Interpreter interpreter, {
        List<String>? labels,
      }) {
    _interpreter = interpreter;
    labels = labels;
  }

  /// Loads interpreter from asset
  Future<Interpreter> loadModel(Interpreter interpreter);

  /// Loads labels from assets
  Future<List<String>?> loadLabels({List<String>? labels});

  /// Sets whether or not the processed frame should be returned to the application
  void setReturnFrame(bool returnFrame);

  /// Runs object detection on the input image
  Future<Map<String, dynamic>?> predict(image_lib.Image image);

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String> get labels => _labels;
}
