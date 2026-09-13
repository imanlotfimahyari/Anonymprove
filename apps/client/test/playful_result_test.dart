import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_feedback_app/models/models.dart';
import 'package:privacy_feedback_app/results/playful_result.dart';

void main() {
  group('buildPlayfulResult', () {
    test('maps a clear communication strength to Clear-Signal Fox', () {
      final result = buildPlayfulResult(
        _results([
          _scale('communication', 4.8),
          _scale('listening', 4.2),
          _scale('reliability', 4.0),
        ]),
        questionnaireSlug: 'core-feedback-v1',
      );

      expect(result, isNotNull);
      expect(result!.character, PlayfulCharacter.clearSignalFox);
      expect(result.title, 'Clear-Signal Fox');
      expect(result.spotlightKey, 'communication');
      expect(result.spotlightAverage, 4.8);
    });

    test('uses Balanced Capybara when top dimensions are too close', () {
      final result = buildPlayfulResult(
        _results([
          _scale('communication', 4.60),
          _scale('listening', 4.45),
          _scale('reliability', 4.00),
        ]),
        questionnaireSlug: 'core-feedback-v1',
      );

      expect(result, isNotNull);
      expect(result!.character, PlayfulCharacter.balancedCapybara);
      expect(result.spotlightKey, isNull);
      expect(result.spotlightAverage, isNull);
    });

    test('supports known group-health dimensions', () {
      final result = buildPlayfulResult(
        _results([
          _scale('support', 4.9),
          _scale('communication', 4.1),
          _scale('safety', 4.0),
        ]),
        questionnaireSlug: 'core-group-health-v1',
      );

      expect(result, isNotNull);
      expect(result!.character, PlayfulCharacter.helpingOctopus);
      expect(result.spotlightKey, 'support');
      expect(result.message, startsWith('The group'));
    });

    test('returns null for custom questionnaires', () {
      final result = buildPlayfulResult(
        _results([
          _scale('my_custom_dimension', 5.0),
          _scale('another_dimension', 3.0),
        ]),
        questionnaireSlug: 'custom-team-feedback-v1',
      );

      expect(result, isNull);
    });

    test('returns null when no scale average is available', () {
      final result = buildPlayfulResult(
        _results([_scale('communication', null), _scale('listening', null)]),
        questionnaireSlug: 'core-feedback-v1',
      );

      expect(result, isNull);
    });

    test('free-text comments cannot influence the playful result', () {
      final first = buildPlayfulResult(
        _results(
          [_scale('reliability', 4.9), _scale('communication', 4.0)],
          comments: const ['First private comment'],
        ),
        questionnaireSlug: 'core-feedback-v1',
      );

      final second = buildPlayfulResult(
        _results(
          [_scale('reliability', 4.9), _scale('communication', 4.0)],
          comments: const [
            'Completely different private comment',
            'Another comment',
          ],
        ),
        questionnaireSlug: 'core-feedback-v1',
      );

      expect(first, isNotNull);
      expect(second, isNotNull);
      expect(first!.character, PlayfulCharacter.steadyTurtle);
      expect(second!.character, first.character);
      expect(second.spotlightKey, first.spotlightKey);
      expect(second.spotlightAverage, first.spotlightAverage);
    });

    test('unknown future built-in dimension fails closed', () {
      final result = buildPlayfulResult(
        _results([
          _scale('future_dimension', 5.0),
          _scale('communication', 4.0),
        ]),
        questionnaireSlug: 'core-feedback-v1',
      );

      expect(result, isNull);
    });
  });
}

ScaleQuestionResult _scale(String key, double? average) {
  return ScaleQuestionResult(
    questionId: 'question-$key',
    key: key,
    prompt: 'Prompt for $key',
    average: average,
    distribution: const {},
  );
}

FeedbackResults _results(
  List<ScaleQuestionResult> scales, {
  List<String> comments = const [],
}) {
  return FeedbackResults(
    roundId: 'round-1',
    responseCount: 3,
    scaleResults: scales,
    textResults: [
      TextQuestionResult(
        questionId: 'question-improvement',
        key: 'improvement',
        prompt: 'What could improve?',
        comments: comments,
      ),
    ],
    choiceResults: const [],
  );
}
