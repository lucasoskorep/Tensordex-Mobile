import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tensordex_mobile/tflite/classifier.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tensordex_mobile/utils/image_utils.dart';

import '../utils/logger.dart';
import '../utils/recognition.dart';
import '../utils/stats.dart';

/// [CameraView] sends each frame for inference
class CameraView extends StatefulWidget {
  /// Callback to pass results after inference to [HomeView]
  final Function(List<Recognition> recognitions) resultsCallback;

  /// Callback to inference stats to [HomeView]
  final Function(Stats stats) statsCallback;

  /// Constructor
  const CameraView(
      {Key? key, required this.resultsCallback, required this.statsCallback})
      : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  /// List of available cameras
  late List<CameraDescription> cameras;

  /// Controller
  late CameraController cameraController;
  Interpreter? interp;

  /// true when inference is ongoing
  bool predicting = false;

  late Classifier classy;

  // /// Instance of [Classifier]
  // Classifier classifier;
  //
  // /// Instance of [IsolateUtils]
  // IsolateUtils isolateUtils;

  @override
  void initState() {
    initStateAsync();
    super.initState();
  }

  void initStateAsync() async {
    WidgetsBinding.instance.addObserver(this);

    // Spawn a new isolate
    // isolateUtils = IsolateUtils();
    // await isolateUtils.start();

    // Camera initialization
    initializeCamera();

    // final gpuDelegateV2 = GpuDelegateV2(
    //     options: GpuDelegateOptionsV2(
    //       isPrecisionLossAllowed: false,
    //       inferencePreference: TfLiteGpuInferenceUsage.fastSingleAnswer,
    //       inferencePriority1: TfLiteGpuInferencePriority.minLatency,
    //       inferencePriority2: TfLiteGpuInferencePriority.auto,
    //       inferencePriority3: TfLiteGpuInferencePriority.auto,
    //     ));


    logger.e("CREATING THE INTERPRETOR");
    var interpreterOptions = InterpreterOptions();//..addDelegate(gpuDelegateV2);
    interp = await Interpreter.fromAsset('efficientnet_v2s.tflite',
        options: interpreterOptions);
    logger.e("CREATING THE INTERPRETOR");

    classy = Classifier(interpreter: interp);
    logger.i(interp?.getOutputTensors());
    // Create an instance of classifier to load model and labels
    // classifier = Classifier();


    // Initially predicting = false
    predicting = false;
  }

  /// Initializes the camera by setting [cameraController]
  void initializeCamera() async {
    cameras = await availableCameras();

    // cameras[0] for rear-camera
    cameraController =
        CameraController(cameras[0], ResolutionPreset.low, enableAudio: false);

    cameraController.initialize().then((_) async {
      // Stream of image passed to [onLatestImageAvailable] callback
      await cameraController.startImageStream(onLatestImageAvailable);

      /// previewSize is size of each image frame captured by controller
      ///
      /// 352x288 on iOS, 240p (320x240) on Android with ResolutionPreset.low
      // Size previewSize = cameraController.value.previewSize;
      //
      // /// previewSize is size of raw input image to the model
      // CameraViewSingleton.inputImageSize = previewSize;
      //
      // // the display width of image on screen is
      // // same as screenWidth while maintaining the aspectRatio
      // Size screenSize = MediaQuery.of(context).size;
      // CameraViewSingleton.screenSize = screenSize;
      // CameraViewSingleton.ratio = screenSize.width / previewSize.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container while the camera is not initialized
    if (!cameraController.value.isInitialized) {
      return Container();
    }

    return AspectRatio(
        aspectRatio: 1/cameraController.value.aspectRatio,
        child: CameraPreview(cameraController));
  }

  /// Callback to receive each frame [CameraImage] perform inference on it
  onLatestImageAvailable(CameraImage cameraImage) async {
    // if (classifier.interpreter != null && classifier.labels != null) {
    //   // If previous inference has not completed then return
    if (predicting) {
      return;
    }
    setState(() {
      predicting = true;
    });
    logger.i("RECIEVED IMAGE");
    logger.i(cameraImage.format.group);
    logger.i(cameraImage);
    var converted = ImageUtils.convertCameraImage(cameraImage);
    if (converted != null){

      var result = classy.predict(converted);

      logger.e("PREDICTED IMAGE");
      logger.i(result);
    }
    // logger.i(cameraImage);
    // logger.i(cameraImage.height);
    // logger.i(cameraImage.width);
    // logger.i(cameraImage.planes[0]);
    //
    //   var uiThreadTimeStart = DateTime.now().millisecondsSinceEpoch;
    //
    //   // Data to be passed to inference isolate
    //   var isolateData = IsolateData(
    //       cameraImage, classifier.interpreter.address, classifier.labels);
    //
    //   // We could have simply used the compute method as well however
    //   // it would be as in-efficient as we need to continuously passing data
    //   // to another isolate.
    //
    //   /// perform inference in separate isolate
    //   Map<String, dynamic> inferenceResults = await inference(isolateData);
    //
    //   var uiThreadInferenceElapsedTime =
    //       DateTime.now().millisecondsSinceEpoch - uiThreadTimeStart;
    //
    //   // pass results to HomeView
    //   widget.resultsCallback(inferenceResults["recognitions"]);
    //
    //   // pass stats to HomeView
    //   widget.statsCallback((inferenceResults["stats"] as Stats)
    //     ..totalElapsedTime = uiThreadInferenceElapsedTime);

    // set predicting to false to allow new frames
    setState(() {
      predicting = false;
    });
  }

// /// Runs inference in another isolate
// Future<Map<String, dynamic>> inference(IsolateData isolateData) async {
//   ReceivePort responsePort = ReceivePort();
//   isolateUtils.sendPort
//       .send(isolateData..responsePort = responsePort.sendPort);
//   var results = await responsePort.first;
//   return results;
// }

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
