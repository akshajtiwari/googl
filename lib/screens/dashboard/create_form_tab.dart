import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

// ─── Data Models ────────────────────────────────────────────────────────────

enum QuestionType {
  shortText,
  longText,
  multipleChoice,
  checkboxes,
  dropdown,
  linearScale,
  date,
  time,
  fileUpload,
}

extension QuestionTypeLabel on QuestionType {
  String get label {
    switch (this) {
      case QuestionType.shortText:
        return 'Short Answer';
      case QuestionType.longText:
        return 'Paragraph';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.checkboxes:
        return 'Checkboxes';
      case QuestionType.dropdown:
        return 'Dropdown';
      case QuestionType.linearScale:
        return 'Linear Scale';
      case QuestionType.date:
        return 'Date';
      case QuestionType.time:
        return 'Time';
      case QuestionType.fileUpload:
        return 'File Upload';
    }
  }

  IconData get icon {
    switch (this) {
      case QuestionType.shortText:
        return Icons.short_text;
      case QuestionType.longText:
        return Icons.subject;
      case QuestionType.multipleChoice:
        return Icons.radio_button_checked;
      case QuestionType.checkboxes:
        return Icons.check_box;
      case QuestionType.dropdown:
        return Icons.arrow_drop_down_circle;
      case QuestionType.linearScale:
        return Icons.linear_scale;
      case QuestionType.date:
        return Icons.calendar_today;
      case QuestionType.time:
        return Icons.access_time;
      case QuestionType.fileUpload:
        return Icons.upload_file;
    }
  }
}

class FormQuestion {
  String id;
  String label;
  QuestionType type;
  bool required;
  List<String> options;
  int scaleMin;
  int scaleMax;
  String scaleMinLabel;
  String scaleMaxLabel;
  String helperText;

  FormQuestion({
    required this.id,
    this.label = '',
    this.type = QuestionType.shortText,
    this.required = false,
    List<String>? options,
    this.scaleMin = 1,
    this.scaleMax = 5,
    this.scaleMinLabel = '',
    this.scaleMaxLabel = '',
    this.helperText = '',
  }) : options = options ?? ['Option 1'];

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'type': type.name,
        'required': required,
        'options': options,
        'scaleMin': scaleMin,
        'scaleMax': scaleMax,
        'scaleMinLabel': scaleMinLabel,
        'scaleMaxLabel': scaleMaxLabel,
        'helperText': helperText,
      };

  factory FormQuestion.fromJson(Map<String, dynamic> j) {
    final typeStr = j['type'] as String? ?? 'shortText';
    final type = QuestionType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => QuestionType.shortText,
    );
    return FormQuestion(
      id: j['id'] as String? ?? UniqueKey().toString(),
      label: j['label'] as String? ?? '',
      type: type,
      required: j['required'] as bool? ?? false,
      options: (j['options'] as List<dynamic>?)?.cast<String>() ?? ['Option 1'],
      scaleMin: j['scaleMin'] as int? ?? 1,
      scaleMax: j['scaleMax'] as int? ?? 5,
      scaleMinLabel: j['scaleMinLabel'] as String? ?? '',
      scaleMaxLabel: j['scaleMaxLabel'] as String? ?? '',
      helperText: j['helperText'] as String? ?? '',
    );
  }

  FormQuestion copyWith({
    String? id,
    String? label,
    QuestionType? type,
    bool? required,
    List<String>? options,
    int? scaleMin,
    int? scaleMax,
    String? scaleMinLabel,
    String? scaleMaxLabel,
    String? helperText,
  }) =>
      FormQuestion(
        id: id ?? this.id,
        label: label ?? this.label,
        type: type ?? this.type,
        required: required ?? this.required,
        options: options ?? List.from(this.options),
        scaleMin: scaleMin ?? this.scaleMin,
        scaleMax: scaleMax ?? this.scaleMax,
        scaleMinLabel: scaleMinLabel ?? this.scaleMinLabel,
        scaleMaxLabel: scaleMaxLabel ?? this.scaleMaxLabel,
        helperText: helperText ?? this.helperText,
      );
}

// Minimal volunteer model (replace with your actual model)
class Volunteer {
  final String id;
  final String name;
  final String email;
  final String? avatarInitials;

  Volunteer({
    required this.id,
    required this.name,
    required this.email,
    this.avatarInitials,
  });
}

// ─── Google Color Palette ────────────────────────────────────────────────────

class _GColors {
  static const blue = Color(0xFF1A73E8);
  static const blueDark = Color(0xFF1557B0);
  static const blueLight = Color(0xFFE8F0FE);
  static const blueAccent = Color(0xFF4285F4);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8F9FA);
  static const border = Color(0xFFDEE2E6);
  static const divider = Color(0xFFE8EAED);
  static const textPrimary = Color(0xFF202124);
  static const textSecondary = Color(0xFF5F6368);
  static const textHint = Color(0xFF80868B);
  static const error = Color(0xFFD93025);
  static const success = Color(0xFF188038);
  static const amber = Color(0xFFF29900);
  static const purple = Color(0xFF9C27B0);
  static const cardShadow = Color(0x1A000000);

  static const questionColors = [
    Color(0xFF1A73E8),
    Color(0xFF0F9D58),
    Color(0xFFF4B400),
    Color(0xFFDB4437),
    Color(0xFF9C27B0),
    Color(0xFF00ACC1),
  ];
}

// ─── Main Widget ─────────────────────────────────────────────────────────────

class CreateFormTab extends StatefulWidget {
  const CreateFormTab({super.key});

  @override
  State<CreateFormTab> createState() => _CreateFormTabState();
}

class _CreateFormTabState extends State<CreateFormTab>
    with SingleTickerProviderStateMixin {
  // Prompt step
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _reqCtrl = TextEditingController();
  bool _loading = false;

  // Builder step
  bool _inBuilder = false;
  String _formTitle = 'Untitled Form';
  String _formDescription = '';
  String _formAccentHex = '#1A73E8';
  List<FormQuestion> _questions = [];
  int? _expandedIndex;

  // Tab controller for builder
  late TabController _tabController;

  // Persistent controllers for builder (never recreated inside build)
  late final TextEditingController _builderTitleCtrl;
  late final TextEditingController _builderDescCtrl;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _builderTitleCtrl = TextEditingController(text: _formTitle);
    _builderDescCtrl = TextEditingController(text: _formDescription);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _reqCtrl.dispose();
    _tabController.dispose();
    _builderTitleCtrl.dispose();
    _builderDescCtrl.dispose();
    super.dispose();
  }

  // ── Generation ────────────────────────────────────────────────────────────

  Future<void> _generate() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      final resp = await ApiService.generateForm(auth.token ?? '', {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'requirements': _reqCtrl.text.trim(),
      });
      _parseResponse(resp);
    } catch (e) {
      if (mounted) {
        _showSnack('Generation failed: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _parseResponse(dynamic resp) {
    try {
      // resp may be a Map (parsed JSON) or a String
      Map<String, dynamic> data;
      if (resp is String) {
        final clean =
            resp.replaceAll(RegExp(r'```json|```', multiLine: true), '').trim();
        data = jsonDecode(clean) as Map<String, dynamic>;
      } else if (resp is Map) {
        // If backend wraps in {'form': '...'} or {'form': {...}}
        if (resp.containsKey('form')) {
          final inner = resp['form'];
          if (inner is String) {
            final clean = inner
                .replaceAll(RegExp(r'```json|```', multiLine: true), '')
                .trim();
            data = jsonDecode(clean) as Map<String, dynamic>;
          } else {
            data = Map<String, dynamic>.from(inner as Map);
          }
        } else {
          data = Map<String, dynamic>.from(resp);
        }
      } else {
        throw Exception('Unexpected response type');
      }

      final questions = <FormQuestion>[];
      final rawQuestions = data['questions'] as List<dynamic>? ?? [];
      for (var i = 0; i < rawQuestions.length; i++) {
        final q = rawQuestions[i] as Map<String, dynamic>;
        final typeStr = (q['type'] as String? ?? '').toLowerCase();
        QuestionType type;
        if (typeStr.contains('text') && typeStr.contains('long')) {
          type = QuestionType.longText;
        } else if (typeStr.contains('paragraph')) {
          type = QuestionType.longText;
        } else if (typeStr.contains('multiple') || typeStr.contains('radio')) {
          type = QuestionType.multipleChoice;
        } else if (typeStr.contains('check')) {
          type = QuestionType.checkboxes;
        } else if (typeStr.contains('drop')) {
          type = QuestionType.dropdown;
        } else if (typeStr.contains('scale') || typeStr.contains('linear')) {
          type = QuestionType.linearScale;
        } else if (typeStr.contains('date')) {
          type = QuestionType.date;
        } else if (typeStr.contains('time')) {
          type = QuestionType.time;
        } else if (typeStr.contains('file')) {
          type = QuestionType.fileUpload;
        } else {
          type = QuestionType.shortText;
        }

        final opts = (q['options'] as List<dynamic>?)?.cast<String>() ??
            (type == QuestionType.multipleChoice ||
                    type == QuestionType.checkboxes ||
                    type == QuestionType.dropdown
                ? ['Option 1', 'Option 2']
                : []);

        questions.add(FormQuestion(
          id: 'q_${DateTime.now().millisecondsSinceEpoch}_$i',
          label: q['label'] as String? ?? q['question'] as String? ?? '',
          type: type,
          required: q['required'] as bool? ?? false,
          options: opts,
        ));
      }

      final parsedTitle = data['title'] as String? ?? _titleCtrl.text;
      final parsedDesc = data['description'] as String? ?? _descCtrl.text;
      setState(() {
        _formTitle = parsedTitle;
        _formDescription = parsedDesc;
        _builderTitleCtrl.text = parsedTitle;
        _builderDescCtrl.text = parsedDesc;
        _questions = questions;
        _inBuilder = true;
        _expandedIndex = questions.isNotEmpty ? 0 : null;
      });
    } catch (e) {
      _showSnack('Failed to parse generated form: $e', isError: true);
    }
  }

  // ── Form builder helpers ──────────────────────────────────────────────────

  void _addQuestion() {
    final q = FormQuestion(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      label: '',
      type: QuestionType.shortText,
    );
    setState(() {
      _questions.add(q);
      _expandedIndex = _questions.length - 1;
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
      if (_expandedIndex == index) {
        _expandedIndex = null;
      } else if (_expandedIndex != null && _expandedIndex! > index) {
        _expandedIndex = _expandedIndex! - 1;
      }
    });
  }

  void _duplicateQuestion(int index) {
    final orig = _questions[index];
    final copy = orig.copyWith(
      id: 'q_${DateTime.now().millisecondsSinceEpoch}',
      options: List.from(orig.options),
    );
    setState(() {
      _questions.insert(index + 1, copy);
      _expandedIndex = index + 1;
    });
  }

  void _moveQuestion(int oldIndex, int newIndex) {
    setState(() {
      final q = _questions.removeAt(oldIndex);
      _questions.insert(newIndex, q);
      _expandedIndex = newIndex;
    });
  }

  void _updateQuestion(int index, FormQuestion updated) {
    setState(() {
      _questions[index] = updated;
    });
  }

  // ── Export ────────────────────────────────────────────────────────────────

  Future<void> _exportJson() async {
    final schema = {
      'title': _formTitle,
      'description': _formDescription,
      'questions': _questions.map((q) => q.toJson()).toList(),
    };
    final pretty = const JsonEncoder.withIndent('  ').convert(schema);
    await Clipboard.setData(ClipboardData(text: pretty));
    _showSnack('Form JSON copied to clipboard');
  }

  /// Export to PDF using a simple approach via pdf package.
  /// Add `pdf: ^3.10.8` and `printing: ^5.12.0` to pubspec.yaml.
  Future<void> _exportPdf() async {
    _showSnack('PDF export: add the pdf + printing packages to your pubspec.yaml\nand call Printing.layoutPdf(...) with your form data.');
    // ── Uncomment after adding packages ──────────────────────────────────
    // import 'package:pdf/widgets.dart' as pw;
    // import 'package:printing/printing.dart';
    //
    // final doc = pw.Document();
    // doc.addPage(pw.MultiPage(
    //   build: (ctx) => [
    //     pw.Text(_formTitle, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
    //     pw.SizedBox(height: 8),
    //     if (_formDescription.isNotEmpty)
    //       pw.Text(_formDescription, style: const pw.TextStyle(fontSize: 14)),
    //     pw.SizedBox(height: 16),
    //     ..._questions.asMap().entries.map((e) {
    //       final i = e.key; final q = e.value;
    //       return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
    //         pw.Text('${i + 1}. ${q.label}${q.required ? ' *' : ''}',
    //             style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold)),
    //         pw.SizedBox(height: 4),
    //         _pdfQuestionWidget(q),
    //         pw.SizedBox(height: 12),
    //       ]);
    //     }),
    //   ],
    // ));
    // await Printing.layoutPdf(onLayout: (_) async => doc.save());
  }

  // ── Volunteer assignment ──────────────────────────────────────────────────

  Future<void> _showAssignDialog() async {
    // Replace with real fetch from your API
    final volunteers = _mockVolunteers();
    final selected = <String>{};

    await showDialog<void>(
      context: context,
      builder: (ctx) => _AssignDialog(
        volunteers: volunteers,
        onAssign: (ids) async {
          // TODO: call your API to send form to selected volunteers
          // e.g. await ApiService.assignForm(token, formId, ids);
          _showSnack('Form sent to ${ids.length} volunteer(s)');
        },
      ),
    );
  }

  List<Volunteer> _mockVolunteers() => [
        Volunteer(id: '1', name: 'Aarav Sharma', email: 'aarav@ngo.org', avatarInitials: 'AS'),
        Volunteer(id: '2', name: 'Priya Mehta', email: 'priya@ngo.org', avatarInitials: 'PM'),
        Volunteer(id: '3', name: 'Rahul Gupta', email: 'rahul@ngo.org', avatarInitials: 'RG'),
        Volunteer(id: '4', name: 'Sneha Iyer', email: 'sneha@ngo.org', avatarInitials: 'SI'),
        Volunteer(id: '5', name: 'Arjun Nair', email: 'arjun@ngo.org', avatarInitials: 'AN'),
        Volunteer(id: '6', name: 'Divya Reddy', email: 'divya@ngo.org', avatarInitials: 'DR'),
      ];

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? _GColors.error : _GColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return _inBuilder ? _buildFormBuilder() : _buildPromptStep();
  }

  // ── Step 1: Prompt ────────────────────────────────────────────────────────

  Widget _buildPromptStep() {
    return Container(
      color: _GColors.background,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              icon: Icons.auto_awesome,
              title: 'AI Form Generator',
              subtitle: 'Describe your survey and let AI build the first draft',
            ),
            const SizedBox(height: 24),
            _GCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _GTextField(
                    controller: _titleCtrl,
                    label: 'Form Title',
                    hint: 'e.g. Volunteer Registration Form',
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  _GTextField(
                    controller: _descCtrl,
                    label: 'Description',
                    hint: 'Brief description of this form',
                    icon: Icons.description,
                  ),
                  const SizedBox(height: 16),
                  _GTextField(
                    controller: _reqCtrl,
                    label: 'Requirements',
                    hint:
                        'What information do you need? e.g. name, skills, availability, emergency contact...',
                    icon: Icons.list_alt,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _GButton(
                        label: 'Generate Form',
                        icon: Icons.auto_awesome,
                        onPressed: _loading ? null : _generate,
                        loading: _loading,
                        primary: true,
                      ),
                      const SizedBox(width: 12),
                      _GButton(
                        label: 'Build Manually',
                        icon: Icons.edit,
                        onPressed: () {
                          final t = _titleCtrl.text.isEmpty ? 'Untitled Form' : _titleCtrl.text;
                          final d = _descCtrl.text;
                          _builderTitleCtrl.text = t;
                          _builderDescCtrl.text = d;
                          setState(() {
                            _formTitle = t;
                            _formDescription = d;
                            _questions = [];
                            _inBuilder = true;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Form Builder ──────────────────────────────────────────────────

  Widget _buildFormBuilder() {
    return Container(
      color: _GColors.background,
      child: Column(
        children: [
          _buildBuilderHeader(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left: form canvas
                Expanded(child: _buildCanvas()),
                // Right: action panel
                _buildActionPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuilderHeader() {
    return Container(
      color: _GColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: _GColors.textSecondary),
            tooltip: 'Back to prompt',
            onPressed: () => setState(() => _inBuilder = false),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _builderTitleCtrl,
              onChanged: (v) => _formTitle = v,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _GColors.textPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Form Title',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _GButton(
            label: 'Add Question',
            icon: Icons.add,
            onPressed: _addQuestion,
            primary: true,
            compact: true,
          ),
          const SizedBox(width: 8),
          _GButton(
            label: 'Assign',
            icon: Icons.send,
            onPressed: _showAssignDialog,
            compact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 12, 80),
      child: Column(
        children: [
          // Form header card
          _buildFormHeaderCard(),
          const SizedBox(height: 12),
          // Questions
          if (_questions.isEmpty)
            _buildEmptyState()
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _questions.length,
              onReorder: (old, nw) {
                if (nw > old) nw--;
                _moveQuestion(old, nw);
              },
              itemBuilder: (ctx, i) => _QuestionCard(
                key: ValueKey(_questions[i].id),
                question: _questions[i],
                index: i,
                total: _questions.length,
                expanded: _expandedIndex == i,
                onTap: () =>
                    setState(() => _expandedIndex = _expandedIndex == i ? null : i),
                onUpdate: (q) => _updateQuestion(i, q),
                onDuplicate: () => _duplicateQuestion(i),
                onDelete: () => _removeQuestion(i),
                onMoveUp: i > 0 ? () => _moveQuestion(i, i - 1) : null,
                onMoveDown:
                    i < _questions.length - 1 ? () => _moveQuestion(i, i + 1) : null,
              ),
            ),
          const SizedBox(height: 16),
          _buildAddQuestionButton(),
        ],
      ),
    );
  }

  Widget _buildFormHeaderCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _GColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(top: BorderSide(color: _GColors.blue, width: 8)),
        boxShadow: [
          BoxShadow(color: _GColors.cardShadow, blurRadius: 4, offset: const Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _builderTitleCtrl,
            onChanged: (v) => _formTitle = v,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w400,
              color: _GColors.textPrimary,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Form Title',
              hintStyle: TextStyle(color: _GColors.textHint),
              isDense: true,
            ),
          ),
          const Divider(color: _GColors.blue, thickness: 2),
          const SizedBox(height: 8),
          TextField(
            controller: _builderDescCtrl,
            onChanged: (v) => _formDescription = v,
            style: const TextStyle(fontSize: 14, color: _GColors.textSecondary),
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Form description (optional)',
              hintStyle: TextStyle(color: _GColors.textHint),
              isDense: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.article_outlined, size: 64, color: _GColors.textHint),
          const SizedBox(height: 12),
          const Text('No questions yet',
              style: TextStyle(color: _GColors.textSecondary, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Click "Add Question" to get started',
              style: TextStyle(color: _GColors.textHint, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAddQuestionButton() {
    return OutlinedButton.icon(
      onPressed: _addQuestion,
      icon: const Icon(Icons.add_circle_outline, color: _GColors.blue),
      label: const Text('Add question',
          style: TextStyle(color: _GColors.blue, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _GColors.border),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        backgroundColor: _GColors.surface,
      ),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      width: 200,
      margin: const EdgeInsets.fromLTRB(0, 20, 20, 20),
      child: Column(
        children: [
          _ActionPanelCard(
            title: 'Export',
            children: [
              _ActionTile(
                icon: Icons.picture_as_pdf,
                label: 'Export PDF',
                color: _GColors.error,
                onTap: _exportPdf,
              ),
              _ActionTile(
                icon: Icons.data_object,
                label: 'Copy JSON',
                color: _GColors.blue,
                onTap: _exportJson,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ActionPanelCard(
            title: 'Share',
            children: [
              _ActionTile(
                icon: Icons.group_add,
                label: 'Assign to volunteers',
                color: _GColors.success,
                onTap: _showAssignDialog,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ActionPanelCard(
            title: 'Stats',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Questions',
                        style:
                            TextStyle(fontSize: 12, color: _GColors.textSecondary)),
                    Text('${_questions.length}',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _GColors.textPrimary)),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Required',
                      style:
                          TextStyle(fontSize: 12, color: _GColors.textSecondary)),
                  Text(
                      '${_questions.where((q) => q.required).length}',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _GColors.textPrimary)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Question Card ────────────────────────────────────────────────────────────

class _QuestionCard extends StatefulWidget {
  final FormQuestion question;
  final int index;
  final int total;
  final bool expanded;
  final VoidCallback onTap;
  final ValueChanged<FormQuestion> onUpdate;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.index,
    required this.total,
    required this.expanded,
    required this.onTap,
    required this.onUpdate,
    required this.onDuplicate,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard> {
  late TextEditingController _labelCtrl;
  late TextEditingController _helperCtrl;
  // One controller per option — rebuilt only when option count changes
  List<TextEditingController> _optionCtrls = [];

  @override
  void initState() {
    super.initState();
    _labelCtrl = TextEditingController(text: widget.question.label);
    _helperCtrl = TextEditingController(text: widget.question.helperText);
    _rebuildOptionControllers(widget.question.options);
  }

  void _rebuildOptionControllers(List<String> options) {
    for (final c in _optionCtrls) c.dispose();
    _optionCtrls = options.map((o) => TextEditingController(text: o)).toList();
  }

  @override
  void didUpdateWidget(_QuestionCard old) {
    super.didUpdateWidget(old);
    // Only update label/helper if the change came from OUTSIDE (e.g. duplicate/undo),
    // not while the user is actively typing (which would be the same id).
    if (old.question.id != widget.question.id) {
      _labelCtrl.text = widget.question.label;
      _helperCtrl.text = widget.question.helperText;
      _rebuildOptionControllers(widget.question.options);
    } else {
      // Same question — only sync options if the count changed (add/remove option)
      if (old.question.options.length != widget.question.options.length) {
        _rebuildOptionControllers(widget.question.options);
      }
    }
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _helperCtrl.dispose();
    for (final c in _optionCtrls) c.dispose();
    super.dispose();
  }

  void _update(FormQuestion q) => widget.onUpdate(q);

  Color get _accentColor =>
      _GColors.questionColors[widget.index % _GColors.questionColors.length];

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _GColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: widget.expanded
            ? Border(left: BorderSide(color: _accentColor, width: 4))
            : null,
        boxShadow: [
          BoxShadow(
              color: _GColors.cardShadow,
              blurRadius: widget.expanded ? 6 : 2,
              offset: const Offset(0, 1))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
              child: Row(
                children: [
                  ReorderableDragStartListener(
                    index: widget.index,
                    child: Icon(Icons.drag_indicator,
                        color: _GColors.textHint, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _accentColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _accentColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      q.label.isEmpty ? 'Question ${widget.index + 1}' : q.label,
                      style: TextStyle(
                        fontSize: 14,
                        color: q.label.isEmpty
                            ? _GColors.textHint
                            : _GColors.textPrimary,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _GColors.background,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _GColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(q.type.icon, size: 14, color: _GColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(q.type.label,
                            style: const TextStyle(
                                fontSize: 11, color: _GColors.textSecondary)),
                      ],
                    ),
                  ),
                  if (q.required)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _GColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('*',
                          style: TextStyle(
                              fontSize: 12,
                              color: _GColors.error,
                              fontWeight: FontWeight.bold)),
                    ),
                  Icon(
                    widget.expanded
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color: _GColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          // Expanded editor
          if (widget.expanded) ...[
            const Divider(height: 1, color: _GColors.divider),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: _buildEditor(q),
            ),
            // Bottom toolbar
            Container(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_upward,
                        size: 18, color: widget.onMoveUp != null ? _GColors.textSecondary : _GColors.textHint),
                    tooltip: 'Move up',
                    onPressed: widget.onMoveUp,
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_downward,
                        size: 18,
                        color: widget.onMoveDown != null ? _GColors.textSecondary : _GColors.textHint),
                    tooltip: 'Move down',
                    onPressed: widget.onMoveDown,
                  ),
                  const VerticalDivider(width: 16),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18, color: _GColors.textSecondary),
                    tooltip: 'Duplicate',
                    onPressed: widget.onDuplicate,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: _GColors.error),
                    tooltip: 'Delete',
                    onPressed: widget.onDelete,
                  ),
                  const SizedBox(width: 8),
                  const VerticalDivider(width: 16),
                  const Text('Required',
                      style: TextStyle(fontSize: 13, color: _GColors.textSecondary)),
                  Switch(
                    value: q.required,
                    activeColor: _accentColor,
                    onChanged: (v) => _update(q.copyWith(required: v)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEditor(FormQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question label
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: _labelCtrl,
                onChanged: (v) => _update(q.copyWith(label: v)),
                style: const TextStyle(fontSize: 14, color: _GColors.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Question',
                  labelStyle: TextStyle(color: _accentColor, fontSize: 13),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _accentColor, width: 2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Type selector
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<QuestionType>(
                value: q.type,
                decoration: InputDecoration(
                  labelText: 'Question Type',
                  labelStyle: const TextStyle(fontSize: 13),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _accentColor, width: 2),
                  ),
                ),
                items: QuestionType.values.map((t) {
                  return DropdownMenuItem(
                    value: t,
                    child: Row(
                      children: [
                        Icon(t.icon, size: 16, color: _GColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(t.label, style: const TextStyle(fontSize: 13)),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (t) {
                  if (t != null) {
                    final needsOptions = t == QuestionType.multipleChoice ||
                        t == QuestionType.checkboxes ||
                        t == QuestionType.dropdown;
                    _update(q.copyWith(
                      type: t,
                      options: needsOptions && q.options.isEmpty
                          ? ['Option 1', 'Option 2']
                          : null,
                    ));
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Helper text
        TextField(
          controller: _helperCtrl,
          onChanged: (v) => _update(q.copyWith(helperText: v)),
          style: const TextStyle(fontSize: 13, color: _GColors.textSecondary),
          decoration: const InputDecoration(
            labelText: 'Helper text (optional)',
            labelStyle: TextStyle(fontSize: 12),
          ),
        ),
        const SizedBox(height: 16),
        // Type-specific options
        _buildTypeOptions(q),
      ],
    );
  }

  Widget _buildTypeOptions(FormQuestion q) {
    switch (q.type) {
      case QuestionType.multipleChoice:
      case QuestionType.checkboxes:
      case QuestionType.dropdown:
        return _buildOptionsEditor(q);
      case QuestionType.linearScale:
        return _buildScaleEditor(q);
      case QuestionType.shortText:
        return _buildPreview(
            const Icon(Icons.short_text, color: _GColors.textHint),
            'Short answer text');
      case QuestionType.longText:
        return _buildPreview(
            const Icon(Icons.subject, color: _GColors.textHint),
            'Long answer text');
      case QuestionType.date:
        return _buildPreview(
            const Icon(Icons.calendar_today, color: _GColors.textHint),
            'Date picker');
      case QuestionType.time:
        return _buildPreview(
            const Icon(Icons.access_time, color: _GColors.textHint),
            'Time picker');
      case QuestionType.fileUpload:
        return _buildPreview(
            const Icon(Icons.upload_file, color: _GColors.textHint),
            'File upload');
    }
  }

  Widget _buildPreview(Widget icon, String label) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(fontSize: 13, color: _GColors.textHint)),
      ],
    );
  }

  Widget _buildOptionsEditor(FormQuestion q) {
    final icon = q.type == QuestionType.checkboxes
        ? Icons.check_box_outline_blank
        : q.type == QuestionType.dropdown
            ? Icons.arrow_drop_down
            : Icons.radio_button_unchecked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...q.options.asMap().entries.map((entry) {
          final i = entry.key;
          // Use the persistent controller — never create one inside build
          final ctrl = i < _optionCtrls.length
              ? _optionCtrls[i]
              : TextEditingController(text: entry.value);
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: _GColors.textHint),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: ctrl,
                    onChanged: (v) {
                      final opts = List<String>.from(q.options);
                      opts[i] = v;
                      // Update model without triggering a full options rebuild
                      widget.onUpdate(q.copyWith(options: opts));
                    },
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Option ${i + 1}',
                      hintStyle:
                          const TextStyle(color: _GColors.textHint, fontSize: 13),
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: _GColors.textHint),
                  onPressed: q.options.length > 1
                      ? () {
                          final opts = List<String>.from(q.options)..removeAt(i);
                          _update(q.copyWith(options: opts));
                        }
                      : null,
                ),
              ],
            ),
          );
        }),
        Row(
          children: [
            const SizedBox(width: 28),
            TextButton.icon(
              onPressed: () {
                final opts = List<String>.from(q.options)
                  ..add('Option ${q.options.length + 1}');
                _update(q.copyWith(options: opts));
              },
              icon: const Icon(Icons.add, size: 16, color: _GColors.blue),
              label: const Text('Add option',
                  style: TextStyle(fontSize: 13, color: _GColors.blue)),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScaleEditor(FormQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Min:', style: TextStyle(fontSize: 13, color: _GColors.textSecondary)),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: q.scaleMin,
              items: [0, 1].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
              onChanged: (v) => v != null ? _update(q.copyWith(scaleMin: v)) : null,
              style: const TextStyle(fontSize: 13, color: _GColors.textPrimary),
            ),
            const SizedBox(width: 24),
            const Text('Max:', style: TextStyle(fontSize: 13, color: _GColors.textSecondary)),
            const SizedBox(width: 8),
            DropdownButton<int>(
              value: q.scaleMax,
              items: [2, 3, 4, 5, 6, 7, 8, 9, 10]
                  .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                  .toList(),
              onChanged: (v) => v != null ? _update(q.copyWith(scaleMax: v)) : null,
              style: const TextStyle(fontSize: 13, color: _GColors.textPrimary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _PersistentTextField(
                initialValue: q.scaleMinLabel,
                label: 'Min label',
                onChanged: (v) => _update(q.copyWith(scaleMinLabel: v)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _PersistentTextField(
                initialValue: q.scaleMaxLabel,
                label: 'Max label',
                onChanged: (v) => _update(q.copyWith(scaleMaxLabel: v)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (q.scaleMinLabel.isNotEmpty)
              Text(q.scaleMinLabel,
                  style: const TextStyle(fontSize: 11, color: _GColors.textSecondary)),
            ...List.generate(q.scaleMax - q.scaleMin + 1, (i) {
              final v = q.scaleMin + i;
              return Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(color: _GColors.border),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('$v',
                      style: const TextStyle(
                          fontSize: 11, color: _GColors.textSecondary)),
                ),
              );
            }),
            if (q.scaleMaxLabel.isNotEmpty)
              Text(q.scaleMaxLabel,
                  style: const TextStyle(fontSize: 11, color: _GColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

// ─── Assign Dialog ────────────────────────────────────────────────────────────

class _AssignDialog extends StatefulWidget {
  final List<Volunteer> volunteers;
  final Future<void> Function(List<String> ids) onAssign;

  const _AssignDialog({required this.volunteers, required this.onAssign});

  @override
  State<_AssignDialog> createState() => _AssignDialogState();
}

class _AssignDialogState extends State<_AssignDialog> {
  final Set<String> _selected = {};
  bool _sending = false;
  String _search = '';

  List<Volunteer> get _filtered => widget.volunteers
      .where((v) =>
          v.name.toLowerCase().contains(_search.toLowerCase()) ||
          v.email.toLowerCase().contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 440,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 16, 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: _GColors.divider)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: _GColors.blueLight,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.group_add, color: _GColors.blue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assign to Volunteers',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _GColors.textPrimary)),
                        Text('Select volunteers to send this form',
                            style: TextStyle(
                                fontSize: 12, color: _GColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search volunteers...',
                  hintStyle:
                      const TextStyle(fontSize: 13, color: _GColors.textHint),
                  prefixIcon: const Icon(Icons.search,
                      size: 18, color: _GColors.textHint),
                  filled: true,
                  fillColor: _GColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  isDense: true,
                ),
              ),
            ),
            // Select all row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${_selected.length} of ${widget.volunteers.length} selected',
                    style: const TextStyle(
                        fontSize: 12, color: _GColors.textSecondary),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() {
                      if (_selected.length == widget.volunteers.length) {
                        _selected.clear();
                      } else {
                        _selected.addAll(widget.volunteers.map((v) => v.id));
                      }
                    }),
                    child: Text(
                      _selected.length == widget.volunteers.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: const TextStyle(
                          fontSize: 12, color: _GColors.blue),
                    ),
                  ),
                ],
              ),
            ),
            // List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _filtered.length,
                itemBuilder: (ctx, i) {
                  final v = _filtered[i];
                  final isSelected = _selected.contains(v.id);
                  final initials = v.avatarInitials ??
                      v.name
                          .split(' ')
                          .map((p) => p.isNotEmpty ? p[0] : '')
                          .take(2)
                          .join()
                          .toUpperCase();
                  return ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: isSelected
                          ? _GColors.blue
                          : _GColors.blueLight,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : _GColors.blue,
                        ),
                      ),
                    ),
                    title: Text(v.name,
                        style: const TextStyle(
                            fontSize: 13, color: _GColors.textPrimary)),
                    subtitle: Text(v.email,
                        style: const TextStyle(
                            fontSize: 11, color: _GColors.textSecondary)),
                    trailing: Checkbox(
                      value: isSelected,
                      activeColor: _GColors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3)),
                      onChanged: (_) => setState(() {
                        if (isSelected) {
                          _selected.remove(v.id);
                        } else {
                          _selected.add(v.id);
                        }
                      }),
                    ),
                    onTap: () => setState(() {
                      if (isSelected) {
                        _selected.remove(v.id);
                      } else {
                        _selected.add(v.id);
                      }
                    }),
                    tileColor: isSelected ? _GColors.blueLight.withOpacity(0.5) : null,
                  );
                },
              ),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: _GColors.divider))),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selected.isEmpty
                          ? 'No volunteers selected'
                          : 'Send to ${_selected.length} volunteer${_selected.length > 1 ? 's' : ''}',
                      style: const TextStyle(
                          fontSize: 13, color: _GColors.textSecondary),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: _GColors.textSecondary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _selected.isEmpty || _sending
                        ? null
                        : () async {
                            setState(() => _sending = true);
                            await widget.onAssign(_selected.toList());
                            if (mounted) Navigator.pop(context);
                          },
                    icon: _sending
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, size: 16),
                    label: Text(_sending ? 'Sending...' : 'Send Form'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _GColors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Reusable Widgets ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _GColors.blueLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: _GColors.blue, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _GColors.textPrimary)),
            Text(subtitle,
                style: const TextStyle(
                    fontSize: 13, color: _GColors.textSecondary)),
          ],
        ),
      ],
    );
  }
}

class _GCard extends StatelessWidget {
  final Widget child;
  const _GCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _GColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: _GColors.cardShadow, blurRadius: 4, offset: Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: child,
    );
  }
}

class _GTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final int maxLines;

  const _GTextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _GColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(color: _GColors.textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: _GColors.textHint, fontSize: 13),
        prefixIcon: Icon(icon, size: 18, color: _GColors.textHint),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: _GColors.border)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _GColors.border)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _GColors.blue, width: 2)),
        filled: true,
        fillColor: _GColors.background,
      ),
    );
  }
}

class _GButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;
  final bool compact;

  const _GButton({
    required this.label,
    required this.icon,
    this.onPressed,
    this.primary = false,
    this.loading = false,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
              const SizedBox(width: 8),
              Text(label),
            ],
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: compact ? 14 : 16),
              const SizedBox(width: 6),
              Text(label),
            ],
          );

    if (primary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _GColors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
              : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          textStyle: TextStyle(fontSize: compact ? 13 : 14),
        ),
        child: child,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: _GColors.blue,
        side: const BorderSide(color: _GColors.border),
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        textStyle: TextStyle(fontSize: compact ? 13 : 14),
      ),
      child: child,
    );
  }
}

class _ActionPanelCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ActionPanelCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _GColors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: _GColors.cardShadow, blurRadius: 3, offset: Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _GColors.textHint,
                  letterSpacing: 1.0)),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(label,
                  style: TextStyle(fontSize: 12, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── _PersistentTextField ─────────────────────────────────────────────────────
// A StatefulWidget that owns its own TextEditingController so it is never
// recreated on parent rebuilds. Use this wherever the parent would otherwise
// create a controller inline inside a build method.

class _PersistentTextField extends StatefulWidget {
  final String initialValue;
  final String label;
  final ValueChanged<String> onChanged;

  const _PersistentTextField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  @override
  State<_PersistentTextField> createState() => _PersistentTextFieldState();
}

class _PersistentTextFieldState extends State<_PersistentTextField> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _ctrl,
      onChanged: widget.onChanged,
      style: const TextStyle(fontSize: 13, color: _GColors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(fontSize: 12),
        isDense: true,
      ),
    );
  }
}