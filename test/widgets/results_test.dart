// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tensordex_mobile/tflite/model/outputs/recognition.dart';
import 'package:tensordex_mobile/tflite/model/outputs/stats.dart';
import 'package:tensordex_mobile/widgets/results.dart';

import '../widget_test_app.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    List<Recognition> recognitions = [
      Recognition(1, 'Pikachu', 0.9),
      Recognition(1, 'Raichu', 0.09),
      Recognition(1, 'Pichu', 0.01),
    ];

    Stats stat = Stats(
      totalTime: 150,
      preProcessingTime: 75,
      inferenceTime: 50,
      postProcessingTime: 25,
    );
    Results results = Results(recognitions, stat);
    // Build our app and trigger a frame.
    List<Widget> widgets = [results];
    await tester.pumpWidget(WidgetTestApp(widgets));

    // Verify that all of hte rcognitions can be found on the recognition widget
    expect(find.text('Pikachu'), findsOneWidget);
    expect(find.text('Raichu'), findsOneWidget);
    expect(find.text('Pichu'), findsOneWidget);
    expect(find.text('0.9'), findsOneWidget);
    expect(find.text('0.09'), findsOneWidget);

  });
}
