import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/auth.dart';
import '../../providers/social_auth_provider.dart';

class LinkedAccountsScreen extends ConsumerStatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  ConsumerState<LinkedAccountsScreen> createState() =>
      _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends ConsumerState<LinkedAccountsScreen> {
  @override
  void initState() {
    super.initState();
    // Load linked accounts when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(socialAuthProvider.notifier).loadLinkedAccounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final socialAuthState = ref.watch(socialAuthProvider);

    ref.listen<SocialAuthState>(socialAuthProvider, (previous, next) {
      if (next.status == SocialAuthStatus.linkSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аккаунт успешно привязан!'),
            backgroundColor: Colors.green,
          ),
        );
        // Reload linked accounts
        ref.read(socialAuthProvider.notifier).loadLinkedAccounts();
      } else if (next.status == SocialAuthStatus.unlinkSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Аккаунт успешно отвязан!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (next.status == SocialAuthStatus.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage ?? 'Произошла ошибка'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Привязанные аккаунты'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: socialAuthState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Привязанные социальные сети',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Привяжите социальные сети для быстрого входа в приложение',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: socialAuthState.linkedAccounts != null
                        ? _buildLinkedAccountsList(
                            socialAuthState.linkedAccounts!)
                        : const Center(
                            child: Text('Загрузка привязанных аккаунтов...'),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildLinkedAccountsList(List<LinkedAccount> linkedAccounts) {
    final availableProviders = [
      SocialProvider.telegram,
      SocialProvider.yandex,
      SocialProvider.vk,
    ];

    return ListView.builder(
      itemCount: availableProviders.length,
      itemBuilder: (context, index) {
        final provider = availableProviders[index];
        final linkedAccount = linkedAccounts
            .where((account) => account.provider == provider)
            .firstOrNull;

        return _buildProviderCard(provider, linkedAccount);
      },
    );
  }

  Widget _buildProviderCard(
      SocialProvider provider, LinkedAccount? linkedAccount) {
    final isLinked = linkedAccount != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getProviderColor(provider).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getProviderIcon(provider),
                color: _getProviderColor(provider),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getProviderName(provider),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLinked
                        ? 'Привязан: ${linkedAccount.socialUsername ?? linkedAccount.socialId}'
                        : 'Не привязан',
                    style: TextStyle(
                      fontSize: 14,
                      color: isLinked ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            isLinked
                ? TextButton(
                    onPressed: () => _unlinkAccount(linkedAccount.id),
                    child: const Text(
                      'Отвязать',
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _linkAccount(provider),
                    child: const Text('Привязать'),
                  ),
          ],
        ),
      ),
    );
  }

  void _linkAccount(SocialProvider provider) {
    ref.read(socialAuthProvider.notifier).linkSocialAccount(provider);
  }

  void _unlinkAccount(String linkedAccountId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отвязать аккаунт'),
        content: const Text(
          'Вы уверены, что хотите отвязать этот аккаунт? '
          'Вы больше не сможете использовать его для входа.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref
                  .read(socialAuthProvider.notifier)
                  .unlinkSocialAccount(linkedAccountId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Отвязать'),
          ),
        ],
      ),
    );
  }

  Color _getProviderColor(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.telegram:
        return const Color(0xFF0088CC);
      case SocialProvider.yandex:
        return const Color(0xFFFFCC00);
      case SocialProvider.vk:
        return const Color(0xFF4C75A3);
      default:
        return Colors.grey;
    }
  }

  IconData _getProviderIcon(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.telegram:
        return Icons.telegram;
      case SocialProvider.yandex:
        return Icons.language;
      case SocialProvider.vk:
        return Icons.group;
      default:
        return Icons.login;
    }
  }

  String _getProviderName(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.telegram:
        return 'Telegram';
      case SocialProvider.yandex:
        return 'Яндекс';
      case SocialProvider.vk:
        return 'VK';
      default:
        return 'Неизвестно';
    }
  }
}
