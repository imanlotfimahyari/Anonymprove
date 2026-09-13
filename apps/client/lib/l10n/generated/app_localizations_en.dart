// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Anonymprove';

  @override
  String get language => 'Language';

  @override
  String get languageAutomatic => 'Automatic';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageItalian => 'Italian';

  @override
  String get languagePersian => 'Persian';

  @override
  String get sessionHeadline =>
      'Constructive feedback, without exposing who said what.';

  @override
  String get sessionDescription =>
      'This MVP creates a temporary private session on this device. Account recovery and persistent sign-in come later.';

  @override
  String get startPrivateSession => 'Start private session';

  @override
  String get myGroups => 'My groups';

  @override
  String get temporarySessionIdentity => 'Temporary session identity';

  @override
  String get refresh => 'Refresh';

  @override
  String get noAssessmentsYet => 'No assessments yet';

  @override
  String get noAssessmentsMessage =>
      'Create a group or join an existing one to get started.';

  @override
  String get join => 'Join';

  @override
  String get create => 'Create';

  @override
  String get createGroup => 'Create group';

  @override
  String get groupName => 'Group name';

  @override
  String get joinGroup => 'Join group';

  @override
  String get joinCode => 'Join code';

  @override
  String get saveJoinCode => 'Save this join code';

  @override
  String get joinCodeShareHint =>
      'Share it only with people you want in this group. The API does not expose the code again later.';

  @override
  String get copyCode => 'Copy code';

  @override
  String get joinCodeCopied => 'Join code copied';

  @override
  String get iSavedIt => 'I saved it';

  @override
  String get cancel => 'Cancel';

  @override
  String get groupHealthHistory => 'Group health history';

  @override
  String get questionnaires => 'Questionnaires';

  @override
  String get noFeedbackRounds => 'No feedback rounds';

  @override
  String get noFeedbackRoundsMessage =>
      'Request feedback about yourself to start a round.';

  @override
  String get groupHealthAssessment => 'Group health assessment';

  @override
  String get yourFeedbackRound => 'Your feedback round';

  @override
  String get groupMemberFeedback => 'Group member feedback';

  @override
  String get assessGroupHealth => 'Assess group health';

  @override
  String get requestFeedback => 'Request feedback';

  @override
  String get statusDraft => 'Draft';

  @override
  String get statusOpen => 'Open';

  @override
  String get statusClosed => 'Closed';

  @override
  String get statusExpired => 'Expired';

  @override
  String get statusClosedNoResults => 'Closed without results';

  @override
  String roundListSubtitle(String status, int minResponses) {
    return '$status · minimum $minResponses responses';
  }

  @override
  String get groupHealth => 'Group health';

  @override
  String get feedbackRound => 'Feedback round';

  @override
  String get questions => 'Questions';

  @override
  String get oneHour => '1 hour';

  @override
  String get sixHours => '6 hours';

  @override
  String get twentyFourHoursRecommended => '24 hours · recommended';

  @override
  String get threeDays => '3 days';

  @override
  String get sevenDays => '7 days';

  @override
  String get responseWindowQuestion =>
      'How long should people have to respond?';

  @override
  String get extendResponsePeriodBy => 'Extend the response period by';

  @override
  String get endWithoutResultsTitle => 'End without results?';

  @override
  String get endWithoutResultsExplanation =>
      'The privacy threshold was not reached. This permanently ends the round without exposing partial results.';

  @override
  String get endWithoutResults => 'End without results';

  @override
  String get closeGroupHealthTitle => 'Close group health assessment?';

  @override
  String get closeFeedbackRoundTitle => 'Close feedback round?';

  @override
  String get closeGroupHealthExplanation =>
      'The privacy threshold has been reached. No more group-health responses can be submitted after closing.';

  @override
  String get closeFeedbackRoundExplanation =>
      'The privacy threshold has been reached. No more feedback can be submitted after closing.';

  @override
  String get closeAssessment => 'Close assessment';

  @override
  String get closeRound => 'Close round';

  @override
  String get feedbackSubmittedAnonymously => 'Feedback submitted anonymously.';

  @override
  String get assessmentNotOpened => 'This assessment has not been opened yet.';

  @override
  String get openGroupHealthAssessment => 'Open group health assessment';

  @override
  String get openRound => 'Open round';

  @override
  String openingGroupHealthRequirement(int minResponses) {
    return 'Opening requires at least $minResponses eligible group members in total.';
  }

  @override
  String openingFeedbackRequirement(int minResponses) {
    return 'Opening requires at least $minResponses other eligible group members.';
  }

  @override
  String get answerAnonymously => 'Answer anonymously';

  @override
  String get groupHealthEligibilityPrivacy =>
      'Your identity is used only to establish eligibility and issue one response credential. The submitted answers do not contain your session identity.';

  @override
  String get feedbackEligibilityPrivacy =>
      'Your identity is used to check eligibility and issue one response credential. The feedback submission itself does not send your session token.';

  @override
  String get closingAfterThreshold =>
      'Closing becomes available after the privacy threshold is met.';

  @override
  String get extendResponsePeriod => 'Extend response period';

  @override
  String get deadlinePassedPartialHidden =>
      'The deadline passed before the privacy threshold was reached. Partial results remain hidden.';

  @override
  String get deadlinePassedCreatorAction =>
      'The response deadline passed before enough responses were received. The round creator can extend it or end it without results.';

  @override
  String get viewAggregatedResults => 'View aggregated results';

  @override
  String get closedWithoutResultsMessage =>
      'This round ended without results because the privacy threshold was not reached.';

  @override
  String get roundNotAcceptingResponses =>
      'This round is not currently accepting responses.';

  @override
  String get roundLifecycle => 'Round lifecycle';

  @override
  String get responseDeadlineNotSet => 'Response deadline: not set yet';

  @override
  String responseDeadline(String value) {
    return 'Response deadline: $value';
  }

  @override
  String get deadlineReached => 'Deadline reached';

  @override
  String timeRemainingDays(int days, int hours) {
    return 'Time remaining: ${days}d ${hours}h';
  }

  @override
  String timeRemainingHours(int hours, int minutes) {
    return 'Time remaining: ${hours}h ${minutes}m';
  }

  @override
  String timeRemainingMinutes(int minutes) {
    return 'Time remaining: ${minutes}m';
  }

  @override
  String responsesReceived(int count) {
    return 'Responses received: $count';
  }

  @override
  String minimumRequired(int count) {
    return 'Minimum required: $count';
  }

  @override
  String get privacyThresholdReached => 'Privacy threshold reached.';

  @override
  String get privacyThresholdNotReached => 'Privacy threshold not reached yet.';

  @override
  String get anonymousCountOnly =>
      'Only the anonymous response count is shown; respondent identities are not exposed.';

  @override
  String get anonymousGroupAssessment => 'Anonymous group assessment';

  @override
  String get anonymousFeedback => 'Anonymous feedback';

  @override
  String get feedbackPrivacyNote =>
      'Focus on observable behavior. Do not include names or identifying details in free-text answers.';

  @override
  String get chooseScore => 'Choose a score';

  @override
  String get chooseOption => 'Choose an option';

  @override
  String get chooseAtLeastOneOption => 'Choose at least one option';

  @override
  String get enterResponse => 'Enter a response';

  @override
  String unsupportedQuestionType(String kind) {
    return 'Unsupported question type: $kind';
  }

  @override
  String get submitPrivately => 'Submit privately';

  @override
  String get yourFeedbackRequest => 'Your feedback request';

  @override
  String get anonymousFeedbackRequest => 'Anonymous feedback request';

  @override
  String statusValue(String status) {
    return 'Status: $status';
  }

  @override
  String privacyThresholdResponses(int count) {
    return 'Privacy threshold: $count responses';
  }

  @override
  String get creatorCanParticipate =>
      'You created this assessment and may also participate anonymously.';

  @override
  String get eligibleMembersCanParticipate =>
      'Eligible group members may participate anonymously.';

  @override
  String ratingRange(int min, int max) {
    return 'Rating $min-$max';
  }

  @override
  String singleChoiceOptions(int count) {
    return 'Single choice · $count options';
  }

  @override
  String multipleChoiceOptions(int count) {
    return 'Multiple choice · $count options';
  }

  @override
  String get requiredShortText => 'Required short text';

  @override
  String get optionalShortText => 'Optional short text';

  @override
  String get requiredLongText => 'Required long text';

  @override
  String get optionalLongText => 'Optional long text';

  @override
  String get informationOnly => 'Information only';

  @override
  String get coreFeedbackName => 'Core constructive feedback';

  @override
  String get coreFeedbackDescription =>
      'Built-in constructive self-improvement feedback questionnaire.';

  @override
  String get coreFeedbackCommunication => 'Communicates clearly and honestly.';

  @override
  String get coreFeedbackListening =>
      'Listens carefully and makes others feel heard.';

  @override
  String get coreFeedbackReliability =>
      'Follows through on commitments and can be relied on.';

  @override
  String get coreFeedbackEmpathy =>
      'Shows empathy and considers other people\'s feelings.';

  @override
  String get coreFeedbackBoundaries =>
      'Respects personal boundaries and differences.';

  @override
  String get coreFeedbackConflict =>
      'Handles disagreement without humiliation, threats, or unnecessary escalation.';

  @override
  String get coreFeedbackSupportiveness =>
      'Is supportive without creating pressure, exclusion, or unhealthy dependence.';

  @override
  String get coreFeedbackImprovement =>
      'What is one thing I could do differently to improve our interactions? Avoid names or identifying details.';

  @override
  String get coreGroupHealthName => 'Core group health';

  @override
  String get coreGroupHealthDescription =>
      'Built-in anonymous questionnaire for assessing group dynamics.';

  @override
  String get coreGroupHealthCommunication =>
      'People in this group communicate important things clearly and honestly.';

  @override
  String get coreGroupHealthListening =>
      'People listen to each other and different views can be expressed.';

  @override
  String get coreGroupHealthSafety =>
      'People can disagree without ridicule, threats, or retaliation.';

  @override
  String get coreGroupHealthReliability =>
      'People generally follow through on commitments to the group.';

  @override
  String get coreGroupHealthSupport =>
      'People help each other when support is reasonably needed.';

  @override
  String get coreGroupHealthConflict =>
      'Problems and disagreements are handled constructively.';

  @override
  String get coreGroupHealthBoundaries =>
      'Personal boundaries and differences are respected.';

  @override
  String get coreGroupHealthImprovement =>
      'What is one thing this group could improve? Avoid names or identifying details.';

  @override
  String get aggregatedResults => 'Aggregated results';

  @override
  String get resultsNotAvailable => 'Results are not available';

  @override
  String responseCount(int count) {
    return '$count responses';
  }

  @override
  String get aggregatedResultsPrivacy =>
      'Only aggregated results are shown after the privacy threshold.';

  @override
  String get noAnswers => 'No answers';

  @override
  String averageValue(String value) {
    return 'Average $value';
  }

  @override
  String get noCommentsSubmitted => 'No comments submitted.';

  @override
  String get historyUnavailable => 'History is unavailable';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistoryMessage =>
      'Complete a group health assessment to start building a history.';

  @override
  String get groupHealthHistoryExplanation =>
      'Each entry represents aggregated responses from one closed assessment that reached its privacy threshold. Changes may reflect both perceptions and changes in group membership. No overall health score is calculated.';

  @override
  String aggregatedResponseCount(int count) {
    return '$count aggregated responses';
  }

  @override
  String get noChange => 'No change';

  @override
  String versusPrevious(String value) {
    return '$value vs previous';
  }

  @override
  String get playfulReflection => 'Playful reflection';

  @override
  String get playfulDisclaimer =>
      'A playful summary of aggregated feedback — not a personality assessment.';

  @override
  String get thoughtfulOwl => 'Thoughtful Owl';

  @override
  String get helpingOctopus => 'Helping Octopus';

  @override
  String get clearSignalFox => 'Clear-Signal Fox';

  @override
  String get steadyTurtle => 'Steady Turtle';

  @override
  String get respectfulHedgehog => 'Respectful Hedgehog';

  @override
  String get calmElephant => 'Calm Elephant';

  @override
  String get balancedCapybara => 'Balanced Capybara';

  @override
  String get balancedPlayfulMessage =>
      'The strongest scale signals are close together, so there is no clear standout dimension in this round.';

  @override
  String personalPlayfulMessage(String prompt, String average) {
    return 'Your strongest aggregate signal was \"$prompt\" ($average/5).';
  }

  @override
  String groupPlayfulMessage(String prompt, String average) {
    return 'The group\'s strongest aggregate signal was \"$prompt\" ($average/5).';
  }

  @override
  String get newQuestionnaire => 'New questionnaire';

  @override
  String get questionnairePrivacyNote =>
      'Privacy note: do not ask respondents for names, initials, addresses, birthdays, or other identifying information. Anonymous storage cannot prevent a respondent from identifying themselves in an answer.';

  @override
  String get somethingWentWrong => 'Something went wrong.';

  @override
  String get couldNotSaveQuestionnaire => 'Could not save questionnaire.';

  @override
  String get builtIn => 'Built-in';

  @override
  String get statusPublished => 'Published';

  @override
  String versionBlocks(int version, int count) {
    return 'Version $version · $count blocks';
  }

  @override
  String get view => 'View';

  @override
  String get editDraft => 'Edit draft';

  @override
  String get publish => 'Publish';

  @override
  String get newVersion => 'New version';

  @override
  String get editorPrivacyNote =>
      'Avoid questions that request identifying information. Prefer observable behavior and bounded choices over personally identifying free text.';

  @override
  String get questionnaireTitle => 'Questionnaire title';

  @override
  String get questionnaireTitleExample =>
      'Example: Team communication and collaboration';

  @override
  String get enterTitle => 'Enter a title';

  @override
  String get descriptionInstructionsOptional =>
      'Description / instructions (optional)';

  @override
  String get descriptionExample =>
      'Example: Think about how we worked together during the last month.';

  @override
  String get addBlock => 'Add block';

  @override
  String get saveDraft => 'Save draft';

  @override
  String blockNumber(int number) {
    return 'Block $number';
  }

  @override
  String get type => 'Type';

  @override
  String get ratingScale => 'Rating scale';

  @override
  String get singleChoice => 'Single choice';

  @override
  String get multipleChoice => 'Multiple choice';

  @override
  String get shortText => 'Short text';

  @override
  String get longText => 'Long text';

  @override
  String get descriptionInformation => 'Description / information';

  @override
  String get scaleHelper =>
      'Rating scale: useful for measurable patterns, for example communication clarity.';

  @override
  String get singleChoiceHelper =>
      'Single choice: the respondent selects exactly one option.';

  @override
  String get multipleChoiceHelper =>
      'Multiple choice: the respondent may select several options.';

  @override
  String get shortTextHelper =>
      'Short text: best for one concise observation or suggestion.';

  @override
  String get longTextHelper =>
      'Long text: use when a more detailed constructive answer is useful.';

  @override
  String get descriptionHelper =>
      'Information only: shown to respondents; no answer is collected.';

  @override
  String get informationText => 'Information text';

  @override
  String get question => 'Question';

  @override
  String get informationTextExample =>
      'Example: Read this before answering the next questions.';

  @override
  String get questionBehaviorHelper =>
      'Keep it about observable behavior, not personality or identity.';

  @override
  String get blockCannotBeBlank => 'This block cannot be blank';

  @override
  String get required => 'Required';

  @override
  String get minimum => 'Minimum';

  @override
  String get maximum => 'Maximum';

  @override
  String get maxMustExceedMin => 'Maximum must be greater than minimum';

  @override
  String get optionsOnePerLine => 'Options (one per line)';

  @override
  String get optionsExample => 'Example: Rarely\nSometimes\nOften';

  @override
  String get addAtLeastTwoOptions => 'Add at least two options';

  @override
  String get optionOne => 'Option 1';

  @override
  String get optionTwo => 'Option 2';

  @override
  String get groupRoleOwner => 'Owner';

  @override
  String get groupRoleMember => 'Member';

  @override
  String get chooseQuestionnaire => 'Choose questionnaire';

  @override
  String get noPublishedQuestionnaires =>
      'No published questionnaires are available.';

  @override
  String get somethingWentWrongTryAgain =>
      'Something went wrong. Please try again.';
}
