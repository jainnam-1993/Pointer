import 'package:flutter_test/flutter_test.dart';
import 'package:pointer/services/aws_credential_service.dart';

void main() {
  group('AWSCredentials', () {
    test('fromJson creates valid credentials', () {
      final json = {
        'AccessKeyId': 'AKIAIOSFODNN7EXAMPLE',
        'SecretAccessKey': 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY',
        'SessionToken': 'FwoGZXIvYXdzEBY...',
        'Expiration': '2025-12-21T12:00:00Z',
      };

      final credentials = AWSCredentials.fromJson(json);

      expect(credentials.accessKeyId, 'AKIAIOSFODNN7EXAMPLE');
      expect(credentials.secretAccessKey, 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY');
      expect(credentials.sessionToken, 'FwoGZXIvYXdzEBY...');
      expect(credentials.expiration, DateTime.utc(2025, 12, 21, 12, 0, 0));
    });

    test('isExpired returns true for past expiration', () {
      final credentials = AWSCredentials(
        accessKeyId: 'test',
        secretAccessKey: 'test',
        sessionToken: 'test',
        expiration: DateTime.now().subtract(const Duration(hours: 1)),
      );

      expect(credentials.isExpired, isTrue);
    });

    test('isExpired returns false for future expiration', () {
      final credentials = AWSCredentials(
        accessKeyId: 'test',
        secretAccessKey: 'test',
        sessionToken: 'test',
        expiration: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(credentials.isExpired, isFalse);
    });

    test('needsRefresh returns true when within 5 minutes of expiry', () {
      final credentials = AWSCredentials(
        accessKeyId: 'test',
        secretAccessKey: 'test',
        sessionToken: 'test',
        expiration: DateTime.now().add(const Duration(minutes: 3)),
      );

      expect(credentials.needsRefresh, isTrue);
    });

    test('needsRefresh returns false when more than 5 minutes from expiry', () {
      final credentials = AWSCredentials(
        accessKeyId: 'test',
        secretAccessKey: 'test',
        sessionToken: 'test',
        expiration: DateTime.now().add(const Duration(minutes: 10)),
      );

      expect(credentials.needsRefresh, isFalse);
    });
  });

  group('AWSCredentialException', () {
    test('toString returns message only when no details', () {
      final exception = AWSCredentialException('Test error');
      expect(exception.toString(), 'Test error');
    });

    test('toString returns message with details when provided', () {
      final exception = AWSCredentialException('Test error', 'Additional info');
      expect(exception.toString(), 'Test error: Additional info');
    });

    test('message property is accessible', () {
      final exception = AWSCredentialException('Test message');
      expect(exception.message, 'Test message');
    });

    test('details property is accessible', () {
      final exception = AWSCredentialException('Error', 'Details here');
      expect(exception.details, 'Details here');
    });
  });

  group('AWSCredentialService - Singleton', () {
    test('instance returns same instance', () {
      final instance1 = AWSCredentialService.instance;
      final instance2 = AWSCredentialService.instance;

      expect(identical(instance1, instance2), isTrue);
    });
  });
}
