import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tensordex_mobile/tflite/ml_isolate.dart';
import 'package:tensordex_mobile/tflite/model/configuration.dart';
import 'package:tensordex_mobile/tflite/model/outputs/stats.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../main.dart';
import '../tflite/classifier.dart';
import '../tflite/model/outputs/recognition.dart';
import '../utils/logger.dart';

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
  /// true when inference is ongoing
  bool predicting = false;
  bool _cameraInitialized = false;
  bool _classifierInitialized = false;
  bool _saveClassifierImage = false;
  int cameraIndex = 0;

  late CameraController cameraController;

  //ml variables
  late Interpreter interpreter;
  late Classifier classifier;
  late MLIsolate _mlIsolate;
  late List<ModelConfiguration> modelConfigurations;

  @override
  void initState() {
    initStateAsync();
    super.initState();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);
    _mlIsolate = MLIsolate();
    await _mlIsolate.start();
    swapToCamera(cameras[0]);
    for (CameraDescription cam in cameras) {
      logger.i(cam);
    }
    initializeModel();
    predicting = false;
  }

  Future<List<String>> getModelFiles() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    return manifestMap.keys
        .where((String key) => key.contains('.tflite'))
        .map((String key) => key.substring(7))
        .toList();
  }

  void initializeModel() async {
    var modelFiles = await getModelFiles();
    var modelConfigurations =
        modelFiles.map((e) => ModelConfiguration(e)).toList();
    var currentConfig = modelConfigurations[0];
    logger.i(modelFiles);
    interpreter = await createInterpreter(currentConfig);
    classifier = Classifier(interpreter);
    _classifierInitialized = true;
  }

  Future<Interpreter> createInterpreter(ModelConfiguration config) async {
    return await Interpreter.fromAsset(config.name,
        options: config.interpreters[0]);
  }

  void swapToCamera(CameraDescription cameraDescription) async {
    cameraController = CameraController(cameraDescription, ResolutionPreset.low,
        enableAudio: false);
    cameraController.initialize().then((_) async {
      /// previewSize is size of each image frame captured by controller
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
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
      logger.i(_saveClassifierImage);
      var results = await inference(MLIsolateData(
          cameraImage,
          classifier.interpreter.address,
          classifier.labels,
          _saveClassifierImage));

      if (results.containsKey('recognitions')) {
        widget.resultsCallback(results['recognitions']);
      }
      if (results.containsKey('stats')) {
        widget.statsCallback(results['stats']);
      }
      if (results.containsKey('image')) {
        var image = results['image'];
        if (image != null) {
          Directory tempDir = await getTemporaryDirectory();
          String tempPath = tempDir.path;
          logger.i(tempPath);
          logger.i('SAVING IMAGE!');
          await File('$tempPath/${DateTime.now().millisecondsSinceEpoch}.png')
              .writeAsBytes(encodePng(image));
          _saveClassifierImage = false;
        }
      }
      setState(() {
        predicting = false;
      });
    }
  }

  void swapCamera() async {
    logger.i(cameras);
    logger.i(cameraIndex);
    cameraIndex += 1;
    if (cameras.length <= cameraIndex) {
      cameraIndex = 0;
    }
    swapToCamera(cameras[cameraIndex]);
  }

  void saveMLImage() async {
    logger.i('setting save classifier to true');
    _saveClassifierImage = true;
  }

  void setZoom() async {
    logger.i(await cameraController.getMinZoomLevel());
    logger.i(await cameraController.getMaxZoomLevel());
    logger.i(cameraController.setZoomLevel(2.0));
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (!_cameraInitialized) {
      return Container();
    }
    return Column(
      children: [
        AspectRatio(
            aspectRatio: 1 / cameraController.value.aspectRatio,
            child: CameraPreview(cameraController)),
        TextButton(onPressed: swapCamera, child: const Text('Change Camera!')),
        TextButton(
            onPressed: saveMLImage, child: const Text('Save Model Image')),
        TextButton(onPressed: setZoom, child: const Text('Zoom!'))
      ],
    );
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
