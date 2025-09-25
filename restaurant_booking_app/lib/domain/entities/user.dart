import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String? phone;
  final String? email;
  final String name;
  final String? avatarUrl;
  final double rating;
  final UserPreferences preferences;
  final DateTime createdAt;

  const User({
    required this.id,
    this.phone,
    this.email,
    required this.name,
    this.avatarUrl,
    required this.rating,
    required this.preferences,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      email: json['email'],
      name: json['name'],
      avatarUrl: json['avatar_url'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      preferences: UserPreferences.fromJson(json['preferences'] ?? {}),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'rating': rating,
      'preferences': preferences.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        phone,
        email,
        name,
        avatarUrl,
        rating,
        preferences,
        createdAt,
      ];
}

class UserPreferences extends Equatable {
  final String language;
  final ThemeMode theme;
  final NotificationSettings notifications;
  final String? defaultCity;

  const UserPreferences({
    required this.language,
    required this.theme,
    required this.notifications,
    this.defaultCity,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      language: json['language'] ?? 'ru',
      theme: ThemeMode.values.firstWhere(
        (e) => e.name == json['theme'],
        orElse: () => ThemeMode.system,
      ),
      notifications: NotificationSettings.fromJson(json['notifications'] ?? {}),
      defaultCity: json['default_city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'theme': theme.name,
      'notifications': notifications.toJson(),
      'default_city': defaultCity,
    };
  }

  @override
  List<Object?> get props => [language, theme, notifications, defaultCity];
}

enum ThemeMode { light, dark, system }

class NotificationSettings extends Equatable {
  final bool pushEnabled;
  final bool smsEnabled;
  final bool emailEnabled;
  final bool marketingEnabled;
  final TimeOfDay? quietHoursStart;
  final TimeOfDay? quietHoursEnd;

  const NotificationSettings({
    required this.pushEnabled,
    required this.smsEnabled,
    required this.emailEnabled,
    required this.marketingEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['push_enabled'] ?? true,
      smsEnabled: json['sms_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      marketingEnabled: json['marketing_enabled'] ?? false,
      quietHoursStart: json['quiet_hours_start'] != null
          ? TimeOfDay.fromJson(json['quiet_hours_start'])
          : null,
      quietHoursEnd: json['quiet_hours_end'] != null
          ? TimeOfDay.fromJson(json['quiet_hours_end'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'sms_enabled': smsEnabled,
      'email_enabled': emailEnabled,
      'marketing_enabled': marketingEnabled,
      'quiet_hours_start': quietHoursStart?.toJson(),
      'quiet_hours_end': quietHoursEnd?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
        pushEnabled,
        smsEnabled,
        emailEnabled,
        marketingEnabled,
        quietHoursStart,
        quietHoursEnd,
      ];
}

class TimeOfDay extends Equatable {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});

  factory TimeOfDay.fromJson(Map<String, dynamic> json) {
    return TimeOfDay(
      hour: json['hour'],
      minute: json['minute'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
    };
  }

  @override
  List<Object> get props => [hour, minute];
}