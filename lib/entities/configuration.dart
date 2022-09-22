import 'package:tflite_flutter/tflite_flutter.dart';
import '../constants/ml_constants.dart';

class ModelConfiguration{
  String name;
  late List<InterpreterOptions> interpreters;

  ModelConfiguration(this.name){
    interpreters = name.contains('gpu') ? ModelConstants.gpuInterpreterList : ModelConstants.cpuInterpreterList;
  }

  @override
  String toString() {
    return 'ModelConfiguration(name: $name, interpreters: $interpreters)';
  }
}