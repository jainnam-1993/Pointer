import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'aws_credential_service.dart';

/// TTS playback state
enum TTSPlaybackState {
  idle,
  loading,
  playing,
  paused,
  completed,
  error,
}

/// Available Polly neural voices
enum PollyVoice {
  joanna('Joanna', 'US English, Female'),
  matthew('Matthew', 'US English, Male'),
  amy('Amy', 'British English, Female'),
  brian('Brian', 'British English, Male');

  final String id;
  final String description;

  const PollyVoice(this.id, this.description);
}

/// Service for text-to-speech using AWS Polly.
///
/// Converts article text to speech via AWS Polly API and plays
/// the resulting audio using just_audio.
class TTSService {
  static TTSService? _instance;
  AudioPlayer? _player;

  final _stateController = StreamController<TTSPlaybackState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration?>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  String? _currentArticleId;
  PollyVoice _selectedVoice = PollyVoice.joanna;

  // Polly API config
  static const String _region = 'us-east-1';
  static const String _service = 'polly';
  static const String _endpoint = 'https://polly.$_region.amazonaws.com';

  TTSService._();

  static TTSService get instance {
    _instance ??= TTSService._();
    return _instance!;
  }

  /// Stream of playback state changes
  Stream<TTSPlaybackState> get stateStream => _stateController.stream;

  /// Stream of playback position updates
  Stream<Duration> get positionStream => _positionController.stream;

  /// Stream of total duration (once known)
  Stream<Duration?> get durationStream => _durationController.stream;

  /// Stream of error messages
  Stream<String> get errorStream => _errorController.stream;

  /// Currently playing article ID
  String? get currentArticleId => _currentArticleId;

  /// Selected voice
  PollyVoice get selectedVoice => _selectedVoice;

  /// Set voice preference
  void setVoice(PollyVoice voice) {
    _selectedVoice = voice;
  }

  /// Current playback state
  TTSPlaybackState get currentState {
    if (_player == null) return TTSPlaybackState.idle;
    if (_player!.processingState == ProcessingState.loading ||
        _player!.processingState == ProcessingState.buffering) {
      return TTSPlaybackState.loading;
    }
    if (_player!.playing) return TTSPlaybackState.playing;
    if (_player!.processingState == ProcessingState.completed) {
      return TTSPlaybackState.completed;
    }
    return TTSPlaybackState.paused;
  }

  /// Initialize audio player
  Future<void> initialize() async {
    _player = AudioPlayer();

    _player!.playerStateStream.listen((state) {
      _stateController.add(currentState);
    });

    _player!.positionStream.listen((position) {
      _positionController.add(position);
    });

    _player!.durationStream.listen((duration) {
      _durationController.add(duration);
    });

    debugPrint('TTSService: Initialized');
  }

  /// Synthesize and play text for an article
  Future<void> synthesizeAndPlay(String articleId, String text) async {
    if (_player == null) await initialize();

    try {
      _stateController.add(TTSPlaybackState.loading);
      _currentArticleId = articleId;

      // Get AWS credentials
      final credentials = await AWSCredentialService.instance.getCredentials();

      // Strip markdown and clean text
      final cleanText = _stripMarkdown(text);

      // Call Polly API
      final audioBytes = await _synthesizeSpeech(cleanText, credentials);

      // Write to temp file
      final tempDir = await getTemporaryDirectory();
      final audioFile = File('${tempDir.path}/tts_$articleId.mp3');
      await audioFile.writeAsBytes(audioBytes);

      // Play the audio
      await _player!.setFilePath(audioFile.path);
      await _player!.play();
    } catch (e) {
      debugPrint('TTSService: Error - $e');
      _stateController.add(TTSPlaybackState.error);
      _errorController.add(e.toString());
    }
  }

  /// Call AWS Polly SynthesizeSpeech API
  Future<Uint8List> _synthesizeSpeech(
    String text,
    AWSCredentials credentials,
  ) async {
    final uri = Uri.parse('$_endpoint/v1/speech');
    final body = jsonEncode({
      'OutputFormat': 'mp3',
      'Text': text,
      'TextType': 'text',
      'VoiceId': _selectedVoice.id,
      'Engine': 'neural',
    });

    final headers = await _signRequest(
      method: 'POST',
      uri: uri,
      body: body,
      credentials: credentials,
    );

    final client = HttpClient();
    try {
      final request = await client.postUrl(uri);

      // Set headers
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      // Write body
      request.write(body);

      // Get response
      final response = await request.close();

      if (response.statusCode != 200) {
        final errorBody = await response.transform(utf8.decoder).join();
        throw Exception('Polly API error ${response.statusCode}: $errorBody');
      }

      // Read audio bytes
      final bytes = await response.fold<List<int>>(
        [],
        (previous, element) => previous..addAll(element),
      );

      return Uint8List.fromList(bytes);
    } finally {
      client.close();
    }
  }

  /// Sign request with AWS SigV4
  Future<Map<String, String>> _signRequest({
    required String method,
    required Uri uri,
    required String body,
    required AWSCredentials credentials,
  }) async {
    final now = DateTime.now().toUtc();
    final dateStamp = _formatDate(now);
    final amzDate = _formatAmzDate(now);

    final host = uri.host;
    final canonicalUri = uri.path.isEmpty ? '/' : uri.path;
    final canonicalQuerystring = '';

    // Hash payload
    final payloadHash = sha256.convert(utf8.encode(body)).toString();

    // Canonical headers
    final canonicalHeaders = 'content-type:application/json\n'
        'host:$host\n'
        'x-amz-date:$amzDate\n'
        'x-amz-security-token:${credentials.sessionToken}\n';

    final signedHeaders =
        'content-type;host;x-amz-date;x-amz-security-token';

    // Canonical request
    final canonicalRequest = '$method\n'
        '$canonicalUri\n'
        '$canonicalQuerystring\n'
        '$canonicalHeaders\n'
        '$signedHeaders\n'
        '$payloadHash';

    // String to sign
    final algorithm = 'AWS4-HMAC-SHA256';
    final credentialScope = '$dateStamp/$_region/$_service/aws4_request';
    final stringToSign = '$algorithm\n'
        '$amzDate\n'
        '$credentialScope\n'
        '${sha256.convert(utf8.encode(canonicalRequest))}';

    // Calculate signature
    final signingKey = _getSignatureKey(
      credentials.secretAccessKey,
      dateStamp,
      _region,
      _service,
    );
    final signature = Hmac(sha256, signingKey)
        .convert(utf8.encode(stringToSign))
        .toString();

    // Authorization header
    final authorization = '$algorithm '
        'Credential=${credentials.accessKeyId}/$credentialScope, '
        'SignedHeaders=$signedHeaders, '
        'Signature=$signature';

    return {
      'Content-Type': 'application/json',
      'X-Amz-Date': amzDate,
      'X-Amz-Security-Token': credentials.sessionToken,
      'Authorization': authorization,
    };
  }

  List<int> _getSignatureKey(
    String key,
    String dateStamp,
    String regionName,
    String serviceName,
  ) {
    final kDate = Hmac(sha256, utf8.encode('AWS4$key'))
        .convert(utf8.encode(dateStamp))
        .bytes;
    final kRegion =
        Hmac(sha256, kDate).convert(utf8.encode(regionName)).bytes;
    final kService =
        Hmac(sha256, kRegion).convert(utf8.encode(serviceName)).bytes;
    final kSigning =
        Hmac(sha256, kService).convert(utf8.encode('aws4_request')).bytes;
    return kSigning;
  }

  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}'
        '${date.month.toString().padLeft(2, '0')}'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatAmzDate(DateTime date) {
    return '${_formatDate(date)}T'
        '${date.hour.toString().padLeft(2, '0')}'
        '${date.minute.toString().padLeft(2, '0')}'
        '${date.second.toString().padLeft(2, '0')}Z';
  }

  /// Strip markdown formatting from text for TTS
  String _stripMarkdown(String markdown) {
    var text = markdown;

    // Remove headers
    text = text.replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '');

    // Remove images FIRST (before links, since images contain link syntax)
    text = text.replaceAll(RegExp(r'!\[.*?\]\(.+?\)'), '');

    // Remove bold/italic - use replaceAllMapped for capture groups
    text = text.replaceAllMapped(
      RegExp(r'\*\*(.+?)\*\*'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'\*(.+?)\*'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'__(.+?)__'),
      (m) => m.group(1) ?? '',
    );
    text = text.replaceAllMapped(
      RegExp(r'_(.+?)_'),
      (m) => m.group(1) ?? '',
    );

    // Remove links but keep text
    text = text.replaceAllMapped(
      RegExp(r'\[(.+?)\]\(.+?\)'),
      (m) => m.group(1) ?? '',
    );

    // Remove blockquote markers
    text = text.replaceAll(RegExp(r'^>\s*', multiLine: true), '');

    // Remove horizontal rules
    text = text.replaceAll(RegExp(r'^[-*_]{3,}$', multiLine: true), '');

    // Remove code blocks
    text = text.replaceAll(RegExp(r'```[\s\S]*?```'), '');
    text = text.replaceAllMapped(
      RegExp(r'`(.+?)`'),
      (m) => m.group(1) ?? '',
    );

    // Remove list markers
    text = text.replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '');
    text = text.replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '');

    // Clean up multiple newlines
    text = text.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return text.trim();
  }

  /// Pause playback
  Future<void> pause() async {
    await _player?.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _player?.play();
  }

  /// Stop playback
  Future<void> stop() async {
    await _player?.stop();
    _currentArticleId = null;
    _stateController.add(TTSPlaybackState.idle);
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _player?.seek(position);
  }

  /// Seek forward by seconds
  Future<void> seekForward({int seconds = 10}) async {
    final current = _player?.position ?? Duration.zero;
    final duration = _player?.duration ?? Duration.zero;
    final newPosition = current + Duration(seconds: seconds);
    await seek(newPosition > duration ? duration : newPosition);
  }

  /// Seek backward by seconds
  Future<void> seekBackward({int seconds = 10}) async {
    final current = _player?.position ?? Duration.zero;
    final newPosition = current - Duration(seconds: seconds);
    await seek(newPosition.isNegative ? Duration.zero : newPosition);
  }

  /// Get current position
  Duration get position => _player?.position ?? Duration.zero;

  /// Get total duration
  Duration? get duration => _player?.duration;

  /// Is currently playing
  bool get isPlaying => _player?.playing ?? false;

  /// Dispose resources
  Future<void> dispose() async {
    await _player?.dispose();
    _player = null;
    await _stateController.close();
    await _positionController.close();
    await _durationController.close();
    await _errorController.close();
  }
}
