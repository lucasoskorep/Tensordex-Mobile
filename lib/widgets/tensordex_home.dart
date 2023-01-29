import 'package:flutter/material.dart';
import 'package:tensordex_mobile/tflite/model/outputs/recognition.dart';
import 'package:tensordex_mobile/tflite/model/outputs/stats.dart';
import 'package:tensordex_mobile/widgets/poke_finder.dart';
import 'package:tensordex_mobile/widgets/results.dart';

import '../utils/logger.dart';

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
  List<Recognition> results = [Recognition(1, 'NOTHING DETECTED', .5)];
  Stats stats = Stats();
  int _selectedNavBarIndex = 0;

  /// Scaffold Key
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  void _incrementCounter() {
    setState(() {
      logger.d('Counter Incremented!');
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

  /// Callback to get inference results from [PokeFinder]
  void resultsCallback(List<Recognition> results) {
    setState(() {
      this.results = results;
    });
  }

  /// Callback to get inference stats from [PokeFinder]
  void statsCallback(Stats stats) {
    setState(() {
      this.stats = stats;
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedNavBarIndex = index;
    });
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PokeFinder(
              resultsCallback: resultsCallback, statsCallback: statsCallback),
          // Results(results, stats),
        ],
      ),
      const Text(
        'Index 1: Seen',
        style: optionStyle,
      ),
      const Text(
        'Index 2: About',
        style: optionStyle,
      ),
      const Text(
        'Index 3: Settings',
        style: optionStyle,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedNavBarIndex),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.lightBlue,
        type: BottomNavigationBarType.shifting,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Camera',
            backgroundColor: Colors.lightBlue,
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Calls',
              backgroundColor: Colors.deepOrange),
          BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
              backgroundColor: Colors.red),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.purple,
          ),
        ],
        currentIndex: _selectedNavBarIndex,
        selectedItemColor: Colors.amber,
        onTap: _onNavBarTapped,
      ),
    );
  }
}
