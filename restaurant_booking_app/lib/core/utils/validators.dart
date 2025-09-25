class Validators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w\-\.+]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(email);
  }

  static bool isValidPhone(String phone) {
    // Russian phone number validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Accept formats: 71234567890, 81234567890, 1234567890
    if (cleanPhone.length == 11) {
      return cleanPhone.startsWith('7') || cleanPhone.startsWith('8');
    } else if (cleanPhone.length == 10) {
      // 10 digits without country code
      return true;
    }
    
    return false;
  }

  static bool isValidOTP(String otp) {
    return RegExp(r'^\d{6}$').hasMatch(otp);
  }

  /// Normalize phone number to +7XXXXXXXXXX format
  static String normalizePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 11) {
      if (cleanPhone.startsWith('8')) {
        return '+7${cleanPhone.substring(1)}';
      } else if (cleanPhone.startsWith('7')) {
        return '+$cleanPhone';
      }
    } else if (cleanPhone.length == 10) {
      return '+7$cleanPhone';
    }
    
    return phone; // Return original if can't normalize
  }

  static bool isValidPartySize(int size) {
    return size >= 1 && size <= 20;
  }

  static bool isValidPassword(String password) {
    // At least 8 characters, one uppercase, one lowercase, one digit
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password);
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email обязателен';
    }
    if (!isValidEmail(value)) {
      return 'Введите корректный email';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Номер телефона обязателен';
    }
    if (!isValidPhone(value)) {
      return 'Введите корректный номер телефона';
    }
    return null;
  }

  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'Код подтверждения обязателен';
    }
    if (!isValidOTP(value)) {
      return 'Код должен содержать 6 цифр';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пароль обязателен';
    }
    if (!isValidPassword(value)) {
      return 'Пароль должен содержать минимум 8 символов, включая заглавную букву, строчную букву и цифру';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Имя обязательно';
    }
    if (value.length < 2) {
      return 'Имя должно содержать минимум 2 символа';
    }
    return null;
  }

  static String? validatePartySize(String? value) {
    if (value == null || value.isEmpty) {
      return 'Количество гостей обязательно';
    }
    final size = int.tryParse(value);
    if (size == null || !isValidPartySize(size)) {
      return 'Количество гостей должно быть от 1 до 20';
    }
    return null;
  }
}