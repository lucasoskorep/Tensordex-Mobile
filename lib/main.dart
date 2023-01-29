import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:tensordex_mobile/db/poke_storage_service.dart';
import 'package:tensordex_mobile/hive.dart';
import 'package:tensordex_mobile/widgets/tensordex_home.dart';
import 'package:tensordex_mobile/utils/logger.dart';

import 'di.dart';

late List<CameraDescription> cameras;

GetIt getIt = GetIt.instance;

Future<void> main() async {
  await setupHive();
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  setupGetIt();
  getIt<PokeStorageService>().loadDefaultPokes();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    logger.i('Building main app');
    return MaterialApp(
      title: 'Tensordex',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightBlue,
      ),
      home: const TensordexHome(title: 'Tensordex'),
    );
  }
}
