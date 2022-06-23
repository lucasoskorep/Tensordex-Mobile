import 'package:flutter/material.dart';
import 'package:tensordex_mobile/widgets/poke_finder.dart';
import 'package:tensordex_mobile/tflite/data/recognition.dart';
import 'package:tensordex_mobile/tflite/data/stats.dart';


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
    return Text(widget.recognitions.toString());
  }
}
