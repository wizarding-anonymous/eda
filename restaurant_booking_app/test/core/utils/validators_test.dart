import 'package:flutter_test/flutter_test.dart';
import 'package:restaurant_booking_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('Phone validation', () {
      test('should validate correct Russian phone numbers', () {
        // 11 digits starting with 7
        expect(Validators.isValidPhone('71234567890'), isTrue);
        expect(Validators.isValidPhone('+71234567890'), isTrue);
        expect(Validators.isValidPhone('+7 (123) 456-78-90'), isTrue);
        
        // 11 digits starting with 8
        expect(Validators.isValidPhone('81234567890'), isTrue);
        expect(Validators.isValidPhone('8 (123) 456-78-90'), isTrue);
        
        // 10 digits without country code
        expect(Validators.isValidPhone('1234567890'), isTrue);
        expect(Validators.isValidPhone('(123) 456-78-90'), isTrue);
      });

      test('should reject invalid phone numbers', () {
        // Too short
        expect(Validators.isValidPhone('123456789'), isFalse);
        
        // Too long
        expect(Validators.isValidPhone('712345678901'), isFalse);
        
        // Wrong country code
        expect(Validators.isValidPhone('91234567890'), isFalse);
        
        // Empty
        expect(Validators.isValidPhone(''), isFalse);
        
        // Only letters
        expect(Validators.isValidPhone('abcdefghij'), isFalse);
      });

      test('should normalize phone numbers correctly', () {
        expect(Validators.normalizePhone('81234567890'), equals('+71234567890'));
        expect(Validators.normalizePhone('71234567890'), equals('+71234567890'));
        expect(Validators.normalizePhone('1234567890'), equals('+71234567890'));
        expect(Validators.normalizePhone('+71234567890'), equals('+71234567890'));
        expect(Validators.normalizePhone('8 (123) 456-78-90'), equals('+71234567890'));
        expect(Validators.normalizePhone('+7 (123) 456-78-90'), equals('+71234567890'));
      });

      test('should return original phone if cannot normalize', () {
        expect(Validators.normalizePhone('123'), equals('123'));
        expect(Validators.normalizePhone('invalid'), equals('invalid'));
      });
    });

    group('OTP validation', () {
      test('should validate correct OTP codes', () {
        expect(Validators.isValidOTP('123456'), isTrue);
        expect(Validators.isValidOTP('000000'), isTrue);
        expect(Validators.isValidOTP('999999'), isTrue);
      });

      test('should reject invalid OTP codes', () {
        // Too short
        expect(Validators.isValidOTP('12345'), isFalse);
        
        // Too long
        expect(Validators.isValidOTP('1234567'), isFalse);
        
        // Contains letters
        expect(Validators.isValidOTP('12345a'), isFalse);
        
        // Empty
        expect(Validators.isValidOTP(''), isFalse);
        
        // Special characters
        expect(Validators.isValidOTP('123-45'), isFalse);
      });
    });

    group('Validation messages', () {
      test('should return correct phone validation messages', () {
        expect(Validators.validatePhone(null), equals('Номер телефона обязателен'));
        expect(Validators.validatePhone(''), equals('Номер телефона обязателен'));
        expect(Validators.validatePhone('123'), equals('Введите корректный номер телефона'));
        expect(Validators.validatePhone('71234567890'), isNull);
      });

      test('should return correct OTP validation messages', () {
        expect(Validators.validateOTP(null), equals('Код подтверждения обязателен'));
        expect(Validators.validateOTP(''), equals('Код подтверждения обязателен'));
        expect(Validators.validateOTP('123'), equals('Код должен содержать 6 цифр'));
        expect(Validators.validateOTP('123456'), isNull);
      });
    });

    group('Email validation', () {
      test('should validate correct email addresses', () {
        expect(Validators.isValidEmail('test@example.com'), isTrue);
        expect(Validators.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(Validators.isValidEmail('test+tag@gmail.com'), isTrue);
      });

      test('should reject invalid email addresses', () {
        expect(Validators.isValidEmail('invalid'), isFalse);
        expect(Validators.isValidEmail('test@'), isFalse);
        expect(Validators.isValidEmail('@domain.com'), isFalse);
        expect(Validators.isValidEmail(''), isFalse);
      });
    });

    group('Password validation', () {
      test('should validate strong passwords', () {
        expect(Validators.isValidPassword('Password123'), isTrue);
        expect(Validators.isValidPassword('MyStr0ngP@ss'), isTrue);
      });

      test('should reject weak passwords', () {
        // Too short
        expect(Validators.isValidPassword('Pass1'), isFalse);
        
        // No uppercase
        expect(Validators.isValidPassword('password123'), isFalse);
        
        // No lowercase
        expect(Validators.isValidPassword('PASSWORD123'), isFalse);
        
        // No digits
        expect(Validators.isValidPassword('Password'), isFalse);
        
        // Empty
        expect(Validators.isValidPassword(''), isFalse);
      });
    });
  });
}