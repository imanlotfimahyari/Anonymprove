import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_feedback_app/api/api_client.dart';
import 'package:privacy_feedback_app/main.dart';

void main() {
  testWidgets('renders the private session entry screen', (tester) async {
    await tester.pumpWidget(
      FeedbackApp(api: HttpAnonymproveApi(baseUrl: 'http://example.invalid')),
    );

    expect(find.text('Private Feedback'), findsOneWidget);
    expect(
      find.text('Constructive feedback, without exposing who said what.'),
      findsOneWidget,
    );
    expect(find.text('Start private session'), findsOneWidget);
  });
}
