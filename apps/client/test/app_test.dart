import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_feedback_app/main.dart';

void main() {
  testWidgets('renders the foundation screen', (tester) async {
    await tester.pumpWidget(const FeedbackApp());

    expect(find.text('Private Feedback'), findsOneWidget);
    expect(
      find.text('Constructive feedback, without exposing who said what.'),
      findsOneWidget,
    );
  });
}
