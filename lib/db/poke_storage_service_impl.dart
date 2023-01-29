import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:tensordex_mobile/db/tables/poke_db.dart';
import 'package:tensordex_mobile/db/poke_storage_service.dart';

import 'package:tensordex_mobile/hive.dart';

import '../utils/logger.dart';

/// Implementation of StorageService using Hive Key-Value DB
class PokeStorageServiceImpl implements PokeStorageService {
  PokeStorageServiceImpl();

  @override
  Future savePoke(Poke poke) async {
    final pokeBox = await Hive.openBox(pokeBoxName);
    await pokeBox.put(poke.id, poke);
  }

  @override
  Future<Poke> getPoke(String id) async {
    final pokeBox = await Hive.openBox(pokeBoxName);
    final poke = await pokeBox.get(id);
    return poke;
  }

  @override
  Future addNonExistantPokes(List<Poke> pokes) async {
    final pokeBox = await Hive.openBox(pokeBoxName);

    Future.forEach(pokes, (Poke poke) async {
      if (!pokeBox.containsKey(poke.id)) {
        await pokeBox.put(poke.id, poke);
      }
    });
  }

  @override
  Future<void> loadDefaultPokes() async {
    var allPokeJson = await _loadPokeJson();
    List<Poke> pokes = [];
    for (var pokeJson in allPokeJson) {
      pokes.add(Poke(
          id: pokeJson['id'].toString(),
          name: pokeJson['name']['english'].toString(),
          seen: false,
          images: []));
    }
    await addNonExistantPokes(pokes);
  }

  Future<List<dynamic>> _loadPokeJson() async {
    return await jsonDecode(await rootBundle.loadString('assets/pokemon.json'));
  }

  @override
  void stop() {
    Hive.close();
  }
}
