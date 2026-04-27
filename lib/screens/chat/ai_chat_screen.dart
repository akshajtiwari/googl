import 'package:flutter/material.dart';
import '../../widgets/sidebar.dart';
import '../../widgets/top_bar.dart';
import '../../core/routes.dart';
import '../../services/auth_service.dart';
import '../../services/key_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isFetchingKey = false;

  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _maybePromptForGoogleKey();
    });
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _maybePromptForGoogleKey() async {
    if ((AuthService.googleApiKey ?? '').isNotEmpty) return;

    final choice = await showDialog<String?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Google API Key'),
        content: const Text(
            'No Google API key is set. Would you like to fetch the key from the server?'),
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
      await _fetchGoogleKey();
    }
  }

  Future<void> _fetchGoogleKey() async {
    try {
      setState(() => _isFetchingKey = true);
      final key = await KeyService.fetchGoogleKey();
      if (key != null && key.isNotEmpty) {
        AuthService.googleApiKey = key;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google key fetched from server')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Server did not return a key')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch Google key: $e')));
    } finally {
      setState(() => _isFetchingKey = false);
    }
  }

  Future<void> _ensureGoogleKey() async {
    if ((AuthService.googleApiKey ?? '').isNotEmpty) return;
    await _fetchGoogleKey();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;

    // ensure we have a key (typed or fetched)
    await _ensureGoogleKey();

    setState(() => _messages.add({'who': 'user', 'text': text}));
    _inputCtrl.clear();
    _scrollToBottom();

    // generate a simple reply
    Future.delayed(const Duration(milliseconds: 400), () {
      final usingGoogle = AuthService.googleApiKey != null &&
          AuthService.googleApiKey!.isNotEmpty;
      String reply;
      if (usingGoogle) {
        reply = 'AI answer (stub) — would use Google API with provided key.';
      } else {
        final q = text.toLowerCase();
        if (q.contains('volunt') || q.contains('how many')) {
          reply = 'There are about 142 volunteers (sample data).';
        } else if (q.contains('tasks')) {
          reply = 'There are 38 active tasks.';
        } else {
          reply =
              'I can answer simple questions about volunteers and tasks in this demo.';
        }
      }

      setState(() => _messages.add({'who': 'bot', 'text': reply}));
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Row(
        children: [
          const Sidebar(currentRoute: AppRoutes.aiChat),
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
                        children: [
                          Row(
                            children: [
                              const Text('AI Chatbot',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const Spacer(),
                              SizedBox(
                                width: 360,
                                child: Row(
                                  children: [
                                    const Text('Google key:'),
                                    const SizedBox(width: 8),
                                    Text(
                                      AuthService.googleApiKey != null &&
                                              AuthService
                                                  .googleApiKey!.isNotEmpty
                                          ? 'set'
                                          : 'not set',
                                      style: TextStyle(
                                        color:
                                            AuthService.googleApiKey != null &&
                                                    AuthService.googleApiKey!
                                                        .isNotEmpty
                                                ? Colors.green
                                                : Colors.redAccent,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: _isFetchingKey
                                          ? null
                                          : _fetchGoogleKey,
                                      icon: _isFetchingKey
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white))
                                          : const Icon(Icons.cloud_download),
                                      label: Text(_isFetchingKey
                                          ? 'Fetching...'
                                          : 'Fetch'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: const Color(0xFFF8F9FA),
                                  borderRadius: BorderRadius.circular(8)),
                              child: ListView.builder(
                                controller: _scrollCtrl,
                                itemCount: _messages.length,
                                itemBuilder: (context, index) {
                                  final m = _messages[index];
                                  final isUser = m['who'] == 'user';
                                  return Align(
                                    alignment: isUser
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                    child: Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6, horizontal: 8),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: isUser
                                            ? const Color(0xFF1A73E8)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                            color: const Color(0xFFDADCE0)),
                                      ),
                                      child: Text(
                                        m['text'] ?? '',
                                        style: TextStyle(
                                            color: isUser
                                                ? Colors.white
                                                : const Color(0xFF202124)),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _inputCtrl,
                                  decoration: const InputDecoration(
                                      hintText: 'Ask a question...'),
                                  onSubmitted: (_) => _send(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                  onPressed: _send, child: const Text('Send')),
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
