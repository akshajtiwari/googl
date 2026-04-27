import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../services/key_service.dart';
import '../../services/generation_service.dart';

class CreateFormScreen extends StatefulWidget {
  const CreateFormScreen({super.key});

  @override
  State<CreateFormScreen> createState() => _CreateFormScreenState();
}

class _CreateFormScreenState extends State<CreateFormScreen> {
  String _template = 'Volunteer Signup';
  List<String> _generatedFields = [];
  bool _isFetchingKey = false;
  final TextEditingController _promptCtrl = TextEditingController();
  String _selectedModel = 'gemini-default';
  double _temperature = 0.2;
  int _maxTokens = 200;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptForGeminiKey();
    });
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _maybePromptForGeminiKey() async {
    if ((AuthService.geminiApiKey ?? '').isNotEmpty) return;

    final choice = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gemini API Key'),
        content: const Text(
            'No Gemini API key is set. Would you like to fetch the key from the server?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'fetch'),
              child: const Text('Fetch from Server')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, 'skip'),
              child: const Text('Skip')),
        ],
      ),
    );

    if (choice == 'fetch') {
      await _fetchGeminiKey();
    }
  }

  Future<void> _fetchGeminiKey() async {
    try {
      setState(() => _isFetchingKey = true);
      final key = await KeyService.fetchGeminiKey();
      if (key != null && key.isNotEmpty) {
        AuthService.geminiApiKey = key;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gemini key fetched from server')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server did not return a key')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch Gemini key: $e')));
    } finally {
      setState(() => _isFetchingKey = false);
    }
  }

  Future<void> _ensureGeminiKey() async {
    if ((AuthService.geminiApiKey ?? '').isNotEmpty) return;
    await _fetchGeminiKey();
  }

  Future<void> _generateForm() async {
    // Ensure we have a Gemini key (fetch from server if needed)
    await _ensureGeminiKey();

    setState(() => _isGenerating = true);
    try {
      final prompt = _promptCtrl.text.trim().isEmpty
          ? 'Create a $_template form for volunteers with appropriate fields.'
          : _promptCtrl.text.trim();

      final fields = await GenerationService.generateForm(
        prompt: prompt,
        model: _selectedModel,
        temperature: _temperature,
        maxTokens: _maxTokens,
      );

      setState(() => _generatedFields = fields);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form generated from backend')),
      );
    } catch (e) {
      // fallback to local template-based generation
      setState(() {
        if (_template == 'Volunteer Signup') {
          _generatedFields = [
            'Full name',
            'Phone number',
            'Email',
            'Preferred role',
            'Availability'
          ];
        } else if (_template == 'Availability') {
          _generatedFields = [
            'Full name',
            'Available dates',
            'Available hours per day',
            'Preferred zones'
          ];
        } else if (_template == 'Incident Report') {
          _generatedFields = [
            'Reporter name',
            'Location',
            'Incident type',
            'Description',
            'Photos (optional)'
          ];
        } else {
          _generatedFields = ['Question 1', 'Question 2', 'Question 3'];
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Generation failed, used fallback: $e')),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _sendToVolunteer() {
    // Stub: in a real app this would POST the form payload to a backend or messaging service
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Form sent to volunteer(s) (stub)')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(currentRoute: AppRoutes.createForm),
          Expanded(
            child: Column(
              children: [
                const TopBar(),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFDADCE0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Create Form',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 12),

                          // Gemini key status + fetch
                          Row(
                            children: [
                              const Text('Gemini key:'),
                              const SizedBox(width: 8),
                              Text(
                                AuthService.geminiApiKey != null &&
                                        AuthService.geminiApiKey!.isNotEmpty
                                    ? 'set'
                                    : 'not set',
                                style: TextStyle(
                                  color: AuthService.geminiApiKey != null &&
                                          AuthService.geminiApiKey!.isNotEmpty
                                      ? Colors.green
                                      : Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed:
                                    _isFetchingKey ? null : _fetchGeminiKey,
                                icon: _isFetchingKey
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Icon(Icons.cloud_download),
                                label: Text(
                                    _isFetchingKey ? 'Fetching...' : 'Fetch'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Prompt for generation
                          TextField(
                            controller: _promptCtrl,
                            minLines: 3,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              labelText: 'Generation prompt',
                              hintText:
                                  'Describe the form you want (fields, validations, required fields, etc.)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Template selector (no generate button here)
                          Row(
                            children: [
                              const Text('Template:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 12),
                              DropdownButton<String>(
                                value: _template,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'Volunteer Signup',
                                      child: Text('Volunteer Signup')),
                                  DropdownMenuItem(
                                      value: 'Availability',
                                      child: Text('Availability')),
                                  DropdownMenuItem(
                                      value: 'Incident Report',
                                      child: Text('Incident Report')),
                                  DropdownMenuItem(
                                      value: 'Survey', child: Text('Survey')),
                                ],
                                onChanged: (v) => setState(
                                    () => _template = v ?? 'Volunteer Signup'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Generation parameters + button
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text('Model:'),
                              const SizedBox(width: 8),
                              DropdownButton<String>(
                                value: _selectedModel,
                                items: const [
                                  DropdownMenuItem(
                                      value: 'gemini-default',
                                      child: Text('gemini-default')),
                                  DropdownMenuItem(
                                      value: 'gemini-1',
                                      child: Text('gemini-1')),
                                  DropdownMenuItem(
                                      value: 'gemini-2',
                                      child: Text('gemini-2')),
                                ],
                                onChanged: (v) => setState(() =>
                                    _selectedModel = v ?? 'gemini-default'),
                              ),
                              const SizedBox(width: 16),
                              const Text('Temp:'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 160,
                                child: Slider(
                                  value: _temperature,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 10,
                                  onChanged: (v) =>
                                      setState(() => _temperature = v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(_temperature.toStringAsFixed(2)),
                              const SizedBox(width: 16),
                              const Text('Max tokens:'),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 80,
                                child: TextFormField(
                                  initialValue: _maxTokens.toString(),
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => setState(() => _maxTokens =
                                      int.tryParse(v) ?? _maxTokens),
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _isGenerating ? null : _generateForm,
                                child: _isGenerating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white))
                                    : const Text('Generate Form'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          const Text('Preview',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),

                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: _generatedFields.isEmpty
                                  ? const Text('No form generated yet')
                                  : ListView.separated(
                                      itemCount: _generatedFields.length,
                                      separatorBuilder: (_, __) =>
                                          const Divider(),
                                      itemBuilder: (context, index) {
                                        final f = _generatedFields[index];
                                        return ListTile(
                                          title: Text(f),
                                          subtitle:
                                              const Text('Sample input field'),
                                        );
                                      },
                                    ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _generatedFields.isEmpty
                                    ? null
                                    : _sendToVolunteer,
                                icon: const Icon(Icons.send),
                                label: const Text('Send to Volunteer'),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () {
                                  // quick helper to show current API key state
                                  final k =
                                      AuthService.geminiApiKey ?? '<not set>';
                                  showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                              title: const Text('Gemini key'),
                                              content: Text(k),
                                              actions: [
                                                TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('OK'))
                                              ]));
                                },
                                child: const Text('Show Gemini Key'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
