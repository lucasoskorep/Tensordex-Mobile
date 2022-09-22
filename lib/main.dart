import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tensordex_mobile/widgets/tensordex_home.dart';
import 'package:tensordex_mobile/utils/logger.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    logger.i('Building main app');
    return MaterialApp(
      title: 'Tensordex',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const TensordexHome(title: 'Tensordex'),
    );
  }
}
