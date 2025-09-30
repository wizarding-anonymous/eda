import 'package:intl/intl.dart';

class Formatters {
  static final _phoneFormatter = RegExp(r'(\d{1})(\d{3})(\d{3})(\d{2})(\d{2})');
  static final _currencyFormatter = NumberFormat.currency(
    locale: 'ru_RU',
    symbol: '₽',
    decimalDigits: 0,
  );
  static final _dateFormatter = DateFormat('dd.MM.yyyy', 'ru_RU');
  static final _timeFormatter = DateFormat('HH:mm', 'ru_RU');
  static final _dateTimeFormatter = DateFormat('dd.MM.yyyy HH:mm', 'ru_RU');

  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length == 11 && cleanPhone.startsWith('7')) {
      return cleanPhone.replaceAllMapped(
        _phoneFormatter,
        (match) => '+7 (${match[2]}) ${match[3]}-${match[4]}-${match[5]}',
      );
    } else if (cleanPhone.length == 11 && cleanPhone.startsWith('8')) {
      final phoneWith7 = '7${cleanPhone.substring(1)}';
      return phoneWith7.replaceAllMapped(
        _phoneFormatter,
        (match) => '+7 (${match[2]}) ${match[3]}-${match[4]}-${match[5]}',
      );
    }
    return phone;
  }

  static String formatCurrency(double amount) {
    return _currencyFormatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return _dateFormatter.format(date);
  }

  static String formatTime(DateTime time) {
    return _timeFormatter.format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return _dateTimeFormatter.format(dateTime);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '$hoursч $minutesмин';
    } else {
      return '$minutesмин';
    }
  }

  static String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()} м';
    } else {
      return '${distanceKm.toStringAsFixed(1)} км';
    }
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String formatReservationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает подтверждения';
      case 'confirmed':
        return 'Подтверждено';
      case 'cancelled':
        return 'Отменено';
      case 'noshow':
        return 'Не явился';
      case 'completed':
        return 'Завершено';
      default:
        return status;
    }
  }

  static String formatPaymentStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Ожидает оплаты';
      case 'completed':
        return 'Оплачено';
      case 'failed':
        return 'Ошибка оплаты';
      case 'refunded':
        return 'Возвращено';
      default:
        return status;
    }
  }
}
