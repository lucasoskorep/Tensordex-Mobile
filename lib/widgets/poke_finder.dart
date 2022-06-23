import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tensordex_mobile/tflite/ml_isolate.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../tflite/classifier.dart';
import '../utils/logger.dart';
import '../tflite/data/recognition.dart';
import '../tflite/data/stats.dart';

/// [PokeFinder] sends each frame for inference
class PokeFinder extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<Recognition> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  /// Constructor
  const PokeFinder(
      {Key? key, required this.resultsCallback, required this.statsCallback})
      : super(key: key);

  @override
  State<PokeFinder> createState() => _PokeFinderState();
}

class _PokeFinderState extends State<PokeFinder> with WidgetsBindingObserver {
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  late MLIsolate _mlIsolate;

  /// true when inference is ongoing
  bool predicting = false;
  bool _cameraInitialized = false;
  bool _classifierInitialized = false;

  late Interpreter interpreter;
  late Classifier classifier;

  @override
  void initState() {
    initStateAsync();
    super.initState();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);
    _mlIsolate = MLIsolate();
    await _mlIsolate.start();
    initializeCamera();
    initializeModel();
    predicting = false;
  }

  void initializeModel() async {
    var interpreterOptions = InterpreterOptions()..threads = 8;
    interpreter = await Interpreter.fromAsset('efficientnet_v2s.tflite',
        options: interpreterOptions);
    classifier = Classifier(interpreter: interpreter);
    _classifierInitialized = true;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController =
        CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    cameraController.initialize().then((_) async {
      /// previewSize is size of each image frame captured by controller
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);
      setState(() {
        _cameraInitialized = true;
      });
    });
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    if (_classifierInitialized) {
      if (predicting) {
        return;
      }
      setState(() {
        predicting = true;
      });
      var results = await inference(MLIsolateData(
          cameraImage, classifier.interpreter.address, classifier.labels));

      if (results.containsKey("recognitions")) {
        widget.resultsCallback(results["recognitions"]);
      }
      if (results.containsKey("stats")) {
        widget.statsCallback(results["stats"]);
      }
      logger.i(results);

      setState(() {
        predicting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (!_cameraInitialized) {
      return Container();
    }
    return AspectRatio(
        aspectRatio: 1 / cameraController.value.aspectRatio,
        child: CameraPreview(cameraController));
  }

  /// Runs inference in another isolate
  Future<Map<String, dynamic>> inference(MLIsolateData mlIsolateData) async {
    ReceivePort responsePort = ReceivePort();
    _mlIsolate.sendPort
        .send(mlIsolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.paused:
        cameraController.stopImageStream();
        break;
      case AppLifecycleState.resumed:
        if (!cameraController.value.isStreamingImages) {
          await cameraController.startImageStream(onLatestImageAvailable);
        }
        break;
      default:
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    super.dispose();
  }
}
