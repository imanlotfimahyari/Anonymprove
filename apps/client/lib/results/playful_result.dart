import '../models/models.dart';

const _coreFeedbackSlug = 'core-feedback-v1';
const _coreGroupHealthSlug = 'core-group-health-v1';

/// If the two strongest dimensions are closer than this on the built-in
/// 1..5 scale, we avoid pretending there is a meaningful standout.
const _standoutGap = 0.25;

enum PlayfulCharacter {
  thoughtfulOwl,
  helpingOctopus,
  clearSignalFox,
  steadyTurtle,
  respectfulHedgehog,
  calmElephant,
  balancedCapybara,
}

class PlayfulResult {
  const PlayfulResult({
    required this.character,
    required this.title,
    required this.message,
    required this.disclaimer,
    this.spotlightKey,
    this.spotlightPrompt,
    this.spotlightAverage,
  });

  final PlayfulCharacter character;
  final String title;
  final String message;
  final String disclaimer;

  final String? spotlightKey;
  final String? spotlightPrompt;
  final double? spotlightAverage;
}

/// Builds a local, deterministic, aggregate-only playful summary.
///
/// Privacy boundary:
/// - reads only [FeedbackResults.scaleResults]
/// - never reads free-text comments
/// - never reads respondent identity or response credentials
/// - never sends data to an external service
///
/// We intentionally support only the built-in questionnaires whose scale
/// semantics are known. Custom questionnaires return null rather than having
/// meaning inferred from arbitrary user-authored questions.
PlayfulResult? buildPlayfulResult(
  FeedbackResults results, {
  required String questionnaireSlug,
}) {
  if (questionnaireSlug != _coreFeedbackSlug &&
      questionnaireSlug != _coreGroupHealthSlug) {
    return null;
  }

  final scored = results.scaleResults
      .where((result) => result.average != null)
      .toList(growable: false);

  if (scored.isEmpty) {
    return null;
  }

  final ordered = [...scored]
    ..sort((left, right) {
      final averageComparison = right.average!.compareTo(left.average!);
      if (averageComparison != 0) {
        return averageComparison;
      }

      return left.key.compareTo(right.key);
    });

  final strongest = ordered.first;

  if (ordered.length > 1) {
    final second = ordered[1];
    final gap = strongest.average! - second.average!;

    if (gap < _standoutGap) {
      return const PlayfulResult(
        character: PlayfulCharacter.balancedCapybara,
        title: 'Balanced Capybara',
        message:
            'Your strongest scale signals are close together, so there is no '
            'clear standout dimension in this round.',
        disclaimer:
            'A playful summary of aggregated feedback — not a personality assessment.',
      );
    }
  }

  final character = _characterForKey(strongest.key);
  if (character == null) {
    // Fail closed if a future built-in questionnaire introduces semantics
    // that this client version does not understand.
    return null;
  }

  final isGroupHealth = questionnaireSlug == _coreGroupHealthSlug;
  final subject = isGroupHealth ? 'The group' : 'You';

  return PlayfulResult(
    character: character,
    title: _titleForCharacter(character),
    message:
        '$subject received the strongest aggregate signal for '
        '"${strongest.prompt}" (${strongest.average!.toStringAsFixed(1)}/5).',
    disclaimer:
        'A playful summary of aggregated feedback — not a personality assessment.',
    spotlightKey: strongest.key,
    spotlightPrompt: strongest.prompt,
    spotlightAverage: strongest.average,
  );
}

PlayfulCharacter? _characterForKey(String key) {
  switch (key) {
    case 'communication':
      return PlayfulCharacter.clearSignalFox;

    case 'listening':
    case 'empathy':
      return PlayfulCharacter.thoughtfulOwl;

    case 'reliability':
      return PlayfulCharacter.steadyTurtle;

    case 'supportiveness':
    case 'support':
      return PlayfulCharacter.helpingOctopus;

    case 'boundaries':
      return PlayfulCharacter.respectfulHedgehog;

    case 'conflict':
    case 'safety':
      return PlayfulCharacter.calmElephant;

    default:
      return null;
  }
}

String _titleForCharacter(PlayfulCharacter character) {
  switch (character) {
    case PlayfulCharacter.thoughtfulOwl:
      return 'Thoughtful Owl';
    case PlayfulCharacter.helpingOctopus:
      return 'Helping Octopus';
    case PlayfulCharacter.clearSignalFox:
      return 'Clear-Signal Fox';
    case PlayfulCharacter.steadyTurtle:
      return 'Steady Turtle';
    case PlayfulCharacter.respectfulHedgehog:
      return 'Respectful Hedgehog';
    case PlayfulCharacter.calmElephant:
      return 'Calm Elephant';
    case PlayfulCharacter.balancedCapybara:
      return 'Balanced Capybara';
  }
}
