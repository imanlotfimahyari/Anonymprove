import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fa'),
    Locale('it'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Anonymprove'**
  String get appTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get languageAutomatic;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageItalian.
  ///
  /// In en, this message translates to:
  /// **'Italian'**
  String get languageItalian;

  /// No description provided for @languagePersian.
  ///
  /// In en, this message translates to:
  /// **'Persian'**
  String get languagePersian;

  /// No description provided for @sessionHeadline.
  ///
  /// In en, this message translates to:
  /// **'Constructive feedback, without exposing who said what.'**
  String get sessionHeadline;

  /// No description provided for @sessionDescription.
  ///
  /// In en, this message translates to:
  /// **'This MVP creates a temporary private session on this device. Account recovery and persistent sign-in come later.'**
  String get sessionDescription;

  /// No description provided for @startPrivateSession.
  ///
  /// In en, this message translates to:
  /// **'Start private session'**
  String get startPrivateSession;

  /// No description provided for @myGroups.
  ///
  /// In en, this message translates to:
  /// **'My groups'**
  String get myGroups;

  /// No description provided for @temporarySessionIdentity.
  ///
  /// In en, this message translates to:
  /// **'Temporary session identity'**
  String get temporarySessionIdentity;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @noAssessmentsYet.
  ///
  /// In en, this message translates to:
  /// **'No assessments yet'**
  String get noAssessmentsYet;

  /// No description provided for @noAssessmentsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a group or join an existing one to get started.'**
  String get noAssessmentsMessage;

  /// No description provided for @join.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get join;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @createGroup.
  ///
  /// In en, this message translates to:
  /// **'Create group'**
  String get createGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Group name'**
  String get groupName;

  /// No description provided for @joinGroup.
  ///
  /// In en, this message translates to:
  /// **'Join group'**
  String get joinGroup;

  /// No description provided for @joinCode.
  ///
  /// In en, this message translates to:
  /// **'Join code'**
  String get joinCode;

  /// No description provided for @saveJoinCode.
  ///
  /// In en, this message translates to:
  /// **'Save this join code'**
  String get saveJoinCode;

  /// No description provided for @joinCodeShareHint.
  ///
  /// In en, this message translates to:
  /// **'Share it only with people you want in this group. The API does not expose the code again later.'**
  String get joinCodeShareHint;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @joinCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Join code copied'**
  String get joinCodeCopied;

  /// No description provided for @iSavedIt.
  ///
  /// In en, this message translates to:
  /// **'I saved it'**
  String get iSavedIt;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @groupHealthHistory.
  ///
  /// In en, this message translates to:
  /// **'Group health history'**
  String get groupHealthHistory;

  /// No description provided for @questionnaires.
  ///
  /// In en, this message translates to:
  /// **'Questionnaires'**
  String get questionnaires;

  /// No description provided for @noFeedbackRounds.
  ///
  /// In en, this message translates to:
  /// **'No feedback rounds'**
  String get noFeedbackRounds;

  /// No description provided for @noFeedbackRoundsMessage.
  ///
  /// In en, this message translates to:
  /// **'Request feedback about yourself to start a round.'**
  String get noFeedbackRoundsMessage;

  /// No description provided for @groupHealthAssessment.
  ///
  /// In en, this message translates to:
  /// **'Group health assessment'**
  String get groupHealthAssessment;

  /// No description provided for @yourFeedbackRound.
  ///
  /// In en, this message translates to:
  /// **'Your feedback round'**
  String get yourFeedbackRound;

  /// No description provided for @groupMemberFeedback.
  ///
  /// In en, this message translates to:
  /// **'Group member feedback'**
  String get groupMemberFeedback;

  /// No description provided for @assessGroupHealth.
  ///
  /// In en, this message translates to:
  /// **'Assess group health'**
  String get assessGroupHealth;

  /// No description provided for @requestFeedback.
  ///
  /// In en, this message translates to:
  /// **'Request feedback'**
  String get requestFeedback;

  /// No description provided for @statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get statusDraft;

  /// No description provided for @statusOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get statusOpen;

  /// No description provided for @statusClosed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get statusClosed;

  /// No description provided for @statusExpired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get statusExpired;

  /// No description provided for @statusClosedNoResults.
  ///
  /// In en, this message translates to:
  /// **'Closed without results'**
  String get statusClosedNoResults;

  /// No description provided for @roundListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{status} · minimum {minResponses} responses'**
  String roundListSubtitle(String status, int minResponses);

  /// No description provided for @groupHealth.
  ///
  /// In en, this message translates to:
  /// **'Group health'**
  String get groupHealth;

  /// No description provided for @feedbackRound.
  ///
  /// In en, this message translates to:
  /// **'Feedback round'**
  String get feedbackRound;

  /// No description provided for @questions.
  ///
  /// In en, this message translates to:
  /// **'Questions'**
  String get questions;

  /// No description provided for @oneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get oneHour;

  /// No description provided for @sixHours.
  ///
  /// In en, this message translates to:
  /// **'6 hours'**
  String get sixHours;

  /// No description provided for @twentyFourHoursRecommended.
  ///
  /// In en, this message translates to:
  /// **'24 hours · recommended'**
  String get twentyFourHoursRecommended;

  /// No description provided for @threeDays.
  ///
  /// In en, this message translates to:
  /// **'3 days'**
  String get threeDays;

  /// No description provided for @sevenDays.
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get sevenDays;

  /// No description provided for @responseWindowQuestion.
  ///
  /// In en, this message translates to:
  /// **'How long should people have to respond?'**
  String get responseWindowQuestion;

  /// No description provided for @extendResponsePeriodBy.
  ///
  /// In en, this message translates to:
  /// **'Extend the response period by'**
  String get extendResponsePeriodBy;

  /// No description provided for @endWithoutResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'End without results?'**
  String get endWithoutResultsTitle;

  /// No description provided for @endWithoutResultsExplanation.
  ///
  /// In en, this message translates to:
  /// **'The privacy threshold was not reached. This permanently ends the round without exposing partial results.'**
  String get endWithoutResultsExplanation;

  /// No description provided for @endWithoutResults.
  ///
  /// In en, this message translates to:
  /// **'End without results'**
  String get endWithoutResults;

  /// No description provided for @closeGroupHealthTitle.
  ///
  /// In en, this message translates to:
  /// **'Close group health assessment?'**
  String get closeGroupHealthTitle;

  /// No description provided for @closeFeedbackRoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Close feedback round?'**
  String get closeFeedbackRoundTitle;

  /// No description provided for @closeGroupHealthExplanation.
  ///
  /// In en, this message translates to:
  /// **'The privacy threshold has been reached. No more group-health responses can be submitted after closing.'**
  String get closeGroupHealthExplanation;

  /// No description provided for @closeFeedbackRoundExplanation.
  ///
  /// In en, this message translates to:
  /// **'The privacy threshold has been reached. No more feedback can be submitted after closing.'**
  String get closeFeedbackRoundExplanation;

  /// No description provided for @closeAssessment.
  ///
  /// In en, this message translates to:
  /// **'Close assessment'**
  String get closeAssessment;

  /// No description provided for @closeRound.
  ///
  /// In en, this message translates to:
  /// **'Close round'**
  String get closeRound;

  /// No description provided for @feedbackSubmittedAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Feedback submitted anonymously.'**
  String get feedbackSubmittedAnonymously;

  /// No description provided for @assessmentNotOpened.
  ///
  /// In en, this message translates to:
  /// **'This assessment has not been opened yet.'**
  String get assessmentNotOpened;

  /// No description provided for @openGroupHealthAssessment.
  ///
  /// In en, this message translates to:
  /// **'Open group health assessment'**
  String get openGroupHealthAssessment;

  /// No description provided for @openRound.
  ///
  /// In en, this message translates to:
  /// **'Open round'**
  String get openRound;

  /// No description provided for @openingGroupHealthRequirement.
  ///
  /// In en, this message translates to:
  /// **'Opening requires at least {minResponses} eligible group members in total.'**
  String openingGroupHealthRequirement(int minResponses);

  /// No description provided for @openingFeedbackRequirement.
  ///
  /// In en, this message translates to:
  /// **'Opening requires at least {minResponses} other eligible group members.'**
  String openingFeedbackRequirement(int minResponses);

  /// No description provided for @answerAnonymously.
  ///
  /// In en, this message translates to:
  /// **'Answer anonymously'**
  String get answerAnonymously;

  /// No description provided for @groupHealthEligibilityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your identity is used only to establish eligibility and issue one response credential. The submitted answers do not contain your session identity.'**
  String get groupHealthEligibilityPrivacy;

  /// No description provided for @feedbackEligibilityPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Your identity is used to check eligibility and issue one response credential. The feedback submission itself does not send your session token.'**
  String get feedbackEligibilityPrivacy;

  /// No description provided for @closingAfterThreshold.
  ///
  /// In en, this message translates to:
  /// **'Closing becomes available after the privacy threshold is met.'**
  String get closingAfterThreshold;

  /// No description provided for @extendResponsePeriod.
  ///
  /// In en, this message translates to:
  /// **'Extend response period'**
  String get extendResponsePeriod;

  /// No description provided for @deadlinePassedPartialHidden.
  ///
  /// In en, this message translates to:
  /// **'The deadline passed before the privacy threshold was reached. Partial results remain hidden.'**
  String get deadlinePassedPartialHidden;

  /// No description provided for @deadlinePassedCreatorAction.
  ///
  /// In en, this message translates to:
  /// **'The response deadline passed before enough responses were received. The round creator can extend it or end it without results.'**
  String get deadlinePassedCreatorAction;

  /// No description provided for @viewAggregatedResults.
  ///
  /// In en, this message translates to:
  /// **'View aggregated results'**
  String get viewAggregatedResults;

  /// No description provided for @closedWithoutResultsMessage.
  ///
  /// In en, this message translates to:
  /// **'This round ended without results because the privacy threshold was not reached.'**
  String get closedWithoutResultsMessage;

  /// No description provided for @roundNotAcceptingResponses.
  ///
  /// In en, this message translates to:
  /// **'This round is not currently accepting responses.'**
  String get roundNotAcceptingResponses;

  /// No description provided for @roundLifecycle.
  ///
  /// In en, this message translates to:
  /// **'Round lifecycle'**
  String get roundLifecycle;

  /// No description provided for @responseDeadlineNotSet.
  ///
  /// In en, this message translates to:
  /// **'Response deadline: not set yet'**
  String get responseDeadlineNotSet;

  /// No description provided for @responseDeadline.
  ///
  /// In en, this message translates to:
  /// **'Response deadline: {value}'**
  String responseDeadline(String value);

  /// No description provided for @deadlineReached.
  ///
  /// In en, this message translates to:
  /// **'Deadline reached'**
  String get deadlineReached;

  /// No description provided for @timeRemainingDays.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {days}d {hours}h'**
  String timeRemainingDays(int days, int hours);

  /// No description provided for @timeRemainingHours.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {hours}h {minutes}m'**
  String timeRemainingHours(int hours, int minutes);

  /// No description provided for @timeRemainingMinutes.
  ///
  /// In en, this message translates to:
  /// **'Time remaining: {minutes}m'**
  String timeRemainingMinutes(int minutes);

  /// No description provided for @responsesReceived.
  ///
  /// In en, this message translates to:
  /// **'Responses received: {count}'**
  String responsesReceived(int count);

  /// No description provided for @minimumRequired.
  ///
  /// In en, this message translates to:
  /// **'Minimum required: {count}'**
  String minimumRequired(int count);

  /// No description provided for @privacyThresholdReached.
  ///
  /// In en, this message translates to:
  /// **'Privacy threshold reached.'**
  String get privacyThresholdReached;

  /// No description provided for @privacyThresholdNotReached.
  ///
  /// In en, this message translates to:
  /// **'Privacy threshold not reached yet.'**
  String get privacyThresholdNotReached;

  /// No description provided for @anonymousCountOnly.
  ///
  /// In en, this message translates to:
  /// **'Only the anonymous response count is shown; respondent identities are not exposed.'**
  String get anonymousCountOnly;

  /// No description provided for @anonymousGroupAssessment.
  ///
  /// In en, this message translates to:
  /// **'Anonymous group assessment'**
  String get anonymousGroupAssessment;

  /// No description provided for @anonymousFeedback.
  ///
  /// In en, this message translates to:
  /// **'Anonymous feedback'**
  String get anonymousFeedback;

  /// No description provided for @feedbackPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Focus on observable behavior. Do not include names or identifying details in free-text answers.'**
  String get feedbackPrivacyNote;

  /// No description provided for @chooseScore.
  ///
  /// In en, this message translates to:
  /// **'Choose a score'**
  String get chooseScore;

  /// No description provided for @chooseOption.
  ///
  /// In en, this message translates to:
  /// **'Choose an option'**
  String get chooseOption;

  /// No description provided for @chooseAtLeastOneOption.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one option'**
  String get chooseAtLeastOneOption;

  /// No description provided for @enterResponse.
  ///
  /// In en, this message translates to:
  /// **'Enter a response'**
  String get enterResponse;

  /// No description provided for @unsupportedQuestionType.
  ///
  /// In en, this message translates to:
  /// **'Unsupported question type: {kind}'**
  String unsupportedQuestionType(String kind);

  /// No description provided for @submitPrivately.
  ///
  /// In en, this message translates to:
  /// **'Submit privately'**
  String get submitPrivately;

  /// No description provided for @yourFeedbackRequest.
  ///
  /// In en, this message translates to:
  /// **'Your feedback request'**
  String get yourFeedbackRequest;

  /// No description provided for @anonymousFeedbackRequest.
  ///
  /// In en, this message translates to:
  /// **'Anonymous feedback request'**
  String get anonymousFeedbackRequest;

  /// No description provided for @statusValue.
  ///
  /// In en, this message translates to:
  /// **'Status: {status}'**
  String statusValue(String status);

  /// No description provided for @privacyThresholdResponses.
  ///
  /// In en, this message translates to:
  /// **'Privacy threshold: {count} responses'**
  String privacyThresholdResponses(int count);

  /// No description provided for @creatorCanParticipate.
  ///
  /// In en, this message translates to:
  /// **'You created this assessment and may also participate anonymously.'**
  String get creatorCanParticipate;

  /// No description provided for @eligibleMembersCanParticipate.
  ///
  /// In en, this message translates to:
  /// **'Eligible group members may participate anonymously.'**
  String get eligibleMembersCanParticipate;

  /// No description provided for @ratingRange.
  ///
  /// In en, this message translates to:
  /// **'Rating {min}-{max}'**
  String ratingRange(int min, int max);

  /// No description provided for @singleChoiceOptions.
  ///
  /// In en, this message translates to:
  /// **'Single choice · {count} options'**
  String singleChoiceOptions(int count);

  /// No description provided for @multipleChoiceOptions.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice · {count} options'**
  String multipleChoiceOptions(int count);

  /// No description provided for @requiredShortText.
  ///
  /// In en, this message translates to:
  /// **'Required short text'**
  String get requiredShortText;

  /// No description provided for @optionalShortText.
  ///
  /// In en, this message translates to:
  /// **'Optional short text'**
  String get optionalShortText;

  /// No description provided for @requiredLongText.
  ///
  /// In en, this message translates to:
  /// **'Required long text'**
  String get requiredLongText;

  /// No description provided for @optionalLongText.
  ///
  /// In en, this message translates to:
  /// **'Optional long text'**
  String get optionalLongText;

  /// No description provided for @informationOnly.
  ///
  /// In en, this message translates to:
  /// **'Information only'**
  String get informationOnly;

  /// No description provided for @coreFeedbackName.
  ///
  /// In en, this message translates to:
  /// **'Core constructive feedback'**
  String get coreFeedbackName;

  /// No description provided for @coreFeedbackDescription.
  ///
  /// In en, this message translates to:
  /// **'Built-in constructive self-improvement feedback questionnaire.'**
  String get coreFeedbackDescription;

  /// No description provided for @coreFeedbackCommunication.
  ///
  /// In en, this message translates to:
  /// **'Communicates clearly and honestly.'**
  String get coreFeedbackCommunication;

  /// No description provided for @coreFeedbackListening.
  ///
  /// In en, this message translates to:
  /// **'Listens carefully and makes others feel heard.'**
  String get coreFeedbackListening;

  /// No description provided for @coreFeedbackReliability.
  ///
  /// In en, this message translates to:
  /// **'Follows through on commitments and can be relied on.'**
  String get coreFeedbackReliability;

  /// No description provided for @coreFeedbackEmpathy.
  ///
  /// In en, this message translates to:
  /// **'Shows empathy and considers other people\'s feelings.'**
  String get coreFeedbackEmpathy;

  /// No description provided for @coreFeedbackBoundaries.
  ///
  /// In en, this message translates to:
  /// **'Respects personal boundaries and differences.'**
  String get coreFeedbackBoundaries;

  /// No description provided for @coreFeedbackConflict.
  ///
  /// In en, this message translates to:
  /// **'Handles disagreement without humiliation, threats, or unnecessary escalation.'**
  String get coreFeedbackConflict;

  /// No description provided for @coreFeedbackSupportiveness.
  ///
  /// In en, this message translates to:
  /// **'Is supportive without creating pressure, exclusion, or unhealthy dependence.'**
  String get coreFeedbackSupportiveness;

  /// No description provided for @coreFeedbackImprovement.
  ///
  /// In en, this message translates to:
  /// **'What is one thing I could do differently to improve our interactions? Avoid names or identifying details.'**
  String get coreFeedbackImprovement;

  /// No description provided for @coreGroupHealthName.
  ///
  /// In en, this message translates to:
  /// **'Core group health'**
  String get coreGroupHealthName;

  /// No description provided for @coreGroupHealthDescription.
  ///
  /// In en, this message translates to:
  /// **'Built-in anonymous questionnaire for assessing group dynamics.'**
  String get coreGroupHealthDescription;

  /// No description provided for @coreGroupHealthCommunication.
  ///
  /// In en, this message translates to:
  /// **'People in this group communicate important things clearly and honestly.'**
  String get coreGroupHealthCommunication;

  /// No description provided for @coreGroupHealthListening.
  ///
  /// In en, this message translates to:
  /// **'People listen to each other and different views can be expressed.'**
  String get coreGroupHealthListening;

  /// No description provided for @coreGroupHealthSafety.
  ///
  /// In en, this message translates to:
  /// **'People can disagree without ridicule, threats, or retaliation.'**
  String get coreGroupHealthSafety;

  /// No description provided for @coreGroupHealthReliability.
  ///
  /// In en, this message translates to:
  /// **'People generally follow through on commitments to the group.'**
  String get coreGroupHealthReliability;

  /// No description provided for @coreGroupHealthSupport.
  ///
  /// In en, this message translates to:
  /// **'People help each other when support is reasonably needed.'**
  String get coreGroupHealthSupport;

  /// No description provided for @coreGroupHealthConflict.
  ///
  /// In en, this message translates to:
  /// **'Problems and disagreements are handled constructively.'**
  String get coreGroupHealthConflict;

  /// No description provided for @coreGroupHealthBoundaries.
  ///
  /// In en, this message translates to:
  /// **'Personal boundaries and differences are respected.'**
  String get coreGroupHealthBoundaries;

  /// No description provided for @coreGroupHealthImprovement.
  ///
  /// In en, this message translates to:
  /// **'What is one thing this group could improve? Avoid names or identifying details.'**
  String get coreGroupHealthImprovement;

  /// No description provided for @aggregatedResults.
  ///
  /// In en, this message translates to:
  /// **'Aggregated results'**
  String get aggregatedResults;

  /// No description provided for @resultsNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Results are not available'**
  String get resultsNotAvailable;

  /// No description provided for @responseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} responses'**
  String responseCount(int count);

  /// No description provided for @aggregatedResultsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Only aggregated results are shown after the privacy threshold.'**
  String get aggregatedResultsPrivacy;

  /// No description provided for @noAnswers.
  ///
  /// In en, this message translates to:
  /// **'No answers'**
  String get noAnswers;

  /// No description provided for @averageValue.
  ///
  /// In en, this message translates to:
  /// **'Average {value}'**
  String averageValue(String value);

  /// No description provided for @noCommentsSubmitted.
  ///
  /// In en, this message translates to:
  /// **'No comments submitted.'**
  String get noCommentsSubmitted;

  /// No description provided for @historyUnavailable.
  ///
  /// In en, this message translates to:
  /// **'History is unavailable'**
  String get historyUnavailable;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @noHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Complete a group health assessment to start building a history.'**
  String get noHistoryMessage;

  /// No description provided for @groupHealthHistoryExplanation.
  ///
  /// In en, this message translates to:
  /// **'Each entry represents aggregated responses from one closed assessment that reached its privacy threshold. Changes may reflect both perceptions and changes in group membership. No overall health score is calculated.'**
  String get groupHealthHistoryExplanation;

  /// No description provided for @aggregatedResponseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} aggregated responses'**
  String aggregatedResponseCount(int count);

  /// No description provided for @noChange.
  ///
  /// In en, this message translates to:
  /// **'No change'**
  String get noChange;

  /// No description provided for @versusPrevious.
  ///
  /// In en, this message translates to:
  /// **'{value} vs previous'**
  String versusPrevious(String value);

  /// No description provided for @playfulReflection.
  ///
  /// In en, this message translates to:
  /// **'Playful reflection'**
  String get playfulReflection;

  /// No description provided for @playfulDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'A playful summary of aggregated feedback — not a personality assessment.'**
  String get playfulDisclaimer;

  /// No description provided for @thoughtfulOwl.
  ///
  /// In en, this message translates to:
  /// **'Thoughtful Owl'**
  String get thoughtfulOwl;

  /// No description provided for @helpingOctopus.
  ///
  /// In en, this message translates to:
  /// **'Helping Octopus'**
  String get helpingOctopus;

  /// No description provided for @clearSignalFox.
  ///
  /// In en, this message translates to:
  /// **'Clear-Signal Fox'**
  String get clearSignalFox;

  /// No description provided for @steadyTurtle.
  ///
  /// In en, this message translates to:
  /// **'Steady Turtle'**
  String get steadyTurtle;

  /// No description provided for @respectfulHedgehog.
  ///
  /// In en, this message translates to:
  /// **'Respectful Hedgehog'**
  String get respectfulHedgehog;

  /// No description provided for @calmElephant.
  ///
  /// In en, this message translates to:
  /// **'Calm Elephant'**
  String get calmElephant;

  /// No description provided for @balancedCapybara.
  ///
  /// In en, this message translates to:
  /// **'Balanced Capybara'**
  String get balancedCapybara;

  /// No description provided for @balancedPlayfulMessage.
  ///
  /// In en, this message translates to:
  /// **'The strongest scale signals are close together, so there is no clear standout dimension in this round.'**
  String get balancedPlayfulMessage;

  /// No description provided for @personalPlayfulMessage.
  ///
  /// In en, this message translates to:
  /// **'Your strongest aggregate signal was \"{prompt}\" ({average}/5).'**
  String personalPlayfulMessage(String prompt, String average);

  /// No description provided for @groupPlayfulMessage.
  ///
  /// In en, this message translates to:
  /// **'The group\'s strongest aggregate signal was \"{prompt}\" ({average}/5).'**
  String groupPlayfulMessage(String prompt, String average);

  /// No description provided for @newQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'New questionnaire'**
  String get newQuestionnaire;

  /// No description provided for @questionnairePrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Privacy note: do not ask respondents for names, initials, addresses, birthdays, or other identifying information. Anonymous storage cannot prevent a respondent from identifying themselves in an answer.'**
  String get questionnairePrivacyNote;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get somethingWentWrong;

  /// No description provided for @couldNotSaveQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Could not save questionnaire.'**
  String get couldNotSaveQuestionnaire;

  /// No description provided for @builtIn.
  ///
  /// In en, this message translates to:
  /// **'Built-in'**
  String get builtIn;

  /// No description provided for @statusPublished.
  ///
  /// In en, this message translates to:
  /// **'Published'**
  String get statusPublished;

  /// No description provided for @versionBlocks.
  ///
  /// In en, this message translates to:
  /// **'Version {version} · {count} blocks'**
  String versionBlocks(int version, int count);

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @editDraft.
  ///
  /// In en, this message translates to:
  /// **'Edit draft'**
  String get editDraft;

  /// No description provided for @publish.
  ///
  /// In en, this message translates to:
  /// **'Publish'**
  String get publish;

  /// No description provided for @newVersion.
  ///
  /// In en, this message translates to:
  /// **'New version'**
  String get newVersion;

  /// No description provided for @editorPrivacyNote.
  ///
  /// In en, this message translates to:
  /// **'Avoid questions that request identifying information. Prefer observable behavior and bounded choices over personally identifying free text.'**
  String get editorPrivacyNote;

  /// No description provided for @questionnaireTitle.
  ///
  /// In en, this message translates to:
  /// **'Questionnaire title'**
  String get questionnaireTitle;

  /// No description provided for @questionnaireTitleExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Team communication and collaboration'**
  String get questionnaireTitleExample;

  /// No description provided for @enterTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter a title'**
  String get enterTitle;

  /// No description provided for @descriptionInstructionsOptional.
  ///
  /// In en, this message translates to:
  /// **'Description / instructions (optional)'**
  String get descriptionInstructionsOptional;

  /// No description provided for @descriptionExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Think about how we worked together during the last month.'**
  String get descriptionExample;

  /// No description provided for @addBlock.
  ///
  /// In en, this message translates to:
  /// **'Add block'**
  String get addBlock;

  /// No description provided for @saveDraft.
  ///
  /// In en, this message translates to:
  /// **'Save draft'**
  String get saveDraft;

  /// No description provided for @blockNumber.
  ///
  /// In en, this message translates to:
  /// **'Block {number}'**
  String blockNumber(int number);

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @ratingScale.
  ///
  /// In en, this message translates to:
  /// **'Rating scale'**
  String get ratingScale;

  /// No description provided for @singleChoice.
  ///
  /// In en, this message translates to:
  /// **'Single choice'**
  String get singleChoice;

  /// No description provided for @multipleChoice.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice'**
  String get multipleChoice;

  /// No description provided for @shortText.
  ///
  /// In en, this message translates to:
  /// **'Short text'**
  String get shortText;

  /// No description provided for @longText.
  ///
  /// In en, this message translates to:
  /// **'Long text'**
  String get longText;

  /// No description provided for @descriptionInformation.
  ///
  /// In en, this message translates to:
  /// **'Description / information'**
  String get descriptionInformation;

  /// No description provided for @scaleHelper.
  ///
  /// In en, this message translates to:
  /// **'Rating scale: useful for measurable patterns, for example communication clarity.'**
  String get scaleHelper;

  /// No description provided for @singleChoiceHelper.
  ///
  /// In en, this message translates to:
  /// **'Single choice: the respondent selects exactly one option.'**
  String get singleChoiceHelper;

  /// No description provided for @multipleChoiceHelper.
  ///
  /// In en, this message translates to:
  /// **'Multiple choice: the respondent may select several options.'**
  String get multipleChoiceHelper;

  /// No description provided for @shortTextHelper.
  ///
  /// In en, this message translates to:
  /// **'Short text: best for one concise observation or suggestion.'**
  String get shortTextHelper;

  /// No description provided for @longTextHelper.
  ///
  /// In en, this message translates to:
  /// **'Long text: use when a more detailed constructive answer is useful.'**
  String get longTextHelper;

  /// No description provided for @descriptionHelper.
  ///
  /// In en, this message translates to:
  /// **'Information only: shown to respondents; no answer is collected.'**
  String get descriptionHelper;

  /// No description provided for @informationText.
  ///
  /// In en, this message translates to:
  /// **'Information text'**
  String get informationText;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Question'**
  String get question;

  /// No description provided for @informationTextExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Read this before answering the next questions.'**
  String get informationTextExample;

  /// No description provided for @questionBehaviorHelper.
  ///
  /// In en, this message translates to:
  /// **'Keep it about observable behavior, not personality or identity.'**
  String get questionBehaviorHelper;

  /// No description provided for @blockCannotBeBlank.
  ///
  /// In en, this message translates to:
  /// **'This block cannot be blank'**
  String get blockCannotBeBlank;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @minimum.
  ///
  /// In en, this message translates to:
  /// **'Minimum'**
  String get minimum;

  /// No description provided for @maximum.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get maximum;

  /// No description provided for @maxMustExceedMin.
  ///
  /// In en, this message translates to:
  /// **'Maximum must be greater than minimum'**
  String get maxMustExceedMin;

  /// No description provided for @optionsOnePerLine.
  ///
  /// In en, this message translates to:
  /// **'Options (one per line)'**
  String get optionsOnePerLine;

  /// No description provided for @optionsExample.
  ///
  /// In en, this message translates to:
  /// **'Example: Rarely\nSometimes\nOften'**
  String get optionsExample;

  /// No description provided for @addAtLeastTwoOptions.
  ///
  /// In en, this message translates to:
  /// **'Add at least two options'**
  String get addAtLeastTwoOptions;

  /// No description provided for @optionOne.
  ///
  /// In en, this message translates to:
  /// **'Option 1'**
  String get optionOne;

  /// No description provided for @optionTwo.
  ///
  /// In en, this message translates to:
  /// **'Option 2'**
  String get optionTwo;

  /// No description provided for @groupRoleOwner.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get groupRoleOwner;

  /// No description provided for @groupRoleMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get groupRoleMember;

  /// No description provided for @chooseQuestionnaire.
  ///
  /// In en, this message translates to:
  /// **'Choose questionnaire'**
  String get chooseQuestionnaire;

  /// No description provided for @noPublishedQuestionnaires.
  ///
  /// In en, this message translates to:
  /// **'No published questionnaires are available.'**
  String get noPublishedQuestionnaires;

  /// No description provided for @somethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get somethingWentWrongTryAgain;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fa', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fa':
      return AppLocalizationsFa();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
