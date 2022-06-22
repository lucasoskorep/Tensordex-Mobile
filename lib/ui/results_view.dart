import 'package:flutter/material.dart';
import 'package:tensordex_mobile/ui/poke_view.dart';
import 'package:tensordex_mobile/utils/recognition.dart';

import '../utils/logger.dart';

/// [CameraView] sends each frame for inference
class ResultsView extends StatefulWidget {

  /// Constructor
  const ResultsView({Key? key}) : super(key: key);


  void setResults(Recognition results){
    logger.i("RESULTS IN THE RESULT VIEW");
  }

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
    return Text("data");
  }
}