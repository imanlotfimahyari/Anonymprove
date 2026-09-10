import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

abstract class AnonymproveApi {
  Future<SessionInfo> createSession();
  Future<List<GroupSummary>> listGroups(String sessionToken);
  Future<GroupSummary> createGroup(String sessionToken, String name);
  Future<GroupSummary> joinGroup(String sessionToken, String joinCode);
  Future<List<QuestionnaireSummary>> listQuestionnaires(
    String sessionToken,
    String groupId,
  );
  Future<QuestionnaireSummary> createQuestionnaire(
    String sessionToken,
    String groupId,
    QuestionnaireUpsertInput input,
  );
  Future<QuestionnaireSummary> updateQuestionnaire(
    String sessionToken,
    String groupId,
    String questionnaireId,
    QuestionnaireUpsertInput input,
  );
  Future<QuestionnaireSummary> publishQuestionnaire(
    String sessionToken,
    String groupId,
    String questionnaireId,
  );
  Future<QuestionnaireSummary> createQuestionnaireVersion(
    String sessionToken,
    String groupId,
    String questionnaireId,
  );
  Future<List<FeedbackRoundSummary>> listFeedbackRounds(
    String sessionToken,
    String groupId,
  );
  Future<FeedbackRoundSummary> createFeedbackRound(
    String sessionToken,
    String groupId, {
    String? questionnaireId,
    String roundType = 'individual_feedback',
  });
  Future<FeedbackRoundDetail> getFeedbackRound(
    String sessionToken,
    String roundId,
  );
  Future<FeedbackRoundSummary> openFeedbackRound(
    String sessionToken,
    String roundId,
  );
  Future<FeedbackRoundSummary> closeFeedbackRound(
    String sessionToken,
    String roundId,
  );
  Future<String> claimResponseCredential(String sessionToken, String roundId);
  Future<void> submitFeedback(
    String roundId,
    String responseToken,
    List<AnswerSubmission> answers,
  );
  Future<FeedbackResults> getFeedbackResults(
    String sessionToken,
    String roundId,
  );
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;
  @override
  String toString() => message;
}

class HttpAnonymproveApi implements AnonymproveApi {
  HttpAnonymproveApi({required String baseUrl, http.Client? client})
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), ''),
      _client = client ?? http.Client();

  final String _baseUrl;
  final http.Client _client;

  @override
  Future<SessionInfo> createSession() async {
    final json = await _request('POST', '/api/v1/users/session');
    return SessionInfo.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<GroupSummary>> listGroups(String sessionToken) async {
    final json = await _request(
      'GET',
      '/api/v1/groups',
      sessionToken: sessionToken,
    );
    return (json as List<dynamic>)
        .map((item) => GroupSummary.fromJson(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<GroupSummary> createGroup(String sessionToken, String name) async {
    final json = await _request(
      'POST',
      '/api/v1/groups',
      sessionToken: sessionToken,
      body: {'name': name},
    );
    return GroupSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<GroupSummary> joinGroup(String sessionToken, String joinCode) async {
    final json = await _request(
      'POST',
      '/api/v1/groups/join',
      sessionToken: sessionToken,
      body: {'joinCode': joinCode},
    );
    return GroupSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<QuestionnaireSummary>> listQuestionnaires(
    String sessionToken,
    String groupId,
  ) async {
    final json = await _request(
      'GET',
      '/api/v1/groups/$groupId/questionnaires',
      sessionToken: sessionToken,
    );
    return (json as List<dynamic>)
        .map(
          (item) => QuestionnaireSummary.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<QuestionnaireSummary> createQuestionnaire(
    String sessionToken,
    String groupId,
    QuestionnaireUpsertInput input,
  ) async {
    final json = await _request(
      'POST',
      '/api/v1/groups/$groupId/questionnaires',
      sessionToken: sessionToken,
      body: input.toJson(),
    );
    return QuestionnaireSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<QuestionnaireSummary> updateQuestionnaire(
    String sessionToken,
    String groupId,
    String questionnaireId,
    QuestionnaireUpsertInput input,
  ) async {
    final json = await _request(
      'PUT',
      '/api/v1/groups/$groupId/questionnaires/$questionnaireId',
      sessionToken: sessionToken,
      body: input.toJson(),
    );
    return QuestionnaireSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<QuestionnaireSummary> publishQuestionnaire(
    String sessionToken,
    String groupId,
    String questionnaireId,
  ) async {
    final json = await _request(
      'POST',
      '/api/v1/groups/$groupId/questionnaires/$questionnaireId/publish',
      sessionToken: sessionToken,
    );
    return QuestionnaireSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<QuestionnaireSummary> createQuestionnaireVersion(
    String sessionToken,
    String groupId,
    String questionnaireId,
  ) async {
    final json = await _request(
      'POST',
      '/api/v1/groups/$groupId/questionnaires/$questionnaireId/versions',
      sessionToken: sessionToken,
    );
    return QuestionnaireSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<List<FeedbackRoundSummary>> listFeedbackRounds(
    String sessionToken,
    String groupId,
  ) async {
    final json = await _request(
      'GET',
      '/api/v1/groups/$groupId/feedback-rounds',
      sessionToken: sessionToken,
    );
    return (json as List<dynamic>)
        .map(
          (item) => FeedbackRoundSummary.fromJson(item as Map<String, dynamic>),
        )
        .toList(growable: false);
  }

  @override
  Future<FeedbackRoundSummary> createFeedbackRound(
    String sessionToken,
    String groupId, {
    String? questionnaireId,
    String roundType = 'individual_feedback',
  }) async {
    final body = <String, dynamic>{'roundType': roundType, 'minResponses': 3};

    if (questionnaireId != null) {
      body['questionnaireId'] = questionnaireId;
    }

    final json = await _request(
      'POST',
      '/api/v1/groups/$groupId/feedback-rounds',
      sessionToken: sessionToken,
      body: body,
    );

    return FeedbackRoundSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<FeedbackRoundDetail> getFeedbackRound(
    String sessionToken,
    String roundId,
  ) async {
    final json = await _request(
      'GET',
      '/api/v1/feedback-rounds/$roundId',
      sessionToken: sessionToken,
    );
    return FeedbackRoundDetail.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<FeedbackRoundSummary> openFeedbackRound(
    String sessionToken,
    String roundId,
  ) async {
    final json = await _request(
      'POST',
      '/api/v1/feedback-rounds/$roundId/open',
      sessionToken: sessionToken,
    );
    return FeedbackRoundSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<FeedbackRoundSummary> closeFeedbackRound(
    String sessionToken,
    String roundId,
  ) async {
    final json = await _request(
      'POST',
      '/api/v1/feedback-rounds/$roundId/close',
      sessionToken: sessionToken,
    );
    return FeedbackRoundSummary.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<String> claimResponseCredential(
    String sessionToken,
    String roundId,
  ) async {
    final json = await _request(
      'POST',
      '/api/v1/feedback-rounds/$roundId/credentials',
      sessionToken: sessionToken,
    );
    return (json as Map<String, dynamic>)['responseToken'] as String;
  }

  @override
  Future<void> submitFeedback(
    String roundId,
    String responseToken,
    List<AnswerSubmission> answers,
  ) async {
    await _request(
      'POST',
      '/api/v1/feedback-rounds/$roundId/responses',
      responseToken: responseToken,
      body: {'answers': answers.map((answer) => answer.toJson()).toList()},
    );
  }

  @override
  Future<FeedbackResults> getFeedbackResults(
    String sessionToken,
    String roundId,
  ) async {
    final json = await _request(
      'GET',
      '/api/v1/feedback-rounds/$roundId/results',
      sessionToken: sessionToken,
    );
    return FeedbackResults.fromJson(json as Map<String, dynamic>);
  }

  Future<dynamic> _request(
    String method,
    String path, {
    String? sessionToken,
    String? responseToken,
    Map<String, dynamic>? body,
  }) async {
    final headers = <String, String>{
      if (body != null) 'Content-Type': 'application/json',
      if (sessionToken != null) 'Authorization': 'Bearer $sessionToken',
      'X-Response-Token': ?responseToken,
    };
    final uri = Uri.parse('$_baseUrl$path');
    final encodedBody = body == null ? null : jsonEncode(body);
    late final http.Response response;
    if (method == 'GET') {
      response = await _client.get(uri, headers: headers);
    } else if (method == 'POST') {
      response = await _client.post(uri, headers: headers, body: encodedBody);
    } else if (method == 'PUT') {
      response = await _client.put(uri, headers: headers, body: encodedBody);
    } else {
      throw ArgumentError.value(method, 'method', 'Unsupported HTTP method');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        _errorMessage(response),
        statusCode: response.statusCode,
      );
    }
    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['detail'] is String) {
        return decoded['detail'] as String;
      }
    } on FormatException {
      // Fall through.
    }
    return 'Request failed (${response.statusCode})';
  }
}
