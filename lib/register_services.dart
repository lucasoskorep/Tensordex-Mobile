import 'package:get_it/get_it.dart';
import 'package:tensordex_mobile/services/classifier/classifier.dart';

GetIt getIt = GetIt.instance;

void getServices() {
  getIt.registerLazySingleton(() => Classifier());
}