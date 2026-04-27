import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

class AiChatbotTab extends StatefulWidget {
  const AiChatbotTab({super.key});

  @override
  State<AiChatbotTab> createState() => _AiChatbotTabState();
}

class _AiChatbotTabState extends State<AiChatbotTab> {
  final TextEditingController _inputCtrl = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _loading = true;
      _inputCtrl.clear();
    });

    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      final resp = await ApiService.chat(auth.token ?? '', text);
      final reply = resp['reply'] ?? resp['message'] ?? resp.toString();
      setState(() {
        _messages.add({'role': 'assistant', 'text': reply.toString()});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'assistant', 'text': 'Error: $e'});
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final m = _messages[index];
                final isUser = m['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(m['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: TextField(
                      controller: _inputCtrl,
                      decoration:
                          const InputDecoration(hintText: 'Ask the AI...'))),
              const SizedBox(width: 8),
              ElevatedButton(
                  onPressed: _loading ? null : _send,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Send'))
            ],
          )
        ],
      ),
    );
  }
}
