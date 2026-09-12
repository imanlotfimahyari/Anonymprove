import 'dart:convert';

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

  test('custom questionnaire round uses questionnaireId selector', () async {
    late http.Request captured;

    final client = MockClient((request) async {
      captured = request;

      return http.Response(
        jsonEncode({
          'id': 'r',
          'groupId': 'g',
          'subjectUserId': 'u',
          'createdByUserId': 'u',
          'questionnaireId': 'q',
          'questionnaireSlug': 'custom',
          'roundType': 'individual_feedback',
          'status': 'draft',
          'minResponses': 3,
          'createdAt': '2026-09-07T00:00:00Z',
          'openedAt': null,
          'closedAt': null,
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = HttpAnonymproveApi(
      baseUrl: 'http://127.0.0.1:8000',
      client: client,
    );

    await api.createFeedbackRound('session-token', 'g', questionnaireId: 'q');

    final body = jsonDecode(captured.body) as Map<String, dynamic>;

    expect(body['questionnaireId'], 'q');
    expect(body.containsKey('questionnaireSlug'), isFalse);
    expect(body['roundType'], 'individual_feedback');
  });

  test('parses group-health round with nullable subject', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/groups/group-1/feedback-rounds');

      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['roundType'], 'group_health');
      expect(body['minResponses'], 3);
      expect(body.containsKey('questionnaireId'), isFalse);
      expect(body.containsKey('questionnaireSlug'), isFalse);

      return http.Response(
        jsonEncode({
          'id': 'round-1',
          'groupId': 'group-1',
          'subjectUserId': null,
          'createdByUserId': 'user-1',
          'questionnaireId': 'questionnaire-1',
          'questionnaireSlug': 'core-group-health-v1',
          'roundType': 'group_health',
          'status': 'draft',
          'minResponses': 3,
          'createdAt': '2026-09-10T20:00:00Z',
          'openedAt': null,
          'closedAt': null,
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = HttpAnonymproveApi(
      baseUrl: 'http://example.invalid',
      client: client,
    );

    final round = await api.createFeedbackRound(
      'session-token',
      'group-1',
      roundType: 'group_health',
    );

    expect(round.roundType, 'group_health');
    expect(round.isGroupHealth, isTrue);
    expect(round.isIndividualFeedback, isFalse);
    expect(round.subjectUserId, isNull);
    expect(round.createdByUserId, 'user-1');
    expect(round.questionnaireSlug, 'core-group-health-v1');
  });

  test(
    'FastAPI validation errors are shown as readable field messages',
    () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {
                'type': 'string_too_short',
                'loc': ['body', 'name'],
                'msg': 'String should have at least 2 characters',
                'input': '',
              },
            ],
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final api = HttpAnonymproveApi(
        baseUrl: 'http://example.invalid',
        client: client,
      );

      await expectLater(
        api.createGroup('session-token', ''),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Name: String should have at least 2 characters',
          ),
        ),
      );
    },
  );

  test('personal feedback remains the default round type', () async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['roundType'], 'individual_feedback');

      return http.Response(
        jsonEncode({
          'id': 'round-2',
          'groupId': 'group-1',
          'subjectUserId': 'user-1',
          'createdByUserId': 'user-1',
          'questionnaireId': 'questionnaire-2',
          'questionnaireSlug': 'core-feedback-v1',
          'roundType': 'individual_feedback',
          'status': 'draft',
          'minResponses': 3,
          'createdAt': '2026-09-10T20:00:00Z',
          'openedAt': null,
          'closedAt': null,
        }),
        201,
        headers: {'content-type': 'application/json'},
      );
    });

    final api = HttpAnonymproveApi(
      baseUrl: 'http://example.invalid',
      client: client,
    );

    final round = await api.createFeedbackRound('session-token', 'group-1');

    expect(round.isIndividualFeedback, isTrue);
    expect(round.isGroupHealth, isFalse);
    expect(round.subjectUserId, 'user-1');
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
