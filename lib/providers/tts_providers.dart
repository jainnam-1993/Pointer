/// TTS providers - Text-to-speech service and playback state
///
/// Manages AWS Polly TTS integration including credential management
/// and audio playback state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/aws_credential_service.dart';
import '../services/tts_service.dart';

// ============================================================
// TTS Service
// ============================================================

/// TTS service singleton provider
final ttsServiceProvider = Provider<TTSService>((ref) {
  return TTSService.instance;
});

// ============================================================
// AWS Credentials
// ============================================================

/// AWS credential service singleton provider
final awsCredentialServiceProvider = Provider<AWSCredentialService>((ref) {
  return AWSCredentialService.instance;
});

/// TTS configuration state (is configured?)
final ttsConfiguredProvider = FutureProvider<bool>((ref) async {
  return AWSCredentialService.instance.isConfigured();
});

// ============================================================
// Playback State
// ============================================================

/// TTS playback state stream provider
final ttsPlaybackStateProvider = StreamProvider<TTSPlaybackState>((ref) {
  return TTSService.instance.stateStream;
});
