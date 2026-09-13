import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../l10n/builtin_content.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';

class QuestionnairesPage extends StatefulWidget {
  const QuestionnairesPage({
    required this.api,
    required this.session,
    required this.group,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final GroupSummary group;

  @override
  State<QuestionnairesPage> createState() => _QuestionnairesPageState();
}

class _QuestionnairesPageState extends State<QuestionnairesPage> {
  List<QuestionnaireSummary> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    try {
      final items = await widget.api.listQuestionnaires(
        widget.session.sessionToken,
        widget.group.id,
      );
      if (mounted) setState(() => _items = items);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuestionnaireEditorPage(
          api: widget.api,
          session: widget.session,
          group: widget.group,
        ),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  Future<void> _edit(QuestionnaireSummary item) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => QuestionnaireEditorPage(
          api: widget.api,
          session: widget.session,
          group: widget.group,
          questionnaire: item,
        ),
      ),
    );
    if (saved == true && mounted) await _reload();
  }

  Future<void> _publish(QuestionnaireSummary item) async {
    try {
      await widget.api.publishQuestionnaire(
        widget.session.sessionToken,
        widget.group.id,
        item.id,
      );
      if (mounted) await _reload();
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  Future<void> _newVersion(QuestionnaireSummary item) async {
    try {
      final draft = await widget.api.createQuestionnaireVersion(
        widget.session.sessionToken,
        widget.group.id,
        item.id,
      );
      if (!mounted) return;
      await _edit(draft);
    } catch (error) {
      if (mounted) _showError(error);
    }
  }

  void _showError(Object error) {
    final l10n = AppLocalizations.of(context);
    final message = error is ApiException
        ? error.message
        : l10n.somethingWentWrong;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.questionnaires),
        actions: [
          IconButton(
            onPressed: _create,
            tooltip: l10n.newQuestionnaire,
            icon: const Icon(Icons.add),
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
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.questionnairePrivacyNote),
                  ),
                ),
                const SizedBox(height: 8),
                for (final item in _items)
                  _QuestionnaireCard(
                    item: item,
                    canEdit: item.createdByUserId == widget.session.userId,
                    onView: () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => QuestionnairePreviewPage(item: item),
                      ),
                    ),
                    onEdit: () => _edit(item),
                    onPublish: () => _publish(item),
                    onNewVersion: () => _newVersion(item),
                  ),
              ],
            ),
    );
  }
}

class _QuestionnaireCard extends StatelessWidget {
  const _QuestionnaireCard({
    required this.item,
    required this.canEdit,
    required this.onView,
    required this.onEdit,
    required this.onPublish,
    required this.onNewVersion,
  });

  final QuestionnaireSummary item;
  final bool canEdit;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onPublish;
  final VoidCallback onNewVersion;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final draft = item.status == 'draft';
    final displayName = localizedQuestionnaireName(l10n, item);
    final displayDescription = localizedQuestionnaireDescription(l10n, item);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    item.isBuiltIn
                        ? l10n.builtIn
                        : item.status == 'draft'
                        ? l10n.statusDraft
                        : item.status == 'published'
                        ? l10n.statusPublished
                        : item.status,
                  ),
                ),
              ],
            ),
            if (displayDescription != null) ...[
              const SizedBox(height: 6),
              Text(displayDescription),
            ],
            const SizedBox(height: 6),
            Text(l10n.versionBlocks(item.version, item.questions.length)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(onPressed: onView, child: Text(l10n.view)),
                if (!item.isBuiltIn && canEdit && draft)
                  OutlinedButton(
                    onPressed: onEdit,
                    child: Text(l10n.editDraft),
                  ),
                if (!item.isBuiltIn && canEdit && draft)
                  FilledButton(onPressed: onPublish, child: Text(l10n.publish)),
                if (!item.isBuiltIn && canEdit && !draft)
                  FilledButton.tonal(
                    onPressed: onNewVersion,
                    child: Text(l10n.newVersion),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionnairePreviewPage extends StatelessWidget {
  const QuestionnairePreviewPage({required this.item, super.key});
  final QuestionnaireSummary item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final displayName = localizedQuestionnaireName(l10n, item);
    final displayDescription = localizedQuestionnaireDescription(l10n, item);

    return Scaffold(
      appBar: AppBar(title: Text(displayName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (displayDescription != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(displayDescription),
              ),
            ),
          for (final question in item.questions)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${question.position}')),
                title: Text(
                  localizedBuiltInQuestionPrompt(
                    l10n,
                    item.slug,
                    question.key,
                    question.prompt,
                  ),
                ),
                subtitle: Text(_kindLabel(context, question)),
              ),
            ),
        ],
      ),
    );
  }
}

class QuestionnaireEditorPage extends StatefulWidget {
  const QuestionnaireEditorPage({
    required this.api,
    required this.session,
    required this.group,
    this.questionnaire,
    super.key,
  });

  final AnonymproveApi api;
  final SessionInfo session;
  final GroupSummary group;
  final QuestionnaireSummary? questionnaire;

  @override
  State<QuestionnaireEditorPage> createState() =>
      _QuestionnaireEditorPageState();
}

class _QuestionnaireEditorPageState extends State<QuestionnaireEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final List<_EditableQuestion> _questions;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final source = widget.questionnaire;
    _nameController = TextEditingController(text: source?.name ?? '');
    _descriptionController = TextEditingController(
      text: source?.description ?? '',
    );
    _questions = source == null
        ? [
            _EditableQuestion(
              kind: 'scale',
              prompt: '',
              required: true,
              minScore: 1,
              maxScore: 5,
            ),
          ]
        : source.questions.map(_EditableQuestion.fromSummary).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final input = QuestionnaireUpsertInput(
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      questions: _questions.map((item) => item.toInput()).toList(),
    );
    setState(() => _saving = true);
    try {
      if (widget.questionnaire == null) {
        await widget.api.createQuestionnaire(
          widget.session.sessionToken,
          widget.group.id,
          input,
        );
      } else {
        await widget.api.updateQuestionnaire(
          widget.session.sessionToken,
          widget.group.id,
          widget.questionnaire!.id,
          input,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        final message = error is ApiException
            ? error.message
            : AppLocalizations.of(context).couldNotSaveQuestionnaire;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        _EditableQuestion(
          kind: 'scale',
          prompt: '',
          required: true,
          minScore: 1,
          maxScore: 5,
        ),
      );
    });
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= _questions.length) return;
    setState(() {
      final item = _questions.removeAt(index);
      _questions.insert(target, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.questionnaire == null ? l10n.newQuestionnaire : l10n.editDraft,
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
                child: Text(l10n.editorPrivacyNote),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              maxLength: 120,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: l10n.questionnaireTitle,
                helperText: l10n.questionnaireTitleExample,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().length < 2 ? l10n.enterTitle : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: l10n.descriptionInstructionsOptional,
                helperText: l10n.descriptionExample,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            for (var index = 0; index < _questions.length; index++) ...[
              _QuestionEditorCard(
                key: ValueKey('question-$index-${_questions[index].kind}'),
                index: index,
                question: _questions[index],
                canMoveUp: index > 0,
                canMoveDown: index < _questions.length - 1,
                onChanged: () => setState(() {}),
                onMoveUp: () => _move(index, -1),
                onMoveDown: () => _move(index, 1),
                onDelete: _questions.length == 1
                    ? null
                    : () => setState(() => _questions.removeAt(index)),
              ),
              const SizedBox(height: 12),
            ],
            OutlinedButton.icon(
              onPressed: _saving ? null : _addQuestion,
              icon: const Icon(Icons.add),
              label: Text(l10n.addBlock),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.saveDraft),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionEditorCard extends StatelessWidget {
  const _QuestionEditorCard({
    required this.index,
    required this.question,
    required this.canMoveUp,
    required this.canMoveDown,
    required this.onChanged,
    required this.onMoveUp,
    required this.onMoveDown,
    required this.onDelete,
    super.key,
  });

  final int index;
  final _EditableQuestion question;
  final bool canMoveUp;
  final bool canMoveDown;
  final VoidCallback onChanged;
  final VoidCallback onMoveUp;
  final VoidCallback onMoveDown;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final isChoice =
        question.kind == 'single_choice' || question.kind == 'multiple_choice';
    final isScale = question.kind == 'scale';
    final isDescription = question.kind == 'description';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.blockNumber(index + 1),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: canMoveUp ? onMoveUp : null,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: canMoveDown ? onMoveDown : null,
                  icon: const Icon(Icons.arrow_downward),
                ),
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            DropdownButtonFormField<String>(
              initialValue: question.kind,
              decoration: InputDecoration(
                labelText: l10n.type,
                border: const OutlineInputBorder(),
              ),
              items: [
                DropdownMenuItem(value: 'scale', child: Text(l10n.ratingScale)),
                DropdownMenuItem(
                  value: 'single_choice',
                  child: Text(l10n.singleChoice),
                ),
                DropdownMenuItem(
                  value: 'multiple_choice',
                  child: Text(l10n.multipleChoice),
                ),
                DropdownMenuItem(
                  value: 'short_text',
                  child: Text(l10n.shortText),
                ),
                DropdownMenuItem(
                  value: 'long_text',
                  child: Text(l10n.longText),
                ),
                DropdownMenuItem(
                  value: 'description',
                  child: Text(l10n.descriptionInformation),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                question.setKind(
                  value,
                  option1: l10n.optionOne,
                  option2: l10n.optionTwo,
                );
                onChanged();
              },
            ),
            const SizedBox(height: 6),
            Text(
              _questionKindHelper(context, question.kind),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: question.prompt,
              maxLines: isDescription ? 3 : 2,
              maxLength: 500,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: isDescription ? l10n.informationText : l10n.question,
                helperText: isDescription
                    ? l10n.informationTextExample
                    : l10n.questionBehaviorHelper,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => question.prompt = value,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? l10n.blockCannotBeBlank : null,
            ),
            if (!isDescription)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: question.required,
                title: Text(l10n.required),
                onChanged: (value) {
                  question.required = value;
                  onChanged();
                },
              ),
            if (isScale) ...[
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: question.minScore,
                      decoration: InputDecoration(labelText: l10n.minimum),
                      items: [
                        for (var value = 1; value <= 9; value++)
                          DropdownMenuItem(value: value, child: Text('$value')),
                      ],
                      onChanged: (value) {
                        question.minScore = value;
                        onChanged();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: question.maxScore,
                      decoration: InputDecoration(labelText: l10n.maximum),
                      items: [
                        for (var value = 2; value <= 10; value++)
                          DropdownMenuItem(value: value, child: Text('$value')),
                      ],
                      onChanged: (value) {
                        question.maxScore = value;
                        onChanged();
                      },
                      validator: (_) =>
                          (question.minScore ?? 1) >= (question.maxScore ?? 5)
                          ? l10n.maxMustExceedMin
                          : null,
                    ),
                  ),
                ],
              ),
            ],
            if (isChoice) ...[
              const SizedBox(height: 12),
              TextFormField(
                initialValue: question.options.join('\n'),
                maxLines: 5,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                decoration: InputDecoration(
                  labelText: l10n.optionsOnePerLine,
                  helperText: l10n.optionsExample,
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  question.options = value
                      .split('\n')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList();
                },
                validator: (_) => question.options.length < 2
                    ? l10n.addAtLeastTwoOptions
                    : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EditableQuestion {
  _EditableQuestion({
    required this.kind,
    required this.prompt,
    required this.required,
    this.minScore,
    this.maxScore,
    List<String>? options,
  }) : options = options ?? [];

  String kind;
  String prompt;
  bool required;
  int? minScore;
  int? maxScore;
  List<String> options;

  factory _EditableQuestion.fromSummary(QuestionSummary question) =>
      _EditableQuestion(
        kind: question.kind == 'text' ? 'long_text' : question.kind,
        prompt: question.prompt,
        required: question.required,
        minScore: question.minScore,
        maxScore: question.maxScore,
        options: question.options.map((option) => option.label).toList(),
      );

  void setKind(
    String value, {
    required String option1,
    required String option2,
  }) {
    kind = value;
    if (value == 'scale') {
      minScore ??= 1;
      maxScore ??= 5;
      options = [];
    } else if (value == 'single_choice' || value == 'multiple_choice') {
      minScore = null;
      maxScore = null;
      if (options.length < 2) {
        options = [option1, option2];
      }
    } else {
      minScore = null;
      maxScore = null;
      options = [];
    }
    if (value == 'description') required = false;
  }

  QuestionnaireQuestionInput toInput() => QuestionnaireQuestionInput(
    prompt: prompt.trim(),
    kind: kind,
    required: kind == 'description' ? false : required,
    minScore: kind == 'scale' ? minScore : null,
    maxScore: kind == 'scale' ? maxScore : null,
    options: kind == 'single_choice' || kind == 'multiple_choice'
        ? options
        : const [],
  );
}

String _questionKindHelper(BuildContext context, String kind) {
  final l10n = AppLocalizations.of(context);

  return switch (kind) {
    'scale' => l10n.scaleHelper,
    'single_choice' => l10n.singleChoiceHelper,
    'multiple_choice' => l10n.multipleChoiceHelper,
    'short_text' => l10n.shortTextHelper,
    'long_text' => l10n.longTextHelper,
    'description' => l10n.descriptionHelper,
    _ => '',
  };
}

String _kindLabel(BuildContext context, QuestionSummary question) {
  final l10n = AppLocalizations.of(context);

  return switch (question.kind) {
    'scale' => l10n.ratingRange(question.minScore ?? 1, question.maxScore ?? 5),
    'single_choice' => l10n.singleChoiceOptions(question.options.length),
    'multiple_choice' => l10n.multipleChoiceOptions(question.options.length),
    'short_text' => l10n.shortText,
    'long_text' || 'text' => l10n.longText,
    'description' => l10n.informationOnly,
    _ => question.kind,
  };
}
