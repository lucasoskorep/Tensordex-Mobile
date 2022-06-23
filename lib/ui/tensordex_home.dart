import 'package:flutter/material.dart';
import 'package:tensordex_mobile/ui/poke_view.dart';
import 'package:tensordex_mobile/ui/results_view.dart';

import '../utils/logger.dart';
import '../tflite/data/recognition.dart';
import '../tflite/data/stats.dart';

class TensordexHome extends StatefulWidget {
  const TensordexHome({Key? key, required this.title}) : super(key: key);

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<TensordexHome> createState() => _TensordexHomeState();
}

class _TensordexHomeState extends State<TensordexHome> {
  /// Results from the image classifier
  List<Recognition> results = [Recognition(1, "NOTHING DETECTED", .5)];
  Stats stats = Stats();

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void _incrementCounter() {
    setState(() {
      logger.d("Counter Incremented!");
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Callback to get inference results from [PokedexView]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [PokedexView]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              PokedexView(
                  resultsCallback: resultsCallback,
                  statsCallback: statsCallback),
              ResultsView(results, stats),
            ],
          ),
        ),
        floatingActionButton: GestureDetector(
          onLongPress: () {
            _incrementCounter();
          },
          child: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.photo_camera),
          ), // This trailing comma makes auto-formatting nicer for build methods.
        ));
  }
}
