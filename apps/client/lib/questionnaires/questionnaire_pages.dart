import 'package:flutter/material.dart';

import '../api/api_client.dart';
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
    final message = error is ApiException
        ? error.message
        : 'Something went wrong.';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaires'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Privacy note: do not ask respondents for names, initials, addresses, '
                      'birthdays, or other identifying information. Anonymous storage cannot '
                      'prevent a respondent from identifying themselves in an answer.',
                    ),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('New questionnaire'),
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
    final draft = item.status == 'draft';
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
                    item.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Chip(
                  label: Text(
                    item.isBuiltIn ? 'BUILT-IN' : item.status.toUpperCase(),
                  ),
                ),
              ],
            ),
            if (item.description != null) ...[
              const SizedBox(height: 6),
              Text(item.description!),
            ],
            const SizedBox(height: 6),
            Text('Version ${item.version} · ${item.questions.length} blocks'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(onPressed: onView, child: const Text('View')),
                if (!item.isBuiltIn && canEdit && draft)
                  OutlinedButton(
                    onPressed: onEdit,
                    child: const Text('Edit draft'),
                  ),
                if (!item.isBuiltIn && canEdit && draft)
                  FilledButton(
                    onPressed: onPublish,
                    child: const Text('Publish'),
                  ),
                if (!item.isBuiltIn && canEdit && !draft)
                  FilledButton.tonal(
                    onPressed: onNewVersion,
                    child: const Text('New version'),
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
    return Scaffold(
      appBar: AppBar(title: Text(item.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (item.description != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(item.description!),
              ),
            ),
          for (final question in item.questions)
            Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${question.position}')),
                title: Text(question.prompt),
                subtitle: Text(_kindLabel(question)),
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
            : 'Could not save questionnaire.';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.questionnaire == null ? 'New questionnaire' : 'Edit draft',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Avoid questions that request identifying information. Prefer observable '
                  'behavior and bounded choices over personally identifying free text.',
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Questionnaire title',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value ?? '').trim().length < 2 ? 'Enter a title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Description / instructions',
                border: OutlineInputBorder(),
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
              label: const Text('Add block'),
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
              label: const Text('Save draft'),
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
                    'Block ${index + 1}',
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
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'scale', child: Text('Rating scale')),
                DropdownMenuItem(
                  value: 'single_choice',
                  child: Text('Single choice'),
                ),
                DropdownMenuItem(
                  value: 'multiple_choice',
                  child: Text('Multiple choice'),
                ),
                DropdownMenuItem(
                  value: 'short_text',
                  child: Text('Short text'),
                ),
                DropdownMenuItem(value: 'long_text', child: Text('Long text')),
                DropdownMenuItem(
                  value: 'description',
                  child: Text('Description / information'),
                ),
              ],
              onChanged: (value) {
                if (value == null) return;
                question.setKind(value);
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              initialValue: question.prompt,
              maxLines: isDescription ? 3 : 2,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: isDescription ? 'Information text' : 'Question',
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) => question.prompt = value,
              validator: (value) => (value ?? '').trim().isEmpty
                  ? 'This block cannot be blank'
                  : null,
            ),
            if (!isDescription)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: question.required,
                title: const Text('Required'),
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
                      decoration: const InputDecoration(labelText: 'Minimum'),
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
                      decoration: const InputDecoration(labelText: 'Maximum'),
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
                          ? 'Max must exceed min'
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
                decoration: const InputDecoration(
                  labelText: 'Options (one per line)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  question.options = value
                      .split('\n')
                      .map((item) => item.trim())
                      .where((item) => item.isNotEmpty)
                      .toList();
                },
                validator: (_) => question.options.length < 2
                    ? 'Add at least two options'
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

  void setKind(String value) {
    kind = value;
    if (value == 'scale') {
      minScore ??= 1;
      maxScore ??= 5;
      options = [];
    } else if (value == 'single_choice' || value == 'multiple_choice') {
      minScore = null;
      maxScore = null;
      if (options.length < 2) options = ['Option 1', 'Option 2'];
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

String _kindLabel(QuestionSummary question) {
  switch (question.kind) {
    case 'scale':
      return 'Rating ${question.minScore}-${question.maxScore}';
    case 'single_choice':
      return 'Single choice · ${question.options.length} options';
    case 'multiple_choice':
      return 'Multiple choice · ${question.options.length} options';
    case 'short_text':
      return 'Short text';
    case 'long_text':
    case 'text':
      return 'Long text';
    case 'description':
      return 'Information only';
    default:
      return question.kind;
  }
}
