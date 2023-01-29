import 'package:get_it/get_it.dart';
import 'package:tensordex_mobile/db/poke_storage_service.dart';
import 'package:tensordex_mobile/db/poke_storage_service_impl.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<PokeStorageService>(PokeStorageServiceImpl());
}
