import 'package:flutter/material.dart';
import '../../domain/entities/auth.dart';

class SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback onPressed;
  final bool isLoading;

  const SocialLoginButton({
    super.key,
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getProviderColor(provider),
          foregroundColor: _getProviderTextColor(provider),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getProviderIcon(provider),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getProviderText(provider),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
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

  Color _getProviderTextColor(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.telegram:
      case SocialProvider.vk:
        return Colors.white;
      case SocialProvider.yandex:
        return Colors.black;
      default:
        return Colors.white;
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

  String _getProviderText(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.telegram:
        return 'Войти через Telegram';
      case SocialProvider.yandex:
        return 'Войти через Яндекс';
      case SocialProvider.vk:
        return 'Войти через VK';
      default:
        return 'Войти';
    }
  }
}
