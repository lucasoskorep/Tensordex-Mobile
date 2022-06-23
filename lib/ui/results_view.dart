import 'package:flutter/material.dart';
import 'package:tensordex_mobile/ui/poke_view.dart';
import 'package:tensordex_mobile/tflite/data/recognition.dart';
import 'package:tensordex_mobile/tflite/data/stats.dart';


/// [PokedexView] sends each frame for inference
class ResultsView extends StatefulWidget {
  final List<Recognition> recognitions;
  final Stats stats;
  /// Constructor
  const ResultsView(this.recognitions, this.stats, {Key? key}) : super(key: key);

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.recognitions.toString());
  }
}
