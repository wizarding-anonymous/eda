import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:restaurant_booking_app/domain/usecases/auth/login_with_phone_usecase.dart';
import 'package:restaurant_booking_app/domain/repositories/auth_repository.dart';
import 'package:restaurant_booking_app/domain/entities/auth.dart';
import 'package:restaurant_booking_app/domain/entities/user.dart';
import 'package:restaurant_booking_app/core/network/api_result.dart';
import 'package:restaurant_booking_app/core/error/failures.dart';
import 'package:restaurant_booking_app/core/utils/validators.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('SMS Authentication Integration Tests', () {
    late LoginWithPhoneUseCase loginWithPhoneUseCase;
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      loginWithPhoneUseCase = LoginWithPhoneUseCase(mockAuthRepository);
    });

    group('Complete SMS Authentication Flow', () {
      const testPhone = '+79123456789';
      const testOtpCode = '123456';

      test('should complete full SMS authentication flow successfully', () async {
        // Step 1: Validate phone number
        expect(Validators.isValidPhone(testPhone), isTrue);
        final normalizedPhone = Validators.normalizePhone(testPhone);
        expect(normalizedPhone, equals(testPhone));

        // Step 2: Send SMS code
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.success(null));

        final smsResult = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(smsResult.isSuccess, isTrue);
        verify(mockAuthRepository.sendSmsCode(testPhone));

        // Step 3: Validate OTP
        expect(Validators.isValidOTP(testOtpCode), isTrue);

        // Step 4: Verify OTP and authenticate
        final testUser = User(
          id: 'user_123',
          name: 'Test User',
          phone: testPhone,
          rating: 4.5,
          preferences: const UserPreferences(
            language: 'ru',
            theme: ThemeMode.system,
            notifications: NotificationSettings(
              pushEnabled: true,
              smsEnabled: true,
              emailEnabled: true,
              marketingEnabled: false,
            ),
          ),
          createdAt: DateTime.now(),
        );

        final authResult = AuthResult.success(
          user: testUser,
          accessToken: 'jwt_access_token',
          refreshToken: 'jwt_refresh_token',
        );

        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => ApiResult.success(authResult));

        final otpResult = await loginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode);
        expect(otpResult.isSuccess, isTrue);
        expect(otpResult.data?.isSuccess, isTrue);
        expect(otpResult.data?.user?.phone, equals(testPhone));
        expect(otpResult.data?.accessToken, equals('jwt_access_token'));
        verify(mockAuthRepository.verifyOtp(testPhone, testOtpCode));
      });

      test('should handle invalid phone number in flow', () async {
        // Step 1: Try with invalid phone
        const invalidPhone = '123';
        expect(Validators.isValidPhone(invalidPhone), isFalse);

        // Step 2: Attempt to send SMS with invalid phone
        when(mockAuthRepository.sendSmsCode(invalidPhone))
            .thenAnswer((_) async => const ApiResult.failure(
              ValidationFailure('Invalid phone number format'),
            ));

        final result = await loginWithPhoneUseCase.sendSmsCode(invalidPhone);
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, equals('Invalid phone number format'));
      });

      test('should handle invalid OTP in flow', () async {
        // Step 1: Valid phone, successful SMS sending
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.success(null));

        final smsResult = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(smsResult.isSuccess, isTrue);

        // Step 2: Try with invalid OTP
        const invalidOtp = '12345'; // Too short
        expect(Validators.isValidOTP(invalidOtp), isFalse);

        when(mockAuthRepository.verifyOtp(testPhone, invalidOtp))
            .thenAnswer((_) async => const ApiResult.failure(
              ValidationFailure('Invalid OTP code'),
            ));

        final otpResult = await loginWithPhoneUseCase.verifyOtp(testPhone, invalidOtp);
        expect(otpResult.isSuccess, isFalse);
        expect(otpResult.failure?.message, equals('Invalid OTP code'));
      });

      test('should handle network errors during SMS flow', () async {
        // Step 1: Network error during SMS sending
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(
              NetworkFailure('Network connection failed'),
            ));

        final smsResult = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(smsResult.isSuccess, isFalse);
        expect(smsResult.failure?.message, equals('Network connection failed'));

        // Step 2: Network error during OTP verification
        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(
              NetworkFailure('Connection timeout'),
            ));

        final otpResult = await loginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode);
        expect(otpResult.isSuccess, isFalse);
        expect(otpResult.failure?.message, equals('Connection timeout'));
      });

      test('should handle expired OTP scenario', () async {
        // Step 1: Successful SMS sending
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.success(null));

        final smsResult = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(smsResult.isSuccess, isTrue);

        // Step 2: OTP expired during verification
        when(mockAuthRepository.verifyOtp(testPhone, testOtpCode))
            .thenAnswer((_) async => const ApiResult.failure(
              ValidationFailure('OTP code has expired'),
            ));

        final otpResult = await loginWithPhoneUseCase.verifyOtp(testPhone, testOtpCode);
        expect(otpResult.isSuccess, isFalse);
        expect(otpResult.failure?.message, equals('OTP code has expired'));
      });

      test('should handle rate limiting scenario', () async {
        // Step 1: Rate limiting during SMS sending
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(
              ServerFailure('Too many SMS requests. Please try again later.'),
            ));

        final result = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(result.isSuccess, isFalse);
        expect(result.failure?.message, contains('Too many SMS requests'));
      });
    });

    group('Phone Number Normalization Integration', () {
      test('should normalize various phone formats correctly', () {
        final testCases = {
          '89123456789': '+79123456789',
          '71234567890': '+71234567890',
          '1234567890': '+71234567890',
          '+79123456789': '+79123456789',
          '8 (912) 345-67-89': '+79123456789',
          '+7 (123) 456-78-90': '+71234567890',
        };

        for (final entry in testCases.entries) {
          final input = entry.key;
          final expected = entry.value;
          
          expect(Validators.normalizePhone(input), equals(expected),
              reason: 'Failed to normalize $input to $expected');
        }
      });

      test('should validate normalized phone numbers', () {
        const phoneNumbers = [
          '+79123456789',
          '+71234567890',
          '89123456789',
          '71234567890',
          '1234567890',
        ];

        for (final phone in phoneNumbers) {
          expect(Validators.isValidPhone(phone), isTrue,
              reason: 'Phone $phone should be valid');
          
          final normalized = Validators.normalizePhone(phone);
          expect(normalized.startsWith('+7'), isTrue,
              reason: 'Normalized phone $normalized should start with +7');
          expect(normalized.length, equals(12),
              reason: 'Normalized phone $normalized should be 12 characters long');
        }
      });
    });

    group('OTP Validation Integration', () {
      test('should validate various OTP formats', () {
        const validOtpCodes = [
          '123456',
          '000000',
          '999999',
          '654321',
        ];

        for (final otp in validOtpCodes) {
          expect(Validators.isValidOTP(otp), isTrue,
              reason: 'OTP $otp should be valid');
        }
      });

      test('should reject invalid OTP formats', () {
        const invalidOtpCodes = [
          '12345',    // Too short
          '1234567',  // Too long
          '12345a',   // Contains letters
          '123-45',   // Contains special characters
          '',         // Empty
          '12 34 56', // Contains spaces
        ];

        for (final otp in invalidOtpCodes) {
          expect(Validators.isValidOTP(otp), isFalse,
              reason: 'OTP $otp should be invalid');
        }
      });
    });

    group('Error Handling Integration', () {
      test('should handle multiple consecutive SMS requests', () async {
        // First request succeeds
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.success(null));

        final firstResult = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(firstResult.isSuccess, isTrue);

        // Second request gets rate limited
        when(mockAuthRepository.sendSmsCode(testPhone))
            .thenAnswer((_) async => const ApiResult.failure(
              ServerFailure('Please wait before requesting another code'),
            ));

        final secondResult = await loginWithPhoneUseCase.sendSmsCode(testPhone);
        expect(secondResult.isSuccess, isFalse);
        expect(secondResult.failure?.message, contains('Please wait'));
      });

      test('should handle multiple failed OTP attempts', () async {
        const wrongOtp = '000000';
        
        // First attempt fails
        when(mockAuthRepository.verifyOtp(testPhone, wrongOtp))
            .thenAnswer((_) async => const ApiResult.failure(
              ValidationFailure('Invalid OTP code'),
            ));

        final firstAttempt = await loginWithPhoneUseCase.verifyOtp(testPhone, wrongOtp);
        expect(firstAttempt.isSuccess, isFalse);

        // Multiple attempts lead to blocking
        when(mockAuthRepository.verifyOtp(testPhone, wrongOtp))
            .thenAnswer((_) async => const ApiResult.failure(
              ValidationFailure('Too many failed attempts. Please request a new code.'),
            ));

        final blockedAttempt = await loginWithPhoneUseCase.verifyOtp(testPhone, wrongOtp);
        expect(blockedAttempt.isSuccess, isFalse);
        expect(blockedAttempt.failure?.message, contains('Too many failed attempts'));
      });
    });
  });
}