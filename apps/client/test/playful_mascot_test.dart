import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_feedback_app/results/playful_mascot.dart';
import 'package:privacy_feedback_app/results/playful_result.dart';

void main() {
  testWidgets('every playful character has a local mascot', (tester) async {
    for (final character in PlayfulCharacter.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PlayfulMascot(
                key: ValueKey(character),
                character: character,
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(ValueKey(character)), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });
}
