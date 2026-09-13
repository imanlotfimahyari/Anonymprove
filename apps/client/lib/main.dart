import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'l10n/builtin_content.dart';
import 'l10n/generated/app_localizations.dart';
import 'l10n/locale_preference.dart';

import 'api/api_client.dart';
import 'models/models.dart';
import 'questionnaires/questionnaire_pages.dart';
import 'results/playful_mascot.dart';
import 'results/playful_result.dart';

const _defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

void main() {
  runApp(FeedbackApp(api: HttpAnonymproveApi(baseUrl: _defaultApiBaseUrl)));
}

class FeedbackApp extends StatefulWidget {
  const FeedbackApp({required this.api, super.key});

  final AnonymproveApi api;

  @override
  State<FeedbackApp> createState() => _FeedbackAppState();
}

class _FeedbackAppState extends State<FeedbackApp> {
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await LocalePreference.load();

    if (!mounted) {
      return;
    }

    setState(() => _locale = locale);
  }

  Future<void> _changeLocale(Locale? locale) async {
    await LocalePreference.save(locale);

    if (!mounted) {
      return;
    }

    setState(() => _locale = locale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: SessionPage(
        api: widget.api,
        locale: _locale,
        onLocaleChanged: _changeLocale,
      ),
    );
  }
}

class SessionPage extends StatefulWidget {
  const SessionPage({
    required this.api,
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final AnonymproveApi api;
  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<SessionPage> createState() => _SessionPageState();
}

class _SessionPageState extends State<SessionPage> {
  SessionInfo? _session;
  bool _starting = false;

  Future<void> _startSession() async {
    setState(() => _starting = true);
    try {
      final session = await widget.api.createSession();
      if (!mounted) {
        return;
      }
      setState(() => _session = session);
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = _session;
    if (session != null) {
      return GroupsPage(
        api: widget.api,
        session: session,
        locale: widget.locale,
        onLocaleChanged: widget.onLocaleChanged,
      );
    }

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          _LanguageButton(
            locale: widget.locale,
            onChanged: widget.onLocaleChanged,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, size: 56),
                const SizedBox(height: 16),
                Text(
                  l10n.sessionHeadline,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(l10n.sessionDescription, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _starting ? null : _startSession,
                  icon: _starting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: Text(l10n.startPrivateSession),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GroupsPage extends StatefulWidget {
  const GroupsPage({
    required this.api,
    required this.session,
    required this.locale,
    required this.onLocaleChanged,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final Locale? locale;
  final ValueChanged<Locale?> onLocaleChanged;

  @override
  State<GroupsPage> createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  List<GroupSummary> _groups = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final groups = await widget.api.listGroups(widget.session.sessionToken);
      if (mounted) {
        setState(() => _groups = groups);
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createGroup() async {
    final l10n = AppLocalizations.of(context);

    final name = await _textDialog(
      context,
      title: l10n.createGroup,
      label: l10n.groupName,
      actionLabel: l10n.create,
    );
    if (name == null || !mounted) {
      return;
    }

    try {
      final group = await widget.api.createGroup(
        widget.session.sessionToken,
        name,
      );
      if (!mounted) {
        return;
      }
      await _showJoinCode(group);
      if (mounted) {
        await _reload();
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    }
  }

  Future<void> _joinGroup() async {
    final l10n = AppLocalizations.of(context);

    final code = await _textDialog(
      context,
      title: l10n.joinGroup,
      label: l10n.joinCode,
      actionLabel: l10n.join,
    );
    if (code == null || !mounted) {
      return;
    }

    try {
      await widget.api.joinGroup(widget.session.sessionToken, code);
      if (mounted) {
        await _reload();
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    }
  }

  Future<void> _showJoinCode(GroupSummary group) async {
    final joinCode = group.joinCode;
    if (joinCode == null) {
      return;
    }
    final l10n = AppLocalizations.of(context);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.saveJoinCode),
        content: SelectableText('$joinCode\n\n${l10n.joinCodeShareHint}'),
        actions: [
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: joinCode));
              if (!mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.joinCodeCopied)));
            },
            icon: const Icon(Icons.copy_outlined),
            label: Text(l10n.copyCode),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.iSavedIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myGroups),
        actions: [
          _LanguageButton(
            locale: widget.locale,
            onChanged: widget.onLocaleChanged,
          ),
          IconButton(
            onPressed: _loading ? null : _reload,
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Material(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: Text(widget.session.alias),
              subtitle: Text(l10n.temporarySessionIdentity),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                ? _EmptyState(
                    icon: Icons.forum_outlined,
                    title: l10n.noAssessmentsYet,
                    message: l10n.noAssessmentsMessage,
                  )
                : RefreshIndicator(
                    onRefresh: _reload,
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _groups.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final group = _groups[index];
                        return Card(
                          child: ListTile(
                            leading: const Icon(Icons.groups_outlined),
                            title: Text(group.name),
                            subtitle: Text(_groupRoleLabel(l10n, group.role)),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () async {
                              await Navigator.of(context).push<void>(
                                MaterialPageRoute(
                                  builder: (_) => GroupPage(
                                    api: widget.api,
                                    session: widget.session,
                                    group: group,
                                  ),
                                ),
                              );
                              if (mounted) {
                                await _reload();
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Wrap(
        spacing: 12,
        children: [
          FloatingActionButton.extended(
            heroTag: 'join-group',
            onPressed: _joinGroup,
            icon: const Icon(Icons.group_add_outlined),
            label: Text(l10n.join),
          ),
          FloatingActionButton.extended(
            heroTag: 'create-group',
            onPressed: _createGroup,
            icon: const Icon(Icons.add),
            label: Text(l10n.create),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  const _LanguageButton({required this.locale, required this.onChanged});

  static const _automatic = '__automatic__';

  final Locale? locale;
  final ValueChanged<Locale?> onChanged;

  Future<void> _select(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final currentValue = locale?.languageCode ?? _automatic;

    final selected = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.language),
        children: [
          RadioGroup<String>(
            groupValue: currentValue,
            onChanged: (value) {
              if (value != null) {
                Navigator.pop(context, value);
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  value: _automatic,
                  title: Text(l10n.languageAutomatic),
                ),
                RadioListTile<String>(
                  value: 'en',
                  title: Text(l10n.languageEnglish),
                ),
                RadioListTile<String>(
                  value: 'it',
                  title: Text(l10n.languageItalian),
                ),
                RadioListTile<String>(
                  value: 'fa',
                  title: Text(l10n.languagePersian),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (selected == null) {
      return;
    }

    if (selected == _automatic) {
      onChanged(null);
      return;
    }

    onChanged(Locale(selected));
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: AppLocalizations.of(context).language,
      onPressed: () => _select(context),
      icon: const Icon(Icons.language_outlined),
    );
  }
}

String _groupRoleLabel(AppLocalizations l10n, String role) {
  return switch (role) {
    'owner' => l10n.groupRoleOwner,
    'member' => l10n.groupRoleMember,
    _ => role,
  };
}

String _roundStatusLabel(AppLocalizations l10n, String status) {
  return switch (status) {
    'draft' => l10n.statusDraft,
    'open' => l10n.statusOpen,
    'closed' => l10n.statusClosed,
    'expired' => l10n.statusExpired,
    'closed_no_results' => l10n.statusClosedNoResults,
    _ => status,
  };
}

class GroupPage extends StatefulWidget {
  const GroupPage({
    required this.api,
    required this.session,
    required this.group,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final GroupSummary group;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  List<FeedbackRoundSummary> _rounds = const [];
  bool _loading = true;
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final rounds = await widget.api.listFeedbackRounds(
        widget.session.sessionToken,
        widget.group.id,
      );
      if (mounted) {
        setState(() => _rounds = rounds);
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createFeedbackRound() async {
    setState(() => _creating = true);
    try {
      final questionnaires = await widget.api.listQuestionnaires(
        widget.session.sessionToken,
        widget.group.id,
      );
      if (!mounted) return;
      final published = questionnaires
          .where(
            (item) =>
                item.status == 'published' &&
                item.slug != 'core-group-health-v1',
          )
          .toList();
      final selected = await _selectQuestionnaireDialog(context, published);
      if (selected == null || !mounted) return;
      final round = await widget.api.createFeedbackRound(
        widget.session.sessionToken,
        widget.group.id,
        questionnaireId: selected.id,
        roundType: 'individual_feedback',
      );
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => RoundPage(
            api: widget.api,
            session: widget.session,
            roundId: round.id,
          ),
        ),
      );
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  Future<void> _createGroupHealthRound() async {
    setState(() => _creating = true);

    try {
      final round = await widget.api.createFeedbackRound(
        widget.session.sessionToken,
        widget.group.id,
        roundType: 'group_health',
      );

      if (!mounted) {
        return;
      }

      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => RoundPage(
            api: widget.api,
            session: widget.session,
            roundId: round.id,
          ),
        ),
      );

      if (mounted) {
        await _reload();
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _creating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            tooltip: l10n.groupHealthHistory,
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => GroupHealthHistoryPage(
                    api: widget.api,
                    session: widget.session,
                    group: widget.group,
                  ),
                ),
              );

              if (mounted) {
                await _reload();
              }
            },
            icon: const Icon(Icons.timeline_outlined),
          ),
          IconButton(
            tooltip: l10n.questionnaires,
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute(
                  builder: (_) => QuestionnairesPage(
                    api: widget.api,
                    session: widget.session,
                    group: widget.group,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.quiz_outlined),
          ),
          IconButton(
            onPressed: _loading ? null : _reload,
            tooltip: l10n.refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rounds.isEmpty
          ? _EmptyState(
              icon: Icons.forum_outlined,
              title: l10n.noFeedbackRounds,
              message: l10n.noFeedbackRoundsMessage,
            )
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _rounds.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final round = _rounds[index];
                  final isMine =
                      round.isIndividualFeedback &&
                      round.subjectUserId == widget.session.userId;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        round.isGroupHealth
                            ? Icons.monitor_heart_outlined
                            : isMine
                            ? Icons.person_outline
                            : Icons.feedback_outlined,
                      ),
                      title: Text(
                        round.isGroupHealth
                            ? l10n.groupHealthAssessment
                            : isMine
                            ? l10n.yourFeedbackRound
                            : l10n.groupMemberFeedback,
                      ),
                      subtitle: Text(
                        l10n.roundListSubtitle(
                          _roundStatusLabel(l10n, round.status),
                          round.minResponses,
                        ),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push<void>(
                          MaterialPageRoute(
                            builder: (_) => RoundPage(
                              api: widget.api,
                              session: widget.session,
                              roundId: round.id,
                            ),
                          ),
                        );
                        if (mounted) {
                          await _reload();
                        }
                      },
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: Wrap(
        spacing: 12,
        children: [
          FloatingActionButton.extended(
            heroTag: 'group-health',
            onPressed: _creating ? null : _createGroupHealthRound,
            icon: const Icon(Icons.monitor_heart_outlined),
            label: Text(l10n.assessGroupHealth),
          ),
          FloatingActionButton.extended(
            heroTag: 'request-feedback',
            onPressed: _creating ? null : _createFeedbackRound,
            icon: _creating
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.add_comment_outlined),
            label: Text(l10n.requestFeedback),
          ),
        ],
      ),
    );
  }
}

class RoundPage extends StatefulWidget {
  const RoundPage({
    required this.api,
    required this.session,
    required this.roundId,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final String roundId;

  @override
  State<RoundPage> createState() => _RoundPageState();
}

class _RoundPageState extends State<RoundPage> {
  FeedbackRoundDetail? _round;
  FeedbackRoundProgress? _progress;
  Timer? _refreshTimer;
  bool _loading = true;
  bool _changing = false;
  bool _refreshing = false;

  @override
  void initState() {
    super.initState();
    _reload();

    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _reload(showLoading: false),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _reload({bool showLoading = true}) async {
    if (_refreshing) return;

    _refreshing = true;

    if (showLoading && mounted) {
      setState(() => _loading = true);
    }

    try {
      final round = await widget.api.getFeedbackRound(
        widget.session.sessionToken,
        widget.roundId,
      );

      FeedbackRoundProgress? progress;

      if (round.createdByUserId == widget.session.userId) {
        progress = await widget.api.getFeedbackRoundProgress(
          widget.session.sessionToken,
          widget.roundId,
        );
      }

      if (mounted) {
        setState(() {
          _round = round;
          _progress = progress;
        });
      }
    } catch (error) {
      if (mounted && showLoading) {
        _showError(context, error);
      }
    } finally {
      _refreshing = false;

      if (mounted && showLoading) {
        setState(() => _loading = false);
      }
    }
  }

  Future<int?> _selectResponseWindow({required String title}) {
    final l10n = AppLocalizations.of(context);

    return showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 60),
            child: Text(l10n.oneHour),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 360),
            child: Text(l10n.sixHours),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 1440),
            child: Text(l10n.twentyFourHoursRecommended),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 4320),
            child: Text(l10n.threeDays),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, 10080),
            child: Text(l10n.sevenDays),
          ),
          const Divider(),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _openRound() async {
    final l10n = AppLocalizations.of(context);

    final minutes = await _selectResponseWindow(
      title: l10n.responseWindowQuestion,
    );

    if (minutes == null || !mounted) return;

    await _changeRound(() {
      return widget.api.openFeedbackRound(
        widget.session.sessionToken,
        widget.roundId,
        responseWindowMinutes: minutes,
      );
    });
  }

  Future<void> _extendRound() async {
    final l10n = AppLocalizations.of(context);

    final minutes = await _selectResponseWindow(
      title: l10n.extendResponsePeriodBy,
    );

    if (minutes == null || !mounted) return;

    await _changeRound(() {
      return widget.api.extendFeedbackRound(
        widget.session.sessionToken,
        widget.roundId,
        responseWindowMinutes: minutes,
      );
    });
  }

  Future<void> _endWithoutResults() async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.endWithoutResultsTitle),
        content: Text(l10n.endWithoutResultsExplanation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.endWithoutResults),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _changeRound(() {
      return widget.api.endFeedbackRoundWithoutResults(
        widget.session.sessionToken,
        widget.roundId,
      );
    });
  }

  Future<void> _closeRound() async {
    final l10n = AppLocalizations.of(context);
    final isGroupHealth = _round?.isGroupHealth == true;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isGroupHealth
              ? l10n.closeGroupHealthTitle
              : l10n.closeFeedbackRoundTitle,
        ),
        content: Text(
          isGroupHealth
              ? l10n.closeGroupHealthExplanation
              : l10n.closeFeedbackRoundExplanation,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(isGroupHealth ? l10n.closeAssessment : l10n.closeRound),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    await _changeRound(() {
      return widget.api.closeFeedbackRound(
        widget.session.sessionToken,
        widget.roundId,
      );
    });
  }

  Future<void> _changeRound(
    Future<FeedbackRoundSummary> Function() action,
  ) async {
    setState(() => _changing = true);

    try {
      await action();

      if (mounted) {
        await _reload(showLoading: false);
      }
    } catch (error) {
      if (mounted) {
        _showError(context, error);
      }
    } finally {
      if (mounted) {
        setState(() => _changing = false);
      }
    }
  }

  Future<void> _answer(FeedbackRoundDetail round) async {
    final submitted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => FeedbackFormPage(
          api: widget.api,
          session: widget.session,
          round: round,
        ),
      ),
    );

    if (submitted == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context).feedbackSubmittedAnonymously,
          ),
        ),
      );

      await _reload(showLoading: false);
    }
  }

  Future<void> _viewResults(FeedbackRoundDetail round) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ResultsPage(
          api: widget.api,
          session: widget.session,
          roundId: widget.roundId,
          questionnaireSlug: round.questionnaireSlug,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final round = _round;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          round?.isGroupHealth == true ? l10n.groupHealth : l10n.feedbackRound,
        ),
        actions: [
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _refreshing ? null : () => _reload(showLoading: false),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading || round == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RoundStatusCard(
                  round: round,
                  isSubject:
                      round.isIndividualFeedback &&
                      round.subjectUserId == widget.session.userId,
                  isCreator: round.createdByUserId == widget.session.userId,
                ),
                const SizedBox(height: 12),
                _RoundLifecycleCard(
                  round: round,
                  progress: _progress,
                  isCreator: round.createdByUserId == widget.session.userId,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.questions,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final question in round.questions)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${question.position}'),
                      ),
                      title: Text(
                        localizedBuiltInQuestionPrompt(
                          l10n,
                          round.questionnaireSlug,
                          question.key,
                          question.prompt,
                        ),
                      ),
                      subtitle: Text(_questionKindLabel(context, question)),
                    ),
                  ),
                const SizedBox(height: 24),
                ..._actionsFor(round),
              ],
            ),
    );
  }

  List<Widget> _actionsFor(FeedbackRoundDetail round) {
    final l10n = AppLocalizations.of(context);

    final isSubject =
        round.isIndividualFeedback &&
        round.subjectUserId == widget.session.userId;

    final isCreator = round.createdByUserId == widget.session.userId;

    if (round.status == 'draft') {
      if (!isCreator) {
        return [Text(l10n.assessmentNotOpened, textAlign: TextAlign.center)];
      }

      return [
        FilledButton.icon(
          onPressed: _changing ? null : _openRound,
          icon: const Icon(Icons.play_arrow),
          label: Text(
            round.isGroupHealth
                ? l10n.openGroupHealthAssessment
                : l10n.openRound,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          round.isGroupHealth
              ? l10n.openingGroupHealthRequirement(round.minResponses)
              : l10n.openingFeedbackRequirement(round.minResponses),
          textAlign: TextAlign.center,
        ),
      ];
    }

    if (round.status == 'open') {
      final thresholdMet = _progress?.thresholdMet == true;

      if (round.isGroupHealth) {
        return [
          FilledButton.icon(
            onPressed: () => _answer(round),
            icon: const Icon(Icons.edit_note),
            label: Text(l10n.answerAnonymously),
          ),
          const SizedBox(height: 8),
          Text(l10n.groupHealthEligibilityPrivacy, textAlign: TextAlign.center),
          if (isCreator) ...[
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
              onPressed: _changing || !thresholdMet ? null : _closeRound,
              icon: const Icon(Icons.stop_circle_outlined),
              label: Text(l10n.closeAssessment),
            ),
            if (!thresholdMet) ...[
              const SizedBox(height: 8),
              Text(l10n.closingAfterThreshold, textAlign: TextAlign.center),
            ],
          ],
        ];
      }

      if (isSubject) {
        return [
          FilledButton.tonalIcon(
            onPressed: _changing || !thresholdMet ? null : _closeRound,
            icon: const Icon(Icons.stop_circle_outlined),
            label: Text(l10n.closeRound),
          ),
          if (!thresholdMet) ...[
            const SizedBox(height: 8),
            Text(l10n.closingAfterThreshold, textAlign: TextAlign.center),
          ],
        ];
      }

      return [
        FilledButton.icon(
          onPressed: () => _answer(round),
          icon: const Icon(Icons.edit_note),
          label: Text(l10n.answerAnonymously),
        ),
        const SizedBox(height: 8),
        Text(l10n.feedbackEligibilityPrivacy, textAlign: TextAlign.center),
      ];
    }

    if (round.status == 'expired') {
      if (isCreator) {
        return [
          FilledButton.icon(
            onPressed: _changing ? null : _extendRound,
            icon: const Icon(Icons.update),
            label: Text(l10n.extendResponsePeriod),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _changing ? null : _endWithoutResults,
            icon: const Icon(Icons.block_outlined),
            label: Text(AppLocalizations.of(context).endWithoutResults),
          ),
          const SizedBox(height: 8),
          Text(l10n.deadlinePassedPartialHidden, textAlign: TextAlign.center),
        ];
      }

      return [
        Text(l10n.deadlinePassedCreatorAction, textAlign: TextAlign.center),
      ];
    }

    if (round.status == 'closed') {
      if (round.isGroupHealth || isSubject) {
        return [
          FilledButton.icon(
            onPressed: () => _viewResults(round),
            icon: const Icon(Icons.bar_chart),
            label: Text(l10n.viewAggregatedResults),
          ),
        ];
      }
    }

    if (round.status == 'closed_no_results') {
      return [
        Text(l10n.closedWithoutResultsMessage, textAlign: TextAlign.center),
      ];
    }

    return [Text(l10n.roundNotAcceptingResponses, textAlign: TextAlign.center)];
  }
}

class _RoundLifecycleCard extends StatelessWidget {
  const _RoundLifecycleCard({
    required this.round,
    required this.progress,
    required this.isCreator,
  });

  final FeedbackRoundDetail round;
  final FeedbackRoundProgress? progress;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final deadline = round.responseDeadlineAt;
    final progress = this.progress;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.roundLifecycle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (deadline == null)
              Text(l10n.responseDeadlineNotSet)
            else ...[
              Text(
                l10n.responseDeadline(_formatRoundDeadline(context, deadline)),
              ),
              if (round.status == 'open')
                Text(_remainingTimeLabel(context, deadline)),
            ],
            if (isCreator && progress != null) ...[
              const SizedBox(height: 8),
              Text(l10n.responsesReceived(progress.responseCount)),
              Text(l10n.minimumRequired(progress.minResponses)),
              const SizedBox(height: 4),
              Text(
                progress.thresholdMet
                    ? l10n.privacyThresholdReached
                    : l10n.privacyThresholdNotReached,
              ),
              const SizedBox(height: 4),
              Text(l10n.anonymousCountOnly),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatRoundDeadline(BuildContext context, DateTime deadline) {
  final local = deadline.toLocal();
  final material = MaterialLocalizations.of(context);

  final date = material.formatMediumDate(local);

  final time = material.formatTimeOfDay(
    TimeOfDay.fromDateTime(local),
    alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
  );

  return '$date $time';
}

String _remainingTimeLabel(BuildContext context, DateTime deadline) {
  final l10n = AppLocalizations.of(context);

  final remaining = deadline.toUtc().difference(DateTime.now().toUtc());

  if (remaining <= Duration.zero) {
    return l10n.deadlineReached;
  }

  if (remaining.inDays >= 1) {
    final hours = remaining.inHours.remainder(24);

    return l10n.timeRemainingDays(remaining.inDays, hours);
  }

  if (remaining.inHours >= 1) {
    final minutes = remaining.inMinutes.remainder(60);

    return l10n.timeRemainingHours(remaining.inHours, minutes);
  }

  return l10n.timeRemainingMinutes(remaining.inMinutes.clamp(1, 59));
}

class FeedbackFormPage extends StatefulWidget {
  const FeedbackFormPage({
    required this.api,
    required this.session,
    required this.round,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final FeedbackRoundDetail round;

  @override
  State<FeedbackFormPage> createState() => _FeedbackFormPageState();
}

class _FeedbackFormPageState extends State<FeedbackFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int> _scores = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Map<String, String> _singleChoices = {};
  final Map<String, Set<String>> _multipleChoices = {};
  bool _submitting = false;
  String? _responseToken;

  @override
  void initState() {
    super.initState();
    for (final question in widget.round.questions) {
      if (question.kind == 'text' ||
          question.kind == 'short_text' ||
          question.kind == 'long_text') {
        _textControllers[question.id] = TextEditingController();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final answers = <AnswerSubmission>[];
      for (final question in widget.round.questions) {
        switch (question.kind) {
          case 'description':
            continue;
          case 'scale':
            final score = _scores[question.id];
            if (score != null) {
              answers.add(
                AnswerSubmission(questionId: question.id, score: score),
              );
            }
            continue;
          case 'text':
          case 'short_text':
          case 'long_text':
            final text = _textControllers[question.id]?.text.trim() ?? '';
            if (text.isNotEmpty) {
              answers.add(
                AnswerSubmission(questionId: question.id, text: text),
              );
            }
            continue;
          case 'single_choice':
            final optionId = _singleChoices[question.id];
            if (optionId != null) {
              answers.add(
                AnswerSubmission(
                  questionId: question.id,
                  optionIds: [optionId],
                ),
              );
            }
            continue;
          case 'multiple_choice':
            final selected = _multipleChoices[question.id] ?? <String>{};
            if (selected.isNotEmpty) {
              answers.add(
                AnswerSubmission(
                  questionId: question.id,
                  optionIds: selected.toList(),
                ),
              );
            }
            continue;
        }
      }
      _responseToken ??= await widget.api.claimResponseCredential(
        widget.session.sessionToken,
        widget.round.id,
      );
      await widget.api.submitFeedback(
        widget.round.id,
        _responseToken!,
        answers,
      );
      _responseToken = null;
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showError(context, error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Widget _field(QuestionSummary question) {
    final l10n = AppLocalizations.of(context);
    final prompt = localizedBuiltInQuestionPrompt(
      l10n,
      widget.round.questionnaireSlug,
      question.key,
      question.prompt,
    );
    final label = '${question.position}. $prompt';
    switch (question.kind) {
      case 'description':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(prompt),
          ),
        );
      case 'scale':
        return DropdownButtonFormField<int>(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          initialValue: _scores[question.id],
          items: [
            for (
              var score = question.minScore ?? 1;
              score <= (question.maxScore ?? 5);
              score++
            )
              DropdownMenuItem(value: score, child: Text('$score')),
          ],
          onChanged: _submitting
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => _scores[question.id] = value);
                  }
                },
          validator: (value) =>
              question.required && value == null ? l10n.chooseScore : null,
        );
      case 'single_choice':
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          initialValue: _singleChoices[question.id],
          items: question.options
              .map(
                (option) => DropdownMenuItem(
                  value: option.id,
                  child: Text(option.label),
                ),
              )
              .toList(),
          onChanged: _submitting
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => _singleChoices[question.id] = value);
                  }
                },
          validator: (value) =>
              question.required && value == null ? l10n.chooseOption : null,
        );
      case 'multiple_choice':
        return FormField<Set<String>>(
          initialValue: _multipleChoices[question.id] ?? <String>{},
          validator: (value) =>
              question.required && (value == null || value.isEmpty)
              ? l10n.chooseAtLeastOneOption
              : null,
          builder: (field) {
            final selected = field.value ?? <String>{};
            return InputDecorator(
              decoration: InputDecoration(
                labelText: label,
                border: const OutlineInputBorder(),
                errorText: field.errorText,
              ),
              child: Column(
                children: [
                  for (final option in question.options)
                    CheckboxListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: Text(option.label),
                      value: selected.contains(option.id),
                      onChanged: _submitting
                          ? null
                          : (checked) {
                              final next = <String>{...selected};
                              if (checked == true) {
                                next.add(option.id);
                              } else {
                                next.remove(option.id);
                              }
                              _multipleChoices[question.id] = next;
                              field.didChange(next);
                              setState(() {});
                            },
                    ),
                ],
              ),
            );
          },
        );
      case 'short_text':
      case 'long_text':
      case 'text':
        final short = question.kind == 'short_text';
        return TextFormField(
          controller: _textControllers[question.id],
          enabled: !_submitting,
          maxLength: short ? 200 : 1000,
          maxLines: short ? 2 : 5,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          validator: (value) =>
              question.required && (value ?? '').trim().isEmpty
              ? l10n.enterResponse
              : null,
        );
      default:
        return Text(l10n.unsupportedQuestionType(question.kind));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.round.isGroupHealth
              ? l10n.anonymousGroupAssessment
              : l10n.anonymousFeedback,
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.feedbackPrivacyNote),
              ),
            ),
            const SizedBox(height: 8),
            for (final question in widget.round.questions) ...[
              _field(question),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(l10n.submitPrivately),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultsPage extends StatefulWidget {
  const ResultsPage({
    required this.api,
    required this.session,
    required this.roundId,
    required this.questionnaireSlug,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final String roundId;
  final String questionnaireSlug;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class GroupHealthHistoryPage extends StatefulWidget {
  const GroupHealthHistoryPage({
    required this.api,
    required this.session,
    required this.group,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final GroupSummary group;

  @override
  State<GroupHealthHistoryPage> createState() => _GroupHealthHistoryPageState();
}

class _GroupHealthHistoryPageState extends State<GroupHealthHistoryPage> {
  List<_GroupHealthSnapshot>? _snapshots;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rounds = await widget.api.listFeedbackRounds(
        widget.session.sessionToken,
        widget.group.id,
      );

      final closedRounds =
          rounds
              .where((round) => round.isGroupHealth && round.status == 'closed')
              .toList()
            ..sort((a, b) => _roundDate(a).compareTo(_roundDate(b)));

      final snapshots = <_GroupHealthSnapshot>[];

      for (final round in closedRounds) {
        try {
          final results = await widget.api.getFeedbackResults(
            widget.session.sessionToken,
            round.id,
          );

          snapshots.add(_GroupHealthSnapshot(round: round, results: results));
        } on ApiException catch (error) {
          if (error.statusCode != 409) {
            rethrow;
          }

          // A closed assessment that did not reach its privacy threshold
          // must not contribute data to longitudinal history.
        }
      }

      if (mounted) {
        setState(() => _snapshots = snapshots);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _error = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    final snapshots = _snapshots;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.groupHealthHistory)),
      body: error != null
          ? _EmptyState(
              icon: Icons.error_outline,
              title: l10n.historyUnavailable,
              message: _messageFor(context, error),
            )
          : snapshots == null
          ? const Center(child: CircularProgressIndicator())
          : snapshots.isEmpty
          ? _EmptyState(
              icon: Icons.timeline_outlined,
              title: l10n.noHistoryYet,
              message: l10n.noHistoryMessage,
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.groupHealthHistoryExplanation,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (var index = snapshots.length - 1; index >= 0; index--)
                  _GroupHealthSnapshotCard(
                    snapshot: snapshots[index],
                    previous: index > 0 ? snapshots[index - 1] : null,
                  ),
              ],
            ),
    );
  }
}

class _GroupHealthSnapshot {
  const _GroupHealthSnapshot({required this.round, required this.results});

  final FeedbackRoundSummary round;
  final FeedbackResults results;
}

class _GroupHealthSnapshotCard extends StatelessWidget {
  const _GroupHealthSnapshotCard({
    required this.snapshot,
    required this.previous,
  });

  final _GroupHealthSnapshot snapshot;
  final _GroupHealthSnapshot? previous;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatHistoryDate(context, _roundDate(snapshot.round)),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(l10n.aggregatedResponseCount(snapshot.results.responseCount)),
            const SizedBox(height: 16),
            for (final result in snapshot.results.scaleResults) ...[
              _GroupHealthDimensionRow(
                result: result,
                previousAverage: _previousAverage(previous, result.key),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupHealthDimensionRow extends StatelessWidget {
  const _GroupHealthDimensionRow({
    required this.result,
    required this.previousAverage,
  });

  final ScaleQuestionResult result;
  final double? previousAverage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final average = result.average;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizedBuiltInQuestionPrompt(
            l10n,
            coreGroupHealthQuestionnaireSlug,
            result.key,
            result.prompt,
          ),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        if (average == null)
          Text(l10n.noAnswers)
        else
          Row(
            children: [
              Text(
                average.toStringAsFixed(2),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (previousAverage != null) ...[
                const SizedBox(width: 12),
                Text(_formatHistoryDelta(context, average - previousAverage!)),
              ],
            ],
          ),
      ],
    );
  }
}

double? _previousAverage(_GroupHealthSnapshot? snapshot, String key) {
  if (snapshot == null) {
    return null;
  }

  for (final result in snapshot.results.scaleResults) {
    if (result.key == key) {
      return result.average;
    }
  }

  return null;
}

DateTime _roundDate(FeedbackRoundSummary round) {
  return round.closedAt ?? round.createdAt;
}

String _formatHistoryDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatMediumDate(date.toLocal());
}

String _formatHistoryDelta(BuildContext context, double delta) {
  final l10n = AppLocalizations.of(context);

  if (delta.abs() < 0.005) {
    return l10n.noChange;
  }

  final prefix = delta > 0 ? '+' : '';
  final value = '$prefix${delta.toStringAsFixed(2)}';

  return l10n.versusPrevious(value);
}

class _ResultsPageState extends State<ResultsPage> {
  FeedbackResults? _results;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final results = await widget.api.getFeedbackResults(
        widget.session.sessionToken,
        widget.roundId,
      );
      if (mounted) setState(() => _results = results);
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = _error;
    final results = _results;
    final playful = results == null
        ? null
        : buildPlayfulResult(
            results,
            questionnaireSlug: widget.questionnaireSlug,
          );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.aggregatedResults)),
      body: error != null
          ? _EmptyState(
              icon: Icons.shield_outlined,
              title: l10n.resultsNotAvailable,
              message: _messageFor(context, error),
            )
          : results == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: Text(l10n.responseCount(results.responseCount)),
                    subtitle: Text(l10n.aggregatedResultsPrivacy),
                  ),
                ),
                const SizedBox(height: 16),
                if (playful != null) ...[
                  _PlayfulResultCard(
                    result: playful,
                    questionnaireSlug: widget.questionnaireSlug,
                  ),
                  const SizedBox(height: 16),
                ],
                for (final result in results.scaleResults)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedBuiltInQuestionPrompt(
                              l10n,
                              widget.questionnaireSlug,
                              result.key,
                              result.prompt,
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.average == null
                                ? l10n.noAnswers
                                : l10n.averageValue(
                                    result.average!.toStringAsFixed(2),
                                  ),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(_distributionText(result.distribution)),
                        ],
                      ),
                    ),
                  ),
                for (final result in results.choiceResults)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizedBuiltInQuestionPrompt(
                              l10n,
                              widget.questionnaireSlug,
                              result.key,
                              result.prompt,
                            ),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          for (final option in result.options)
                            Text('${option.label}: ${option.count}'),
                        ],
                      ),
                    ),
                  ),
                for (final result in results.textResults) ...[
                  const SizedBox(height: 16),
                  Text(
                    localizedBuiltInQuestionPrompt(
                      l10n,
                      widget.questionnaireSlug,
                      result.key,
                      result.prompt,
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (result.comments.isEmpty)
                    Text(l10n.noCommentsSubmitted)
                  else
                    for (final comment in result.comments)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(comment),
                        ),
                      ),
                ],
              ],
            ),
    );
  }
}

class _PlayfulResultCard extends StatelessWidget {
  const _PlayfulResultCard({
    required this.result,
    required this.questionnaireSlug,
  });

  final PlayfulResult result;
  final String questionnaireSlug;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final title = _playfulCharacterTitle(l10n, result.character);

    final prompt = result.spotlightKey == null
        ? null
        : localizedBuiltInQuestionPrompt(
            l10n,
            questionnaireSlug,
            result.spotlightKey!,
            result.spotlightPrompt ?? '',
          );

    final message = result.character == PlayfulCharacter.balancedCapybara
        ? l10n.balancedPlayfulMessage
        : questionnaireSlug == coreGroupHealthQuestionnaireSlug
        ? l10n.groupPlayfulMessage(
            prompt ?? '',
            result.spotlightAverage?.toStringAsFixed(1) ?? '',
          )
        : l10n.personalPlayfulMessage(
            prompt ?? '',
            result.spotlightAverage?.toStringAsFixed(1) ?? '',
          );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PlayfulMascot(character: result.character, size: 84),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.playfulReflection,
                        style: theme.textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Text(message),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.playfulDisclaimer,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _playfulCharacterTitle(
  AppLocalizations l10n,
  PlayfulCharacter character,
) {
  return switch (character) {
    PlayfulCharacter.thoughtfulOwl => l10n.thoughtfulOwl,
    PlayfulCharacter.helpingOctopus => l10n.helpingOctopus,
    PlayfulCharacter.clearSignalFox => l10n.clearSignalFox,
    PlayfulCharacter.steadyTurtle => l10n.steadyTurtle,
    PlayfulCharacter.respectfulHedgehog => l10n.respectfulHedgehog,
    PlayfulCharacter.calmElephant => l10n.calmElephant,
    PlayfulCharacter.balancedCapybara => l10n.balancedCapybara,
  };
}

class _RoundStatusCard extends StatelessWidget {
  const _RoundStatusCard({
    required this.round,
    required this.isSubject,
    required this.isCreator,
  });

  final FeedbackRoundDetail round;
  final bool isSubject;
  final bool isCreator;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              round.isGroupHealth
                  ? l10n.groupHealthAssessment
                  : isSubject
                  ? l10n.yourFeedbackRequest
                  : l10n.anonymousFeedbackRequest,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(l10n.statusValue(_roundStatusLabel(l10n, round.status))),
            Text(l10n.privacyThresholdResponses(round.minResponses)),
            if (round.isGroupHealth)
              Text(
                isCreator
                    ? l10n.creatorCanParticipate
                    : l10n.eligibleMembersCanParticipate,
              ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

Future<QuestionnaireSummary?> _selectQuestionnaireDialog(
  BuildContext context,
  List<QuestionnaireSummary> questionnaires,
) async {
  final l10n = AppLocalizations.of(context);

  if (questionnaires.isEmpty) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.noPublishedQuestionnaires)));
    return null;
  }
  return showDialog<QuestionnaireSummary>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.chooseQuestionnaire),
      content: SizedBox(
        width: 520,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final item in questionnaires)
              ListTile(
                leading: Icon(
                  item.isBuiltIn ? Icons.lock_outline : Icons.quiz_outlined,
                ),
                title: Text(localizedQuestionnaireName(l10n, item)),
                subtitle: Text(
                  l10n.versionBlocks(item.version, item.questions.length),
                ),
                onTap: () => Navigator.pop(context, item),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
      ],
    ),
  );
}

String _questionKindLabel(BuildContext context, QuestionSummary question) {
  final l10n = AppLocalizations.of(context);

  switch (question.kind) {
    case 'scale':
      return l10n.ratingRange(question.minScore ?? 1, question.maxScore ?? 5);

    case 'single_choice':
      return l10n.singleChoiceOptions(question.options.length);

    case 'multiple_choice':
      return l10n.multipleChoiceOptions(question.options.length);

    case 'short_text':
      return question.required
          ? l10n.requiredShortText
          : l10n.optionalShortText;

    case 'long_text':
    case 'text':
      return question.required ? l10n.requiredLongText : l10n.optionalLongText;

    case 'description':
      return l10n.informationOnly;

    default:
      return question.kind;
  }
}

Future<String?> _textDialog(
  BuildContext context, {
  required String title,
  required String label,
  required String actionLabel,
}) async {
  var draft = '';

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onChanged: (value) => draft = value,
        onSubmitted: (value) {
          final trimmed = value.trim();
          if (trimmed.isNotEmpty) {
            Navigator.pop(context, trimmed);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(AppLocalizations.of(context).cancel),
        ),
        FilledButton(
          onPressed: () {
            final trimmed = draft.trim();
            if (trimmed.isNotEmpty) {
              Navigator.pop(context, trimmed);
            }
          },
          child: Text(actionLabel),
        ),
      ],
    ),
  );
}

void _showError(BuildContext context, Object error) {
  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(_messageFor(context, error))));
}

String _messageFor(BuildContext context, Object error) {
  if (error is ApiException) {
    return error.message;
  }

  return AppLocalizations.of(context).somethingWentWrongTryAgain;
}

String _distributionText(Map<String, int> distribution) {
  final entries = distribution.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));
  return entries.map((entry) => '${entry.key}: ${entry.value}').join(' · ');
}
