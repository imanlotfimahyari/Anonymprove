import 'package:flutter/material.dart';

import 'api/api_client.dart';
import 'models/models.dart';
import 'questionnaires/questionnaire_pages.dart';

const _defaultApiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://127.0.0.1:8000',
);

void main() {
  runApp(FeedbackApp(api: HttpAnonymproveApi(baseUrl: _defaultApiBaseUrl)));
}

class FeedbackApp extends StatelessWidget {
  const FeedbackApp({required this.api, super.key});

  final AnonymproveApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Private Feedback',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: SessionPage(api: api),
    );
  }
}

class SessionPage extends StatefulWidget {
  const SessionPage({required this.api, super.key});

  final AnonymproveApi api;

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
      return GroupsPage(api: widget.api, session: session);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Private Feedback')),
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
                  'Constructive feedback, without exposing who said what.',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'This MVP creates a temporary private session on this device. '
                  'Account recovery and persistent sign-in come later.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _starting ? null : _startSession,
                  icon: _starting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.arrow_forward),
                  label: const Text('Start private session'),
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
  const GroupsPage({required this.api, required this.session, super.key});

  final AnonymproveApi api;
  final SessionInfo session;

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
    final name = await _textDialog(
      context,
      title: 'Create group',
      label: 'Group name',
      actionLabel: 'Create',
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
    final code = await _textDialog(
      context,
      title: 'Join group',
      label: 'Join code',
      actionLabel: 'Join',
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
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Save this join code'),
        content: SelectableText(
          '$joinCode\n\nShare it only with people you want in this group. '
          'The API does not expose the code again later.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('I saved it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My groups'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _reload,
            tooltip: 'Refresh',
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
              subtitle: const Text('Temporary session identity'),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _groups.isEmpty
                ? const _EmptyState(
                    icon: Icons.group_outlined,
                    title: 'No groups yet',
                    message: 'Create a group or join one with a join code.',
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
                            subtitle: Text(group.role),
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
            label: const Text('Join'),
          ),
          FloatingActionButton.extended(
            heroTag: 'create-group',
            onPressed: _createGroup,
            icon: const Icon(Icons.add),
            label: const Text('Create'),
          ),
        ],
      ),
    );
  }
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

  Future<void> _createRound() async {
    setState(() => _creating = true);
    try {
      final questionnaires = await widget.api.listQuestionnaires(
        widget.session.sessionToken,
        widget.group.id,
      );
      if (!mounted) return;
      final published = questionnaires
          .where((item) => item.status == 'published')
          .toList();
      final selected = await _selectQuestionnaireDialog(context, published);
      if (selected == null || !mounted) return;
      final round = await widget.api.createFeedbackRound(
        widget.session.sessionToken,
        widget.group.id,
        questionnaireId: selected.id,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.group.name),
        actions: [
          IconButton(
            tooltip: 'Questionnaires',
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
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rounds.isEmpty
          ? const _EmptyState(
              icon: Icons.forum_outlined,
              title: 'No feedback rounds',
              message: 'Request feedback about yourself to start a round.',
            )
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _rounds.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final round = _rounds[index];
                  final isMine = round.subjectUserId == widget.session.userId;
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        isMine ? Icons.person_outline : Icons.feedback_outlined,
                      ),
                      title: Text(
                        isMine
                            ? 'Your feedback round'
                            : 'Group member feedback',
                      ),
                      subtitle: Text(
                        '${round.status.toUpperCase()} · minimum ${round.minResponses} responses',
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _creating ? null : _createRound,
        icon: _creating
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.add_comment_outlined),
        label: const Text('Request feedback'),
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
  bool _loading = true;
  bool _changing = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final round = await widget.api.getFeedbackRound(
        widget.session.sessionToken,
        widget.roundId,
      );
      if (mounted) {
        setState(() => _round = round);
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

  Future<void> _openRound() async {
    await _changeRound(() {
      return widget.api.openFeedbackRound(
        widget.session.sessionToken,
        widget.roundId,
      );
    });
  }

  Future<void> _closeRound() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Close feedback round?'),
        content: const Text(
          'No more feedback can be submitted after the round is closed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Close round'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
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
        await _reload();
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
        const SnackBar(content: Text('Feedback submitted anonymously.')),
      );
    }
  }

  Future<void> _viewResults() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => ResultsPage(
          api: widget.api,
          session: widget.session,
          roundId: widget.roundId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final round = _round;
    return Scaffold(
      appBar: AppBar(title: const Text('Feedback round')),
      body: _loading || round == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _RoundStatusCard(
                  round: round,
                  isSubject: round.subjectUserId == widget.session.userId,
                ),
                const SizedBox(height: 16),
                Text(
                  'Questions',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                for (final question in round.questions)
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text('${question.position}'),
                      ),
                      title: Text(question.prompt),
                      subtitle: Text(_questionKindLabel(question)),
                    ),
                  ),
                const SizedBox(height: 24),
                ..._actionsFor(round),
              ],
            ),
    );
  }

  List<Widget> _actionsFor(FeedbackRoundDetail round) {
    final isSubject = round.subjectUserId == widget.session.userId;
    if (isSubject && round.status == 'draft') {
      return [
        FilledButton.icon(
          onPressed: _changing ? null : _openRound,
          icon: const Icon(Icons.play_arrow),
          label: const Text('Open round'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Opening requires at least 3 other eligible group members.',
          textAlign: TextAlign.center,
        ),
      ];
    }
    if (isSubject && round.status == 'open') {
      return [
        FilledButton.tonalIcon(
          onPressed: _changing ? null : _closeRound,
          icon: const Icon(Icons.stop_circle_outlined),
          label: const Text('Close round'),
        ),
      ];
    }
    if (isSubject && round.status == 'closed') {
      return [
        FilledButton.icon(
          onPressed: _viewResults,
          icon: const Icon(Icons.bar_chart),
          label: const Text('View aggregated results'),
        ),
      ];
    }
    if (!isSubject && round.status == 'open') {
      return [
        FilledButton.icon(
          onPressed: () => _answer(round),
          icon: const Icon(Icons.edit_note),
          label: const Text('Answer anonymously'),
        ),
        const SizedBox(height: 8),
        const Text(
          'Your identity is used to check eligibility and issue one response '
          'credential. The feedback submission itself does not send your session token.',
          textAlign: TextAlign.center,
        ),
      ];
    }
    return [
      const Text(
        'This round is not currently accepting responses.',
        textAlign: TextAlign.center,
      ),
    ];
  }
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
    final label = '${question.position}. ${question.prompt}';
    switch (question.kind) {
      case 'description':
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(question.prompt),
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
              question.required && value == null ? 'Choose a score' : null,
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
              question.required && value == null ? 'Choose an option' : null,
        );
      case 'multiple_choice':
        return FormField<Set<String>>(
          initialValue: _multipleChoices[question.id] ?? <String>{},
          validator: (value) =>
              question.required && (value == null || value.isEmpty)
              ? 'Choose at least one option'
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
              ? 'Enter a response'
              : null,
        );
      default:
        return Text('Unsupported question type: ${question.kind}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anonymous feedback')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Focus on observable behavior. Do not include names or identifying details '
                  'in free-text answers.',
                ),
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
              label: const Text('Submit privately'),
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
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final String roundId;

  @override
  State<ResultsPage> createState() => _ResultsPageState();
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
    final error = _error;
    final results = _results;
    return Scaffold(
      appBar: AppBar(title: const Text('Aggregated results')),
      body: error != null
          ? _EmptyState(
              icon: Icons.shield_outlined,
              title: 'Results are not available',
              message: _messageFor(error),
            )
          : results == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.people_outline),
                    title: Text('${results.responseCount} responses'),
                    subtitle: const Text(
                      'Only aggregated results are shown after the privacy threshold.',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (final result in results.scaleResults)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.prompt,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            result.average == null
                                ? 'No answers'
                                : 'Average ${result.average!.toStringAsFixed(2)}',
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
                            result.prompt,
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
                    result.prompt,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  if (result.comments.isEmpty)
                    const Text('No comments submitted.')
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

class _RoundStatusCard extends StatelessWidget {
  const _RoundStatusCard({required this.round, required this.isSubject});

  final FeedbackRoundDetail round;
  final bool isSubject;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isSubject
                  ? 'Your feedback request'
                  : 'Anonymous feedback request',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('Status: ${round.status.toUpperCase()}'),
            Text('Privacy threshold: ${round.minResponses} responses'),
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
  if (questionnaires.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No published questionnaires are available.'),
      ),
    );
    return null;
  }
  return showDialog<QuestionnaireSummary>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Choose questionnaire'),
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
                title: Text(item.name),
                subtitle: Text(
                  'Version ${item.version} · ${item.questions.length} blocks',
                ),
                onTap: () => Navigator.pop(context, item),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}

String _questionKindLabel(QuestionSummary question) {
  switch (question.kind) {
    case 'scale':
      return 'Rating ${question.minScore}-${question.maxScore}';
    case 'single_choice':
      return 'Single choice · ${question.options.length} options';
    case 'multiple_choice':
      return 'Multiple choice · ${question.options.length} options';
    case 'short_text':
      return question.required ? 'Required short text' : 'Optional short text';
    case 'long_text':
    case 'text':
      return question.required ? 'Required long text' : 'Optional long text';
    case 'description':
      return 'Information only';
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
          child: const Text('Cancel'),
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
  ).showSnackBar(SnackBar(content: Text(_messageFor(error))));
}

String _messageFor(Object error) {
  if (error is ApiException) {
    return error.message;
  }
  return 'Something went wrong. Please try again.';
}

String _distributionText(Map<String, int> distribution) {
  final entries = distribution.entries.toList()
    ..sort((left, right) => left.key.compareTo(right.key));
  return entries.map((entry) => '${entry.key}: ${entry.value}').join(' · ');
}
