import 'package:hive/hive.dart';

part 'poke_db.g.dart';

@HiveType(typeId: 1)
class Poke {
  Poke(
      {required this.id,
      required this.name,
      required this.seen,
      required this.images});

  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  bool seen;

  @HiveField(3)
  List<String> images;

  @override
  String toString() {
    return '$id: $name | seen?:$seen | images: $images';
  }
}
