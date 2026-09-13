import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:privacy_feedback_app/l10n/builtin_content.dart';
import 'package:privacy_feedback_app/l10n/generated/app_localizations.dart';
import 'package:privacy_feedback_app/l10n/locale_preference.dart';
import 'package:privacy_feedback_app/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('generated localizations support English Italian and Persian', () {
    final codes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();

    expect(codes, {'en', 'it', 'fa'});
  });

  test('manual locale preference persists and automatic clears it', () async {
    await LocalePreference.save(const Locale('fa'));

    final stored = await LocalePreference.load();

    expect(stored?.languageCode, 'fa');

    await LocalePreference.save(null);

    expect(await LocalePreference.load(), isNull);
  });

  test(
    'built-in content is localized but custom content is preserved',
    () async {
      final italian = await AppLocalizations.delegate.load(const Locale('it'));

      const builtIn = QuestionnaireSummary(
        id: 'built-in',
        slug: coreFeedbackQuestionnaireSlug,
        name: 'Server-side English name',
        description: 'Server-side English description',
        version: 1,
        status: 'published',
        questions: [],
      );

      const custom = QuestionnaireSummary(
        id: 'custom',
        groupId: 'group-1',
        createdByUserId: 'user-1',
        slug: 'custom-questionnaire',
        name: 'Autore - titolo originale',
        description: 'Testo scritto dall autore',
        version: 1,
        status: 'published',
        questions: [],
      );

      expect(
        localizedQuestionnaireName(italian, builtIn),
        italian.coreFeedbackName,
      );

      expect(
        localizedQuestionnaireDescription(italian, builtIn),
        italian.coreFeedbackDescription,
      );

      expect(localizedQuestionnaireName(italian, custom), custom.name);

      expect(
        localizedQuestionnaireDescription(italian, custom),
        custom.description,
      );

      expect(
        localizedBuiltInQuestionPrompt(
          italian,
          coreFeedbackQuestionnaireSlug,
          'communication',
          'fallback',
        ),
        italian.coreFeedbackCommunication,
      );

      expect(
        localizedBuiltInQuestionPrompt(
          italian,
          custom.slug,
          'communication',
          'Author supplied prompt',
        ),
        'Author supplied prompt',
      );
    },
  );

  testWidgets('Persian locale renders with RTL directionality', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('fa'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Text(
                AppLocalizations.of(context).startPrivateSession,
                key: const Key('localized-text'),
              ),
            );
          },
        ),
      ),
    );

    await tester.pumpAndSettle();

    final finder = find.byKey(const Key('localized-text'));

    expect(finder, findsOneWidget);

    final context = tester.element(finder);

    expect(Directionality.of(context), TextDirection.rtl);

    final text = tester.widget<Text>(finder);

    expect(text.data, 'شروع نشست خصوصی');
  });
}
