import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:image/image.dart' as image_lib;
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

import 'model/outputs/recognition.dart';
import '../utils/logger.dart';
import 'model/outputs/stats.dart';

/// Classifier
class Classifier {
  static const String modelFileName = 'efficientnet_v2s.tflite';
  static const int inputSize = 224;

  /// [ImageProcessor] used to pre-process the image
  ImageProcessor? imageProcessor;

  ///Tensor image to move image outputs into
  late TensorImage _inputImage;

  /// Instance of Interpreter
  late Interpreter _interpreter;
  late TensorBuffer _outputBuffer;
  late TfLiteType _inputType;
  late TfLiteType _outputType;

  late SequentialProcessor<TensorBuffer> _outputProcessor;

  /// Labels file loaded as list
  late List<String> _labels;
  int classifierCreationStart = -1;
  bool _shouldReturnFrame = false;

  Classifier(
    Interpreter interpreter, {
    List<String>? labels,
  }) {
    loadModel(interpreter);
    loadLabels(labels: labels);
  }

  /// Loads interpreter from asset
  void loadModel(Interpreter interpreter) async {
    try {
      _interpreter = interpreter;
      var outputTensor = _interpreter.getOutputTensor(0);
      var outputShape = outputTensor.shape;
      _outputType = outputTensor.type;
      var inputTensor = _interpreter.getInputTensor(0);
      _inputType = inputTensor.type;
      _inputImage = TensorImage(_inputType);
      _outputBuffer = TensorBuffer.createFixedSize(outputShape, _outputType);
      _outputProcessor =
          TensorProcessorBuilder().add(NormalizeOp(0, 1)).build();
    } catch (e) {
      logger.e('Error while creating interpreter: ', e);
    }
  }

  /// Loads labels from assets
  void loadLabels({List<String>? labels}) async {
    try {
      _labels = labels ?? await FileUtil.loadLabels('assets/labels.txt');
    } catch (e) {
      logger.e('Error while loading labels: $e');
    }
  }

  void setReturnFrame(bool returnFrame) {
    _shouldReturnFrame = returnFrame;
  }

  /// Pre-process the image
  TensorImage? getProcessedImage(TensorImage? inputImage) {
    int cropSize = min(_inputImage.height, _inputImage.width);
    if (inputImage != null) {
      imageProcessor ??= ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(cropSize, cropSize))
          .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
          .add(NormalizeOp(0, 1))
          // .add(NormalizeOp(127.5, 127.5)) // photo vs quant normalization
          .build();
      return imageProcessor?.process(inputImage);
    }
    return null;
  }

  /// Runs object detection on the input image
  Future<Map<String, dynamic>?> predict(image_lib.Image image) async {
    var preProcStart = DateTime.now().millisecondsSinceEpoch;
    _inputImage.loadImage(image_lib.copyRotate(image, 90));
    _inputImage = getProcessedImage(_inputImage)!;


    var inferenceStart = DateTime.now().millisecondsSinceEpoch;
        _interpreter.run(_inputImage.buffer, _outputBuffer.getBuffer());
    var postProcStart = DateTime.now().millisecondsSinceEpoch;
    Map<String, double> labeledProb =
        TensorLabel.fromList(labels, _outputProcessor.process(_outputBuffer))
            .getMapWithFloatValue();
    final predictions = getTopProbabilities(labeledProb, number: 5)
        .mapIndexed(
            (index, element) => Recognition(index, element.key, element.value))
        .toList();
    var endTime = DateTime.now().millisecondsSinceEpoch;
    return {
      'recognitions': predictions,
      'stats': Stats(
        totalTime: endTime - preProcStart,
        preProcessingTime: inferenceStart - preProcStart,
        inferenceTime: postProcStart - inferenceStart,
        postProcessingTime: endTime - postProcStart,
      ),
      'image': _shouldReturnFrame? _inputImage.image : null,
    };
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  /// Gets the loaded labels
  List<String> get labels => _labels;
}

List<MapEntry<String, double>> getTopProbabilities(
    Map<String, double> labeledProb,
    {int number = 3}) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);
  return [for (var i = 0; i < number; i += 1) pq.removeFirst()];
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
