import 'package:tensordex_mobile/db/tables/poke_db.dart';

abstract class PokeStorageService {

  Future<void> savePoke(Poke user);

  Future<Poke> getPoke(String pokeId);

  void addNonExistantPokes(List<Poke> pokes);

  void loadDefaultPokes();

  void stop();
}