import 'package:flutter/material.dart';

class WidgetTestApp extends StatelessWidget {
  final List<Widget> widgets;

  const WidgetTestApp(this.widgets, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Test App',
        theme: ThemeData(
          primarySwatch: Colors.lightBlue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('TEST APP'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: widgets,
            ),
          ),
        ));
  }
}
