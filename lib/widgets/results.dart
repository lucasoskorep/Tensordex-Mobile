import 'package:flutter/material.dart';
import 'package:tensordex_mobile/widgets/poke_finder.dart';
import '../entities/recognition.dart';
import '../entities/stats.dart';

/// [PokeFinder] sends each frame for inference
class Results extends StatefulWidget {
  final List<Recognition> recognitions;
  final Stats stats;

  /// Constructor
  const Results(this.recognitions, this.stats, {Key? key}) : super(key: key);

  @override
  State<Results> createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.recognitions
          .map((recognition) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(recognition.label.toString()),
          Text(recognition.score.toString()),
        ],
      )).toList(),
    );
  }
}
