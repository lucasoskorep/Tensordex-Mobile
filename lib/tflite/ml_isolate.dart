import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:tensordex_mobile/tflite/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../utils/image_utils.dart';
import '../utils/logger.dart';

class IsolateBase {
  final ReceivePort _receivePort = ReceivePort();
}

class MLIsolate extends IsolateBase {
  static const String debugIsolate = "MLIsolate";
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;

  Future<void> start() async {
    await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: debugIsolate,
    );
    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final MLIsolateData mlIsolateData in port) {
      var cameraImage = mlIsolateData.cameraImage;
      var converted = ImageUtils.convertCameraImage(cameraImage);
      if (converted != null) {
        Classifier classifier = Classifier(
            interpreter:
                Interpreter.fromAddress(mlIsolateData.interpreterAddress),
            labels: mlIsolateData.labels);
        var result = classifier.predict(converted);
        mlIsolateData.responsePort?.send(result);
      } else {
        mlIsolateData.responsePort?.send({"response": "not working yet"});
      }
    }
  }
}

/// Bundles data to pass between Isolate
class MLIsolateData {
  CameraImage cameraImage;
  int interpreterAddress;
  List<String> labels;
  SendPort? responsePort;

  MLIsolateData(
    this.cameraImage,
    this.interpreterAddress,
    this.labels,
  );
}
