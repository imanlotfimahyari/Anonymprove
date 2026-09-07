import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:privacy_feedback_app/api/api_client.dart';
import 'package:privacy_feedback_app/models/models.dart';

void main() {
  test('anonymous submission omits the bearer identity', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{"status":"accepted"}', 201);
    });
    final api = HttpAnonymproveApi(
      baseUrl: 'http://127.0.0.1:8000',
      client: client,
    );

    await api.submitFeedback('round-id', 'response-token-value', const [
      AnswerSubmission(questionId: 'question-id', score: 4),
    ]);

    expect(_header(captured, 'X-Response-Token'), 'response-token-value');
    expect(_header(captured, 'Authorization'), isNull);
  });

  test('credential claim uses the bearer identity', () async {
    late http.Request captured;
    final client = MockClient((request) async {
      captured = request;
      return http.Response('{"responseToken":"issued-token"}', 201);
    });
    final api = HttpAnonymproveApi(
      baseUrl: 'http://127.0.0.1:8000',
      client: client,
    );

    final token = await api.claimResponseCredential(
      'session-token',
      'round-id',
    );

    expect(token, 'issued-token');
    expect(_header(captured, 'Authorization'), 'Bearer session-token');
    expect(_header(captured, 'X-Response-Token'), isNull);
  });
}

String? _header(http.Request request, String name) {
  final target = name.toLowerCase();
  for (final entry in request.headers.entries) {
    if (entry.key.toLowerCase() == target) {
      return entry.value;
    }
  }
  return null;
}
