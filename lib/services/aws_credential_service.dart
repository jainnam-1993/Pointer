import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:otp/otp.dart';

/// AWS credentials returned from the auth endpoint
class AWSCredentials {
  final String accessKeyId;
  final String secretAccessKey;
  final String sessionToken;
  final DateTime expiration;

  AWSCredentials({
    required this.accessKeyId,
    required this.secretAccessKey,
    required this.sessionToken,
    required this.expiration,
  });

  bool get isExpired => DateTime.now().isAfter(expiration);

  /// Buffer of 5 minutes before actual expiry to avoid edge cases
  bool get needsRefresh =>
      DateTime.now().isAfter(expiration.subtract(const Duration(minutes: 5)));

  factory AWSCredentials.fromJson(Map<String, dynamic> json) {
    return AWSCredentials(
      accessKeyId: json['AccessKeyId'] as String,
      secretAccessKey: json['SecretAccessKey'] as String,
      sessionToken: json['SessionToken'] as String,
      expiration: DateTime.parse(json['Expiration'] as String),
    );
  }
}

/// Service for managing AWS credentials via TOTP authentication.
///
/// Flow:
/// 1. Setup (one-time): User enters OTP → API returns TOTP secret → cached securely
/// 2. Runtime: Generate TOTP from secret → API returns AWS credentials
class AWSCredentialService {
  static final AWSCredentialService _instance = AWSCredentialService._internal();
  static AWSCredentialService get instance => _instance;

  AWSCredentialService._internal();

  // Secure storage for TOTP secret
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Storage keys
  static const String _secretKey = 'aws_totp_secret';
  static const String _credentialsCacheKey = 'aws_credentials_cache';

  // API endpoints
  static const String _secretEndpoint =
      'https://l35p6w7qe7.execute-api.us-east-1.amazonaws.com/prod/setup';
  static const String _credentialsEndpoint =
      'https://l35p6w7qe7.execute-api.us-east-1.amazonaws.com/prod/auth';

  // In-memory credential cache
  AWSCredentials? _cachedCredentials;

  /// Check if TTS is configured (has TOTP secret stored)
  Future<bool> isConfigured() async {
    final secret = await _secureStorage.read(key: _secretKey);
    return secret != null && secret.isNotEmpty;
  }

  /// Setup TTS access with a one-time OTP.
  ///
  /// This calls an API that validates the OTP and returns the TOTP secret
  /// which is then stored securely for future use.
  ///
  /// Returns true if setup was successful, throws on error.
  Future<bool> setupWithOTP(String otp) async {
    try {
      final response = await http.post(
        Uri.parse(_secretEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': otp}),
      );

      if (response.statusCode != 200) {
        throw AWSCredentialException(
          'Failed to validate OTP: ${response.statusCode}',
          response.body,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final secret = data['secret'] as String?;

      if (secret == null || secret.isEmpty) {
        throw AWSCredentialException('Invalid response: no secret returned');
      }

      // Store secret securely
      await _secureStorage.write(key: _secretKey, value: secret);

      // Clear any cached credentials to force refresh
      _cachedCredentials = null;
      await _secureStorage.delete(key: _credentialsCacheKey);

      return true;
    } on http.ClientException catch (e) {
      throw AWSCredentialException('Network error during setup', e.toString());
    }
  }

  /// Clear the stored TOTP secret and cached credentials.
  /// Use this to "log out" of TTS access.
  Future<void> clearConfiguration() async {
    await _secureStorage.delete(key: _secretKey);
    await _secureStorage.delete(key: _credentialsCacheKey);
    _cachedCredentials = null;
  }

  /// Get AWS credentials for Polly API access.
  ///
  /// This automatically:
  /// 1. Returns cached credentials if still valid
  /// 2. Generates a TOTP code from the stored secret
  /// 3. Calls the auth API to get fresh credentials
  /// 4. Caches the new credentials
  ///
  /// Throws [AWSCredentialException] if not configured or on error.
  Future<AWSCredentials> getCredentials() async {
    // Return cached if valid
    if (_cachedCredentials != null && !_cachedCredentials!.needsRefresh) {
      return _cachedCredentials!;
    }

    // Check for stored secret
    final secret = await _secureStorage.read(key: _secretKey);
    if (secret == null || secret.isEmpty) {
      throw AWSCredentialException(
        'TTS not configured',
        'Please configure TTS access in Settings first.',
      );
    }

    // Generate TOTP code
    final totpCode = _generateTOTP(secret);

    // Fetch credentials from API
    try {
      final response = await http.post(
        Uri.parse(_credentialsEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'code': totpCode}),
      );

      if (response.statusCode != 200) {
        throw AWSCredentialException(
          'Failed to get credentials: ${response.statusCode}',
          response.body,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final credentials = AWSCredentials.fromJson(data);

      // Cache credentials
      _cachedCredentials = credentials;
      await _cacheCredentials(credentials);

      return credentials;
    } on http.ClientException catch (e) {
      // Try to use cached credentials from storage if network fails
      final cached = await _loadCachedCredentials();
      if (cached != null && !cached.isExpired) {
        _cachedCredentials = cached;
        return cached;
      }
      throw AWSCredentialException('Network error', e.toString());
    }
  }

  /// Generate a TOTP code from the secret.
  /// Uses standard TOTP: SHA1, 30-second window, 6 digits.
  String _generateTOTP(String secret) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return OTP.generateTOTPCodeString(
      secret,
      now,
      algorithm: Algorithm.SHA1,
      interval: 30,
      length: 6,
      isGoogle: true,
    );
  }

  /// Cache credentials to secure storage for offline/backup use.
  Future<void> _cacheCredentials(AWSCredentials credentials) async {
    final json = jsonEncode({
      'AccessKeyId': credentials.accessKeyId,
      'SecretAccessKey': credentials.secretAccessKey,
      'SessionToken': credentials.sessionToken,
      'Expiration': credentials.expiration.toIso8601String(),
    });
    await _secureStorage.write(key: _credentialsCacheKey, value: json);
  }

  /// Load cached credentials from secure storage.
  Future<AWSCredentials?> _loadCachedCredentials() async {
    final cached = await _secureStorage.read(key: _credentialsCacheKey);
    if (cached == null) return null;

    try {
      final data = jsonDecode(cached) as Map<String, dynamic>;
      return AWSCredentials.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}

/// Exception for AWS credential operations.
class AWSCredentialException implements Exception {
  final String message;
  final String? details;

  AWSCredentialException(this.message, [this.details]);

  @override
  String toString() => details != null ? '$message: $details' : message;
}
