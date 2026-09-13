import '../models/models.dart';
import 'generated/app_localizations.dart';

const coreFeedbackQuestionnaireSlug = 'core-feedback-v1';
const coreGroupHealthQuestionnaireSlug = 'core-group-health-v1';

String localizedQuestionnaireName(
  AppLocalizations l10n,
  QuestionnaireSummary questionnaire,
) {
  return switch (questionnaire.slug) {
    coreFeedbackQuestionnaireSlug => l10n.coreFeedbackName,
    coreGroupHealthQuestionnaireSlug => l10n.coreGroupHealthName,
    _ => questionnaire.name,
  };
}

String? localizedQuestionnaireDescription(
  AppLocalizations l10n,
  QuestionnaireSummary questionnaire,
) {
  return switch (questionnaire.slug) {
    coreFeedbackQuestionnaireSlug => l10n.coreFeedbackDescription,
    coreGroupHealthQuestionnaireSlug => l10n.coreGroupHealthDescription,
    _ => questionnaire.description,
  };
}

String localizedBuiltInQuestionPrompt(
  AppLocalizations l10n,
  String questionnaireSlug,
  String questionKey,
  String fallback,
) {
  if (questionnaireSlug == coreFeedbackQuestionnaireSlug) {
    return switch (questionKey) {
      'communication' => l10n.coreFeedbackCommunication,
      'listening' => l10n.coreFeedbackListening,
      'reliability' => l10n.coreFeedbackReliability,
      'empathy' => l10n.coreFeedbackEmpathy,
      'boundaries' => l10n.coreFeedbackBoundaries,
      'conflict' => l10n.coreFeedbackConflict,
      'supportiveness' => l10n.coreFeedbackSupportiveness,
      'improvement' => l10n.coreFeedbackImprovement,
      _ => fallback,
    };
  }

  if (questionnaireSlug == coreGroupHealthQuestionnaireSlug) {
    return switch (questionKey) {
      'communication' => l10n.coreGroupHealthCommunication,
      'listening' => l10n.coreGroupHealthListening,
      'safety' => l10n.coreGroupHealthSafety,
      'reliability' => l10n.coreGroupHealthReliability,
      'support' => l10n.coreGroupHealthSupport,
      'conflict' => l10n.coreGroupHealthConflict,
      'boundaries' => l10n.coreGroupHealthBoundaries,
      'improvement' => l10n.coreGroupHealthImprovement,
      _ => fallback,
    };
  }

  return fallback;
}
