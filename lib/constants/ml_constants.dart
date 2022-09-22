import 'package:tflite_flutter/tflite_flutter.dart';


class ModelConstants {
  static final InterpreterOptions _npuConfig = InterpreterOptions()..threads = 8..useNnApiForAndroid = true..useMetalDelegateForIOS = true;
  static final InterpreterOptions _cpuConfig = InterpreterOptions()..threads = 8;
  static final List<InterpreterOptions> gpuInterpreterList = [_npuConfig, _cpuConfig];
  static final List<InterpreterOptions> cpuInterpreterList = [_cpuConfig];
}

