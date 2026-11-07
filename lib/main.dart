import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiUrl = 'http://10.0.2.2:8000/save_user';

void main() {
  runApp(const UserApp());
}

class UserApp extends StatelessWidget {
  const UserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FastAPI demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const SaveUserPage(),
    );
  }
}

class SaveUserPage extends StatefulWidget {
  const SaveUserPage({super.key});

  @override
  State<SaveUserPage> createState() => _SaveUserPageState();
}

class _SaveUserPageState extends State<SaveUserPage> {
  final _nameController = TextEditingController();
  String? _message;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveUser() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _message = 'Введіть імʼя');
      return;
    }

    setState(() {
      _isSaving = true;
      _message = null;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name}),
      );

      if (!mounted) return;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      setState(() {
        _message = response.statusCode == 200
            ? body['message'] as String
            : 'Помилка: ${body['detail'] ?? response.statusCode}';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _message = 'Не вдалося підключитися до FastAPI');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Збереження користувача')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Імʼя',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => _saveUser(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _saveUser,
                    child: _isSaving
                        ? const CircularProgressIndicator()
                        : const Text('Зберегти'),
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: 16),
                  Text(_message!, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
