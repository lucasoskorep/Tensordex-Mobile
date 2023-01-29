import 'dart:io';

import 'package:hive_flutter/adapters.dart';

import 'db/tables/poke_db.dart';

const pokeBoxName = 'pokes';

Future setupHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PokeAdapter());
  await Hive.openBox(pokeBoxName);
}
