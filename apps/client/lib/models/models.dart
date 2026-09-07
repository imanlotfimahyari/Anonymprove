class SessionInfo {
  const SessionInfo({
    required this.sessionToken,
    required this.userId,
    required this.alias,
  });

  final String sessionToken;
  final String userId;
  final String alias;

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      sessionToken: json['sessionToken'] as String,
      userId: json['userId'] as String,
      alias: json['alias'] as String,
    );
  }
}

class GroupSummary {
  const GroupSummary({
    required this.id,
    required this.name,
    required this.role,
    required this.createdAt,
    this.joinCode,
  });

  final String id;
  final String name;
  final String role;
  final DateTime createdAt;
  final String? joinCode;

  factory GroupSummary.fromJson(Map<String, dynamic> json) {
    return GroupSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      joinCode: json['joinCode'] as String?,
    );
  }
}

class QuestionOptionSummary {
  const QuestionOptionSummary({
    required this.id,
    required this.label,
    required this.position,
  });

  final String id;
  final String label;
  final int position;

  factory QuestionOptionSummary.fromJson(Map<String, dynamic> json) {
    return QuestionOptionSummary(
      id: json['id'] as String,
      label: json['label'] as String,
      position: json['position'] as int,
    );
  }
}

class QuestionSummary {
  const QuestionSummary({
    required this.id,
    required this.key,
    required this.prompt,
    required this.kind,
    required this.position,
    required this.required,
    required this.options,
    this.minScore,
    this.maxScore,
  });

  final String id;
  final String key;
  final String prompt;
  final String kind;
  final int position;
  final bool required;
  final int? minScore;
  final int? maxScore;
  final List<QuestionOptionSummary> options;

  factory QuestionSummary.fromJson(Map<String, dynamic> json) {
    return QuestionSummary(
      id: json['id'] as String,
      key: json['key'] as String,
      prompt: json['prompt'] as String,
      kind: json['kind'] as String,
      position: json['position'] as int,
      required: json['required'] as bool,
      minScore: json['minScore'] as int?,
      maxScore: json['maxScore'] as int?,
      options: (json['options'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                QuestionOptionSummary.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

class QuestionnaireSummary {
  const QuestionnaireSummary({
    required this.id,
    required this.slug,
    required this.name,
    required this.version,
    required this.status,
    required this.questions,
    this.groupId,
    this.createdByUserId,
    this.description,
  });

  final String id;
  final String? groupId;
  final String? createdByUserId;
  final String slug;
  final String name;
  final String? description;
  final int version;
  final String status;
  final List<QuestionSummary> questions;

  bool get isBuiltIn => groupId == null;

  factory QuestionnaireSummary.fromJson(Map<String, dynamic> json) {
    return QuestionnaireSummary(
      id: json['id'] as String,
      groupId: json['groupId'] as String?,
      createdByUserId: json['createdByUserId'] as String?,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      version: json['version'] as int,
      status: json['status'] as String,
      questions: (json['questions'] as List<dynamic>)
          .map((item) => QuestionSummary.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class QuestionnaireQuestionInput {
  const QuestionnaireQuestionInput({
    required this.prompt,
    required this.kind,
    required this.required,
    this.minScore,
    this.maxScore,
    this.options = const [],
  });

  final String prompt;
  final String kind;
  final bool required;
  final int? minScore;
  final int? maxScore;
  final List<String> options;

  Map<String, dynamic> toJson() => {
    'prompt': prompt,
    'kind': kind,
    'required': required,
    if (minScore != null) 'minScore': minScore,
    if (maxScore != null) 'maxScore': maxScore,
    if (options.isNotEmpty) 'options': options,
  };
}

class QuestionnaireUpsertInput {
  const QuestionnaireUpsertInput({
    required this.name,
    required this.questions,
    this.description,
  });

  final String name;
  final String? description;
  final List<QuestionnaireQuestionInput> questions;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
    'questions': questions.map((question) => question.toJson()).toList(),
  };
}

class FeedbackRoundSummary {
  const FeedbackRoundSummary({
    required this.id,
    required this.groupId,
    required this.subjectUserId,
    required this.questionnaireId,
    required this.questionnaireSlug,
    required this.status,
    required this.minResponses,
    required this.createdAt,
    this.openedAt,
    this.closedAt,
  });

  final String id;
  final String groupId;
  final String subjectUserId;
  final String questionnaireId;
  final String questionnaireSlug;
  final String status;
  final int minResponses;
  final DateTime createdAt;
  final DateTime? openedAt;
  final DateTime? closedAt;

  factory FeedbackRoundSummary.fromJson(Map<String, dynamic> json) {
    return FeedbackRoundSummary(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      subjectUserId: json['subjectUserId'] as String,
      questionnaireId: json['questionnaireId'] as String,
      questionnaireSlug: json['questionnaireSlug'] as String,
      status: json['status'] as String,
      minResponses: json['minResponses'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      openedAt: _parseOptionalDate(json['openedAt']),
      closedAt: _parseOptionalDate(json['closedAt']),
    );
  }
}

class FeedbackRoundDetail extends FeedbackRoundSummary {
  const FeedbackRoundDetail({
    required super.id,
    required super.groupId,
    required super.subjectUserId,
    required super.questionnaireId,
    required super.questionnaireSlug,
    required super.status,
    required super.minResponses,
    required super.createdAt,
    required this.questions,
    super.openedAt,
    super.closedAt,
  });

  final List<QuestionSummary> questions;

  factory FeedbackRoundDetail.fromJson(Map<String, dynamic> json) {
    return FeedbackRoundDetail(
      id: json['id'] as String,
      groupId: json['groupId'] as String,
      subjectUserId: json['subjectUserId'] as String,
      questionnaireId: json['questionnaireId'] as String,
      questionnaireSlug: json['questionnaireSlug'] as String,
      status: json['status'] as String,
      minResponses: json['minResponses'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      openedAt: _parseOptionalDate(json['openedAt']),
      closedAt: _parseOptionalDate(json['closedAt']),
      questions: (json['questions'] as List<dynamic>)
          .map((item) => QuestionSummary.fromJson(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}

class AnswerSubmission {
  const AnswerSubmission({
    required this.questionId,
    this.score,
    this.text,
    this.optionIds,
  });

  final String questionId;
  final int? score;
  final String? text;
  final List<String>? optionIds;

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    if (score != null) 'score': score,
    if (text != null) 'text': text,
    if (optionIds != null) 'optionIds': optionIds,
  };
}

class ScaleQuestionResult {
  const ScaleQuestionResult({
    required this.questionId,
    required this.key,
    required this.prompt,
    required this.average,
    required this.distribution,
  });

  final String questionId;
  final String key;
  final String prompt;
  final double? average;
  final Map<String, int> distribution;

  factory ScaleQuestionResult.fromJson(Map<String, dynamic> json) {
    final rawAverage = json['average'];
    return ScaleQuestionResult(
      questionId: json['questionId'] as String,
      key: json['key'] as String,
      prompt: json['prompt'] as String,
      average: rawAverage == null ? null : (rawAverage as num).toDouble(),
      distribution: (json['distribution'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }
}

class TextQuestionResult {
  const TextQuestionResult({
    required this.questionId,
    required this.key,
    required this.prompt,
    required this.comments,
  });

  final String questionId;
  final String key;
  final String prompt;
  final List<String> comments;

  factory TextQuestionResult.fromJson(Map<String, dynamic> json) {
    return TextQuestionResult(
      questionId: json['questionId'] as String,
      key: json['key'] as String,
      prompt: json['prompt'] as String,
      comments: (json['comments'] as List<dynamic>).cast<String>(),
    );
  }
}

class ChoiceOptionResult {
  const ChoiceOptionResult({
    required this.optionId,
    required this.label,
    required this.count,
  });

  final String optionId;
  final String label;
  final int count;

  factory ChoiceOptionResult.fromJson(Map<String, dynamic> json) {
    return ChoiceOptionResult(
      optionId: json['optionId'] as String,
      label: json['label'] as String,
      count: json['count'] as int,
    );
  }
}

class ChoiceQuestionResult {
  const ChoiceQuestionResult({
    required this.questionId,
    required this.key,
    required this.prompt,
    required this.kind,
    required this.options,
  });

  final String questionId;
  final String key;
  final String prompt;
  final String kind;
  final List<ChoiceOptionResult> options;

  factory ChoiceQuestionResult.fromJson(Map<String, dynamic> json) {
    return ChoiceQuestionResult(
      questionId: json['questionId'] as String,
      key: json['key'] as String,
      prompt: json['prompt'] as String,
      kind: json['kind'] as String,
      options: (json['options'] as List<dynamic>)
          .map(
            (item) => ChoiceOptionResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

class FeedbackResults {
  const FeedbackResults({
    required this.roundId,
    required this.responseCount,
    required this.scaleResults,
    required this.textResults,
    required this.choiceResults,
  });

  final String roundId;
  final int responseCount;
  final List<ScaleQuestionResult> scaleResults;
  final List<TextQuestionResult> textResults;
  final List<ChoiceQuestionResult> choiceResults;

  factory FeedbackResults.fromJson(Map<String, dynamic> json) {
    return FeedbackResults(
      roundId: json['roundId'] as String,
      responseCount: json['responseCount'] as int,
      scaleResults: (json['scaleResults'] as List<dynamic>)
          .map(
            (item) =>
                ScaleQuestionResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      textResults: (json['textResults'] as List<dynamic>)
          .map(
            (item) => TextQuestionResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
      choiceResults: (json['choiceResults'] as List<dynamic>? ?? const [])
          .map(
            (item) =>
                ChoiceQuestionResult.fromJson(item as Map<String, dynamic>),
          )
          .toList(growable: false),
    );
  }
}

DateTime? _parseOptionalDate(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.parse(value as String);
}
