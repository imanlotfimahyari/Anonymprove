import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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

  testWidgets('create group text dialog dismisses cleanly after submission', (
    tester,
  ) async {
    var groupCreated = false;

    final groupJson = <String, dynamic>{
      'id': 'group-1',
      'name': 'Regression group',
      'role': 'owner',
      'createdAt': '2026-09-09T20:00:00Z',
      'joinCode': 'test-join-code',
    };

    final client = MockClient((request) async {
      if (request.method == 'POST' &&
          request.url.path == '/api/v1/users/session') {
        return _jsonResponse({
          'sessionToken': 'session-token',
          'userId': 'user-1',
          'alias': 'Test user',
        });
      }

      if (request.method == 'GET' && request.url.path == '/api/v1/groups') {
        return _jsonResponse(groupCreated ? [groupJson] : []);
      }

      if (request.method == 'POST' && request.url.path == '/api/v1/groups') {
        expect(jsonDecode(request.body), {'name': 'Regression group'});
        groupCreated = true;
        return _jsonResponse(groupJson);
      }

      throw StateError('Unexpected request: ${request.method} ${request.url}');
    });

    await tester.pumpWidget(
      FeedbackApp(
        api: HttpAnonymproveApi(
          baseUrl: 'http://example.invalid',
          client: client,
        ),
      ),
    );

    await tester.tap(find.text('Start private session'));
    await tester.pumpAndSettle();

    expect(find.text('My groups'), findsOneWidget);

    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    expect(find.text('Create group'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Regression group');

    await tester.tap(find.widgetWithText(FilledButton, 'Create'));
    await tester.pumpAndSettle();

    expect(find.text('Save this join code'), findsOneWidget);
    expect(find.text('Copy code'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('I saved it'));
    await tester.pumpAndSettle();

    expect(find.text('Regression group'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

http.Response _jsonResponse(Object body) {
  return http.Response(
    jsonEncode(body),
    200,
    headers: {'content-type': 'application/json'},
  );
}
