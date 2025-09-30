import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/repositories/mock_auth_repository_impl.dart';

class TestUsersInfo extends StatelessWidget {
  const TestUsersInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final testUsers = MockAuthRepositoryImpl.getTestUsers();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Тестовые пользователи',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Для тестирования используйте следующие учетные данные:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ...testUsers.map((user) => _UserCredentialTile(
                  name: user['name']!,
                  email: user['email']!,
                  password: user['password']!,
                )),
          ],
        ),
      ),
    );
  }
}

class _UserCredentialTile extends StatelessWidget {
  final String name;
  final String email;
  final String password;

  const _UserCredentialTile({
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Email: $email',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(context, email),
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Скопировать email',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Пароль: $password',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
              IconButton(
                onPressed: () => _copyToClipboard(context, password),
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Скопировать пароль',
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Скопировано: $text'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
