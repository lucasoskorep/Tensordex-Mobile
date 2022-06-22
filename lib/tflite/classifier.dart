import 'dart:math';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import '../utils/logger.dart';
import '../utils/recognition.dart';
import '../utils/stats.dart';

/// Classifier
class Classifier {
  static const String MODEL_FILE_NAME = "detect.tflite";
  static const String LABEL_FILE_NAME = "labelmap.txt";

  /// Input size of image (height = width = 300)
  static const int INPUT_SIZE = 224;

  /// Result score threshold
  static const double THRESHOLD = 0.5;

  /// [ImageProcessor] used to pre-process the image
  ImageProcessor? imageProcessor;

  /// Padding the image to transform into square
  // int padSize = 0;
  /// Instance of Interpreter
  late Interpreter _interpreter;

  late TensorBuffer _outputBuffer;
  late var _probabilityProcessor;

  /// Labels file loaded as list
  late List<String> _labels;

  /// Number of results to show
  static const int NUM_RESULTS = 10;

  Classifier({
    Interpreter? interpreter,
    List<String>? labels,
  }) {
    loadModel(interpreter: interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  void loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            MODEL_FILE_NAME,
            options: InterpreterOptions()..threads = 4,
          );
      var outputTensor = _interpreter.getOutputTensor(0);
      var outputShape = outputTensor.shape;
      var outputType = outputTensor.type;

      var inputTensor = _interpreter.getInputTensor(0);
      var intputShape = inputTensor.shape;
      var intputType = inputTensor.type;

      _outputBuffer = TensorBuffer.createFixedSize(outputShape, outputType);
      _probabilityProcessor =
          TensorProcessorBuilder().add(NormalizeOp(0, 1)).build();
    } catch (e) {
      logger.e("Error while creating interpreter: ", e);
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels = labels ?? await FileUtil.loadLabels("assets/labels.txt");
    } catch (e) {
      logger.e("Error while loading labels: $e");
    }
  }

  /// Pre-process the image
  TensorImage? getProcessedImage(TensorImage inputImage) {
    // padSize = max(inputImage.height, inputImage.width);
    imageProcessor ??= ImageProcessorBuilder()
        // .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .add(NormalizeOp(127.5, 127.5))
        .build();
    return imageProcessor?.process(inputImage);
  }

  /// Runs object detection on the input image
  Map<String, dynamic>? predict(image_lib.Image image) {
    logger.i(labels);
    var predictStartTime = DateTime.now().millisecondsSinceEpoch;
    if (_interpreter == null) {
      logger.e("Interpreter not initialized");
      return null;
    }
    var preProcessStart = DateTime.now().millisecondsSinceEpoch;
    // Create TensorImage from image
    // Pre-process TensorImage
    var procImage = getProcessedImage(TensorImage.fromImage(image));

    var preProcessElapsedTime =
        DateTime.now().millisecondsSinceEpoch - preProcessStart;
    if (procImage != null) {
      var inferenceTimeStart = DateTime.now().millisecondsSinceEpoch;
      // run inference
      var inferenceTimeElapsed =
          DateTime.now().millisecondsSinceEpoch - inferenceTimeStart;

      logger.i("Sending image to ML");

      logger.i(procImage.buffer.asFloat32List());
      logger.i(procImage.width);
      logger.i(procImage.height);
      logger.i(procImage.tensorBuffer.shape);
      logger.i(procImage.tensorBuffer.isDynamic);
      _interpreter.run(procImage.buffer, _outputBuffer.getBuffer());

      Map<String, double> labeledProb = TensorLabel.fromList(
              labels, _probabilityProcessor.process(_outputBuffer))
          .getMapWithFloatValue();
      final pred = getTopProbability(labeledProb);
      Recognition rec = Recognition(1, pred.key, pred.value);
      var predictElapsedTime = DateTime.now().millisecondsSinceEpoch - predictStartTime;
      return {
        "recognitions": rec,
        "stats": Stats(predictElapsedTime, predictElapsedTime, predictElapsedTime, predictElapsedTime),
      };
    } else {
      return null;
    }
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String> get labels => _labels;
}

MapEntry<String, double> getTopProbability(Map<String, double> labeledProb) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);

  return pq.first;
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}
