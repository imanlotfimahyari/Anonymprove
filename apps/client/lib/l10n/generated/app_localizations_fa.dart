// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Persian (`fa`).
class AppLocalizationsFa extends AppLocalizations {
  AppLocalizationsFa([String locale = 'fa']) : super(locale);

  @override
  String get appTitle => 'Anonymprove';

  @override
  String get language => 'زبان';

  @override
  String get languageAutomatic => 'خودکار';

  @override
  String get languageEnglish => 'انگلیسی';

  @override
  String get languageItalian => 'ایتالیایی';

  @override
  String get languagePersian => 'فارسی';

  @override
  String get sessionHeadline =>
      'بازخورد سازنده، بدون مشخص شدن اینکه چه کسی چه گفته است.';

  @override
  String get sessionDescription =>
      'این نسخهٔ آزمایشی یک نشست خصوصی موقت روی این دستگاه ایجاد می‌کند. بازیابی حساب و ورود پایدار بعداً اضافه خواهد شد.';

  @override
  String get startPrivateSession => 'شروع نشست خصوصی';

  @override
  String get myGroups => 'گروه‌های من';

  @override
  String get temporarySessionIdentity => 'هویت موقت نشست';

  @override
  String get refresh => 'به‌روزرسانی';

  @override
  String get noAssessmentsYet => 'هنوز گروهی وجود ندارد';

  @override
  String get noAssessmentsMessage =>
      'برای شروع، یک گروه بسازید یا به یک گروه موجود بپیوندید.';

  @override
  String get join => 'پیوستن';

  @override
  String get create => 'ایجاد';

  @override
  String get createGroup => 'ایجاد گروه';

  @override
  String get groupName => 'نام گروه';

  @override
  String get joinGroup => 'پیوستن به گروه';

  @override
  String get joinCode => 'کد پیوستن';

  @override
  String get saveJoinCode => 'این کد پیوستن را ذخیره کنید';

  @override
  String get joinCodeShareHint =>
      'این کد را فقط با افرادی به اشتراک بگذارید که می‌خواهید عضو گروه باشند. API بعداً این کد را دوباره نمایش نمی‌دهد.';

  @override
  String get copyCode => 'کپی کد';

  @override
  String get joinCodeCopied => 'کد پیوستن کپی شد';

  @override
  String get iSavedIt => 'ذخیره کردم';

  @override
  String get cancel => 'لغو';

  @override
  String get groupHealthHistory => 'تاریخچه سلامت گروه';

  @override
  String get questionnaires => 'پرسش‌نامه‌ها';

  @override
  String get noFeedbackRounds => 'هنوز دور بازخوردی وجود ندارد';

  @override
  String get noFeedbackRoundsMessage =>
      'برای شروع، درباره خودتان درخواست بازخورد ایجاد کنید.';

  @override
  String get groupHealthAssessment => 'ارزیابی سلامت گروه';

  @override
  String get yourFeedbackRound => 'دور بازخورد شما';

  @override
  String get groupMemberFeedback => 'بازخورد درباره عضو گروه';

  @override
  String get assessGroupHealth => 'ارزیابی سلامت گروه';

  @override
  String get requestFeedback => 'درخواست بازخورد';

  @override
  String get statusDraft => 'پیش‌نویس';

  @override
  String get statusOpen => 'باز';

  @override
  String get statusClosed => 'بسته';

  @override
  String get statusExpired => 'منقضی‌شده';

  @override
  String get statusClosedNoResults => 'بسته‌شده بدون نتیجه';

  @override
  String roundListSubtitle(String status, int minResponses) {
    return '$status · حداقل $minResponses پاسخ';
  }

  @override
  String get groupHealth => 'سلامت گروه';

  @override
  String get feedbackRound => 'دور بازخورد';

  @override
  String get questions => 'پرسش‌ها';

  @override
  String get oneHour => '۱ ساعت';

  @override
  String get sixHours => '۶ ساعت';

  @override
  String get twentyFourHoursRecommended => '۲۴ ساعت · پیشنهادشده';

  @override
  String get threeDays => '۳ روز';

  @override
  String get sevenDays => '۷ روز';

  @override
  String get responseWindowQuestion =>
      'افراد چه مدت برای پاسخ‌دادن فرصت داشته باشند؟';

  @override
  String get extendResponsePeriodBy => 'تمدید زمان پاسخ‌گویی به مدت';

  @override
  String get endWithoutResultsTitle => 'بدون نتیجه پایان یابد؟';

  @override
  String get endWithoutResultsExplanation =>
      'حد نصاب حریم خصوصی به دست نیامده است. با این کار دور برای همیشه پایان می‌یابد و نتایج ناقص نمایش داده نمی‌شوند.';

  @override
  String get endWithoutResults => 'پایان بدون نتیجه';

  @override
  String get closeGroupHealthTitle => 'ارزیابی سلامت گروه بسته شود؟';

  @override
  String get closeFeedbackRoundTitle => 'دور بازخورد بسته شود؟';

  @override
  String get closeGroupHealthExplanation =>
      'حد نصاب حریم خصوصی به دست آمده است. پس از بستن، دیگر پاسخی برای ارزیابی سلامت گروه پذیرفته نمی‌شود.';

  @override
  String get closeFeedbackRoundExplanation =>
      'حد نصاب حریم خصوصی به دست آمده است. پس از بستن، دیگر بازخوردی پذیرفته نمی‌شود.';

  @override
  String get closeAssessment => 'بستن ارزیابی';

  @override
  String get closeRound => 'بستن دور';

  @override
  String get feedbackSubmittedAnonymously => 'بازخورد به‌صورت ناشناس ارسال شد.';

  @override
  String get assessmentNotOpened => 'این ارزیابی هنوز باز نشده است.';

  @override
  String get openGroupHealthAssessment => 'باز کردن ارزیابی سلامت گروه';

  @override
  String get openRound => 'باز کردن دور';

  @override
  String openingGroupHealthRequirement(int minResponses) {
    return 'برای باز کردن، در مجموع حداقل $minResponses عضو واجد شرایط گروه لازم است.';
  }

  @override
  String openingFeedbackRequirement(int minResponses) {
    return 'برای باز کردن، حداقل $minResponses عضو واجد شرایط دیگر گروه لازم است.';
  }

  @override
  String get answerAnonymously => 'پاسخ ناشناس';

  @override
  String get groupHealthEligibilityPrivacy =>
      'هویت شما فقط برای بررسی واجد شرایط بودن و صدور یک اعتبار پاسخ استفاده می‌شود. پاسخ‌های ارسال‌شده شامل هویت نشست شما نیستند.';

  @override
  String get feedbackEligibilityPrivacy =>
      'هویت شما برای بررسی واجد شرایط بودن و صدور یک اعتبار پاسخ استفاده می‌شود. خودِ ارسال بازخورد، توکن نشست شما را ارسال نمی‌کند.';

  @override
  String get closingAfterThreshold =>
      'پس از رسیدن به حد نصاب حریم خصوصی، امکان بستن فعال می‌شود.';

  @override
  String get extendResponsePeriod => 'تمدید زمان پاسخ‌گویی';

  @override
  String get deadlinePassedPartialHidden =>
      'مهلت پیش از رسیدن به حد نصاب حریم خصوصی پایان یافت. نتایج ناقص همچنان مخفی می‌مانند.';

  @override
  String get deadlinePassedCreatorAction =>
      'مهلت پیش از دریافت تعداد کافی پاسخ پایان یافت. سازنده دور می‌تواند آن را تمدید کند یا بدون نتیجه پایان دهد.';

  @override
  String get viewAggregatedResults => 'مشاهده نتایج تجمیعی';

  @override
  String get closedWithoutResultsMessage =>
      'این دور بدون نتیجه پایان یافت زیرا حد نصاب حریم خصوصی به دست نیامد.';

  @override
  String get roundNotAcceptingResponses =>
      'این دور در حال حاضر پاسخ جدید نمی‌پذیرد.';

  @override
  String get roundLifecycle => 'چرخه دور';

  @override
  String get responseDeadlineNotSet => 'مهلت پاسخ‌گویی: هنوز تعیین نشده';

  @override
  String responseDeadline(String value) {
    return 'مهلت پاسخ‌گویی: $value';
  }

  @override
  String get deadlineReached => 'مهلت پایان یافته است';

  @override
  String timeRemainingDays(int days, int hours) {
    return 'زمان باقی‌مانده: $days روز و $hours ساعت';
  }

  @override
  String timeRemainingHours(int hours, int minutes) {
    return 'زمان باقی‌مانده: $hours ساعت و $minutes دقیقه';
  }

  @override
  String timeRemainingMinutes(int minutes) {
    return 'زمان باقی‌مانده: $minutes دقیقه';
  }

  @override
  String responsesReceived(int count) {
    return 'پاسخ‌های دریافت‌شده: $count';
  }

  @override
  String minimumRequired(int count) {
    return 'حداقل لازم: $count';
  }

  @override
  String get privacyThresholdReached => 'حد نصاب حریم خصوصی به دست آمده است.';

  @override
  String get privacyThresholdNotReached =>
      'حد نصاب حریم خصوصی هنوز به دست نیامده است.';

  @override
  String get anonymousCountOnly =>
      'فقط تعداد پاسخ‌های ناشناس نمایش داده می‌شود و هویت پاسخ‌دهندگان آشکار نمی‌شود.';

  @override
  String get anonymousGroupAssessment => 'ارزیابی ناشناس گروه';

  @override
  String get anonymousFeedback => 'بازخورد ناشناس';

  @override
  String get feedbackPrivacyNote =>
      'روی رفتارهای قابل مشاهده تمرکز کنید. در پاسخ‌های متنی نام یا اطلاعات شناسایی‌کننده وارد نکنید.';

  @override
  String get chooseScore => 'یک امتیاز انتخاب کنید';

  @override
  String get chooseOption => 'یک گزینه انتخاب کنید';

  @override
  String get chooseAtLeastOneOption => 'حداقل یک گزینه انتخاب کنید';

  @override
  String get enterResponse => 'پاسخ را وارد کنید';

  @override
  String unsupportedQuestionType(String kind) {
    return 'نوع پرسش پشتیبانی نمی‌شود: $kind';
  }

  @override
  String get submitPrivately => 'ارسال خصوصی';

  @override
  String get yourFeedbackRequest => 'درخواست بازخورد شما';

  @override
  String get anonymousFeedbackRequest => 'درخواست بازخورد ناشناس';

  @override
  String statusValue(String status) {
    return 'وضعیت: $status';
  }

  @override
  String privacyThresholdResponses(int count) {
    return 'حد نصاب حریم خصوصی: $count پاسخ';
  }

  @override
  String get creatorCanParticipate =>
      'شما این ارزیابی را ایجاد کرده‌اید و می‌توانید به‌صورت ناشناس نیز شرکت کنید.';

  @override
  String get eligibleMembersCanParticipate =>
      'اعضای واجد شرایط گروه می‌توانند به‌صورت ناشناس شرکت کنند.';

  @override
  String ratingRange(int min, int max) {
    return 'امتیازدهی $min تا $max';
  }

  @override
  String singleChoiceOptions(int count) {
    return 'تک‌گزینه‌ای · $count گزینه';
  }

  @override
  String multipleChoiceOptions(int count) {
    return 'چندگزینه‌ای · $count گزینه';
  }

  @override
  String get requiredShortText => 'متن کوتاه الزامی';

  @override
  String get optionalShortText => 'متن کوتاه اختیاری';

  @override
  String get requiredLongText => 'متن بلند الزامی';

  @override
  String get optionalLongText => 'متن بلند اختیاری';

  @override
  String get informationOnly => 'فقط اطلاعاتی';

  @override
  String get coreFeedbackName => 'بازخورد سازنده پایه';

  @override
  String get coreFeedbackDescription =>
      'پرسش‌نامه داخلی برای بازخورد سازنده و بهبود فردی.';

  @override
  String get coreFeedbackCommunication =>
      'شفاف و صادقانه ارتباط برقرار می‌کند.';

  @override
  String get coreFeedbackListening =>
      'با دقت گوش می‌دهد و باعث می‌شود دیگران احساس کنند شنیده می‌شوند.';

  @override
  String get coreFeedbackReliability =>
      'به تعهدات خود عمل می‌کند و می‌توان روی او حساب کرد.';

  @override
  String get coreFeedbackEmpathy =>
      'همدلی نشان می‌دهد و احساسات دیگران را در نظر می‌گیرد.';

  @override
  String get coreFeedbackBoundaries =>
      'به مرزهای شخصی و تفاوت‌ها احترام می‌گذارد.';

  @override
  String get coreFeedbackConflict =>
      'اختلاف‌نظر را بدون تحقیر، تهدید یا تشدید غیرضروری مدیریت می‌کند.';

  @override
  String get coreFeedbackSupportiveness =>
      'بدون ایجاد فشار، طرد یا وابستگی ناسالم از دیگران حمایت می‌کند.';

  @override
  String get coreFeedbackImprovement =>
      'چه کاری را می‌توانم متفاوت انجام دهم تا تعاملاتمان بهتر شود؟ از نام یا اطلاعات شناسایی‌کننده استفاده نکنید.';

  @override
  String get coreGroupHealthName => 'سلامت گروه';

  @override
  String get coreGroupHealthDescription =>
      'پرسش‌نامه ناشناس داخلی برای ارزیابی پویایی و روابط گروه.';

  @override
  String get coreGroupHealthCommunication =>
      'افراد این گروه موضوعات مهم را شفاف و صادقانه با یکدیگر در میان می‌گذارند.';

  @override
  String get coreGroupHealthListening =>
      'افراد به یکدیگر گوش می‌دهند و دیدگاه‌های متفاوت می‌توانند بیان شوند.';

  @override
  String get coreGroupHealthSafety =>
      'افراد می‌توانند بدون تمسخر، تهدید یا تلافی با یکدیگر مخالفت کنند.';

  @override
  String get coreGroupHealthReliability =>
      'افراد معمولاً به تعهدات خود نسبت به گروه عمل می‌کنند.';

  @override
  String get coreGroupHealthSupport =>
      'افراد زمانی که به‌طور منطقی نیاز باشد به یکدیگر کمک می‌کنند.';

  @override
  String get coreGroupHealthConflict =>
      'مشکلات و اختلاف‌نظرها به‌صورت سازنده مدیریت می‌شوند.';

  @override
  String get coreGroupHealthBoundaries =>
      'به مرزهای شخصی و تفاوت‌ها احترام گذاشته می‌شود.';

  @override
  String get coreGroupHealthImprovement =>
      'این گروه چه چیزی را می‌تواند بهتر کند؟ از نام یا اطلاعات شناسایی‌کننده استفاده نکنید.';

  @override
  String get aggregatedResults => 'نتایج تجمیعی';

  @override
  String get resultsNotAvailable => 'نتایج در دسترس نیست';

  @override
  String responseCount(int count) {
    return '$count پاسخ';
  }

  @override
  String get aggregatedResultsPrivacy =>
      'نتایج فقط پس از رسیدن به حد نصاب حریم خصوصی و به‌صورت تجمیعی نمایش داده می‌شوند.';

  @override
  String get noAnswers => 'بدون پاسخ';

  @override
  String averageValue(String value) {
    return 'میانگین $value';
  }

  @override
  String get noCommentsSubmitted => 'هیچ نظری ارسال نشده است.';

  @override
  String get historyUnavailable => 'تاریخچه در دسترس نیست';

  @override
  String get noHistoryYet => 'هنوز تاریخچه‌ای وجود ندارد';

  @override
  String get noHistoryMessage =>
      'برای ایجاد تاریخچه، یک ارزیابی سلامت گروه را تکمیل کنید.';

  @override
  String get groupHealthHistoryExplanation =>
      'هر مورد نشان‌دهنده پاسخ‌های تجمیعی یک ارزیابی بسته‌شده است که به حد نصاب حریم خصوصی رسیده است. تغییرات ممکن است هم بازتاب برداشت افراد و هم تغییر اعضای گروه باشند. هیچ امتیاز کلی برای سلامت گروه محاسبه نمی‌شود.';

  @override
  String aggregatedResponseCount(int count) {
    return '$count پاسخ تجمیعی';
  }

  @override
  String get noChange => 'بدون تغییر';

  @override
  String versusPrevious(String value) {
    return '$value نسبت به دوره قبل';
  }

  @override
  String get playfulReflection => 'برداشت دوستانه';

  @override
  String get playfulDisclaimer =>
      'یک خلاصه سرگرم‌کننده از بازخوردهای تجمیعی است — نه ارزیابی شخصیت.';

  @override
  String get thoughtfulOwl => 'جغد اندیشمند';

  @override
  String get helpingOctopus => 'اختاپوس یاری‌رسان';

  @override
  String get clearSignalFox => 'روباه شفاف';

  @override
  String get steadyTurtle => 'لاک‌پشت قابل‌اعتماد';

  @override
  String get respectfulHedgehog => 'جوجه‌تیغی محترم';

  @override
  String get calmElephant => 'فیل آرام';

  @override
  String get balancedCapybara => 'کاپیبارای متعادل';

  @override
  String get balancedPlayfulMessage =>
      'قوی‌ترین نشانه‌ها به یکدیگر نزدیک‌اند، بنابراین در این دور هیچ بُعد مشخصی به‌طور واضح برجسته نیست.';

  @override
  String personalPlayfulMessage(String prompt, String average) {
    return 'قوی‌ترین نشانه تجمیعی شما «$prompt» بود ($average/۵).';
  }

  @override
  String groupPlayfulMessage(String prompt, String average) {
    return 'قوی‌ترین نشانه تجمیعی گروه «$prompt» بود ($average/۵).';
  }

  @override
  String get newQuestionnaire => 'پرسش‌نامه جدید';

  @override
  String get questionnairePrivacyNote =>
      'نکته حریم خصوصی: از پاسخ‌دهندگان نام، حروف اول نام، نشانی، تاریخ تولد یا اطلاعات شناسایی‌کننده دیگر نخواهید. ذخیره‌سازی ناشناس نمی‌تواند مانع شود که فرد در متن پاسخ خودش را معرفی کند.';

  @override
  String get somethingWentWrong => 'مشکلی پیش آمد.';

  @override
  String get couldNotSaveQuestionnaire => 'ذخیره پرسش‌نامه ممکن نشد.';

  @override
  String get builtIn => 'داخلی';

  @override
  String get statusPublished => 'منتشرشده';

  @override
  String versionBlocks(int version, int count) {
    return 'نسخه $version · $count بلوک';
  }

  @override
  String get view => 'مشاهده';

  @override
  String get editDraft => 'ویرایش پیش‌نویس';

  @override
  String get publish => 'انتشار';

  @override
  String get newVersion => 'نسخه جدید';

  @override
  String get editorPrivacyNote =>
      'از پرسش‌هایی که اطلاعات شناسایی‌کننده درخواست می‌کنند خودداری کنید. رفتارهای قابل مشاهده و گزینه‌های محدود را به متن آزادِ قابل شناسایی ترجیح دهید.';

  @override
  String get questionnaireTitle => 'عنوان پرسش‌نامه';

  @override
  String get questionnaireTitleExample => 'مثال: ارتباط و همکاری تیمی';

  @override
  String get enterTitle => 'یک عنوان وارد کنید';

  @override
  String get descriptionInstructionsOptional => 'توضیحات / راهنما (اختیاری)';

  @override
  String get descriptionExample =>
      'مثال: به نحوه همکاری ما در ماه گذشته فکر کنید.';

  @override
  String get addBlock => 'افزودن بلوک';

  @override
  String get saveDraft => 'ذخیره پیش‌نویس';

  @override
  String blockNumber(int number) {
    return 'بلوک $number';
  }

  @override
  String get type => 'نوع';

  @override
  String get ratingScale => 'مقیاس امتیازدهی';

  @override
  String get singleChoice => 'تک‌گزینه‌ای';

  @override
  String get multipleChoice => 'چندگزینه‌ای';

  @override
  String get shortText => 'متن کوتاه';

  @override
  String get longText => 'متن بلند';

  @override
  String get descriptionInformation => 'توضیح / اطلاعات';

  @override
  String get scaleHelper =>
      'مقیاس امتیازدهی: برای الگوهای قابل اندازه‌گیری مانند شفافیت ارتباط مناسب است.';

  @override
  String get singleChoiceHelper =>
      'تک‌گزینه‌ای: پاسخ‌دهنده دقیقاً یک گزینه را انتخاب می‌کند.';

  @override
  String get multipleChoiceHelper =>
      'چندگزینه‌ای: پاسخ‌دهنده می‌تواند چند گزینه را انتخاب کند.';

  @override
  String get shortTextHelper => 'متن کوتاه: مناسب یک مشاهده یا پیشنهاد مختصر.';

  @override
  String get longTextHelper =>
      'متن بلند: زمانی مناسب است که پاسخ سازنده و دقیق‌تری لازم باشد.';

  @override
  String get descriptionHelper =>
      'فقط اطلاعاتی: به پاسخ‌دهنده نمایش داده می‌شود و پاسخی دریافت نمی‌کند.';

  @override
  String get informationText => 'متن اطلاعاتی';

  @override
  String get question => 'پرسش';

  @override
  String get informationTextExample =>
      'مثال: پیش از پاسخ دادن به پرسش‌های بعدی این متن را بخوانید.';

  @override
  String get questionBehaviorHelper =>
      'پرسش را درباره رفتار قابل مشاهده نگه دارید، نه شخصیت یا هویت.';

  @override
  String get blockCannotBeBlank => 'این بلوک نمی‌تواند خالی باشد';

  @override
  String get required => 'الزامی';

  @override
  String get minimum => 'حداقل';

  @override
  String get maximum => 'حداکثر';

  @override
  String get maxMustExceedMin => 'حداکثر باید بیشتر از حداقل باشد';

  @override
  String get optionsOnePerLine => 'گزینه‌ها (هر گزینه در یک خط)';

  @override
  String get optionsExample => 'مثال: به‌ندرت\nگاهی\nاغلب';

  @override
  String get addAtLeastTwoOptions => 'حداقل دو گزینه اضافه کنید';

  @override
  String get optionOne => 'گزینه ۱';

  @override
  String get optionTwo => 'گزینه ۲';

  @override
  String get groupRoleOwner => 'مالک';

  @override
  String get groupRoleMember => 'عضو';

  @override
  String get chooseQuestionnaire => 'انتخاب پرسش‌نامه';

  @override
  String get noPublishedQuestionnaires =>
      'هیچ پرسش‌نامه منتشرشده‌ای در دسترس نیست.';

  @override
  String get somethingWentWrongTryAgain => 'مشکلی پیش آمد. دوباره تلاش کنید.';
}
