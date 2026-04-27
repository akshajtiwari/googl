import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import 'package:flutter/services.dart';

class CreateFormTab extends StatefulWidget {
  const CreateFormTab({super.key});

  @override
  State<CreateFormTab> createState() => _CreateFormTabState();
}

class _CreateFormTabState extends State<CreateFormTab> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _reqCtrl = TextEditingController();
  String? _generatedJson;
  bool _loading = false;

  Future<void> _generate() async {
    setState(() => _loading = true);
    final auth = Provider.of<AuthService>(context, listen: false);
    try {
      final resp = await ApiService.generateForm(auth.token ?? '', {
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'requirements': _reqCtrl.text.trim(),
      });
      // Expecting JSON response with a 'form' or raw JSON. We'll stringify.
      _generatedJson = const JsonEncoder.withIndent('  ').convert(resp);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Generation failed: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final generatedJson = _generatedJson;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('AI Form Generator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Form Title')),
          const SizedBox(height: 8),
          TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description')),
          const SizedBox(height: 8),
          TextField(
              controller: _reqCtrl,
              decoration: const InputDecoration(
                  labelText: 'Requirements (what you need from volunteers)'),
              maxLines: 4),
          const SizedBox(height: 12),
          Row(children: [
            ElevatedButton(
                onPressed: _loading ? null : _generate,
                child: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Generate Form')),
            const SizedBox(width: 12),
            if (generatedJson != null)
              ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: generatedJson));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Form JSON copied to clipboard')));
                  },
                  child: const Text('Copy JSON'))
          ]),
          const SizedBox(height: 16),
          if (generatedJson != null)
            Expanded(
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: SelectableText(generatedJson,
                        style: const TextStyle(fontFamily: 'monospace')),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
