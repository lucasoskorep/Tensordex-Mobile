import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tensordex_mobile/ui/poke_view.dart';

import '../utils/logger.dart';
import '../utils/recognition.dart';
import '../utils/stats.dart';

class TensordexHome extends StatefulWidget {
  const TensordexHome({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TensordexHome> createState() => _TensordexHomeState();
}

class _TensordexHomeState extends State<TensordexHome> {
  int _counter = 0;

  /// Results to draw bounding boxes
  List<Recognition>? results;

  /// Realtime stats
  Stats? stats;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void _incrementCounter() {
    setState(() {
      _counter++;
      logger.d("Counter Incremented!");
      logger.w("Counter Incremented!");
      logger.e("Counter Incremented!");
    });
  }

  // void onNewCameraSelected(CameraDescription cameraDescription) async {
  //   final previousCameraController = controller;
  //   // Instantiating the camera controller
  //   final CameraController cameraController = CameraController(
  //     cameraDescription,
  //     ResolutionPreset.high,
  //     imageFormatGroup: ImageFormatGroup.jpeg,
  //   );
  //
  //   // Dispose the previous controller
  //   await previousCameraController.dispose();
  //
  //   // Replace with the new controller
  //   if (mounted) {
  //     setState(() {
  //       controller = cameraController;
  //     });
  //   }
  //
  //   // Update UI if controller updated
  //   cameraController.addListener(() {
  //     if (mounted) setState(() {});
  //   });
  //
  //   // Initialize controller
  //   try {
  //     await cameraController.initialize();
  //   } on CameraException catch (e) {
  //     logger.e('Error initializing camera:', e);
  //   }
  //
  //   // Update the Boolean
  //   if (mounted) {
  //     setState(() {
  //       _isCameraInitialized = controller.value.isInitialized;
  //     });
  //   }
  // }

  // @override
  // void initState() {
  //   super.initState();
  // WidgetsBinding.instance.addObserver(this);

  // controller = CameraController(_cameras[0], ResolutionPreset.max);
  // controller.initialize().then((_) {
  //   if (!mounted) {
  //     return;
  //   }
  //
  //   setState(() {onNewCameraSelected(_cameras[0]);});
  // }).catchError((Object e) {
  //   if (e is CameraException) {
  //     switch (e.code) {
  //       case 'CameraAccessDenied':
  //         logger.w('User denied camera access.');
  //         controller.initialize().then((_) {
  //           if (!mounted) {
  //             return;
  //           }
  //           setState(() {});
  //         }).catchError((Object e) {
  //           if (e is CameraException) {
  //             switch (e.code) {
  //               case 'CameraAccessDenied':
  //                 logger.i('User denied camera access.');
  //                 break;
  //               default:
  //                 logger.i('Handle other errors.');
  //                 break;
  //             }
  //           }
  //         });
  //         break;
  //       default:
  //         logger.i('Handle other errors.');
  //         break;
  //     }
  //   }
  // });
  // }

  @override
  void dispose() {
    // controller.dispose();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Callback to get inference results from [CameraView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [CameraView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'You have pushed the button this many times:',
              ),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headline4,
              ),
              CameraView(
                  resultsCallback: resultsCallback,
                  statsCallback: statsCallback
              ),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onLongPress: () {
            _incrementCounter();
          },
          child: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.photo_camera),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
