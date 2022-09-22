import 'package:collection/collection.dart';

List<MapEntry<String, double>> getTopProbabilities(
    Map<String, double> labeledProb,
    {int number = 3}) {
  var pq = PriorityQueue<MapEntry<String, double>>(compare);
  pq.addAll(labeledProb.entries);
  return [for (var i = 0; i < number; i += 1) pq.removeFirst()];
}

int compare(MapEntry<String, double> e1, MapEntry<String, double> e2) {
  if (e1.value > e2.value) {
    return -1;
  } else if (e1.value == e2.value) {
    return 0;
  } else {
    return 1;
  }
}
