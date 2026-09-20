import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' show ListenMode, LocaleName, SpeechListenOptions, SpeechToText;
import 'package:flutter_tts/flutter_tts.dart';

/// Voice Service for real Speech Recognition and Text-to-Speech
class VoiceService {
  static final VoiceService _instance = VoiceService._internal();
  factory VoiceService() => _instance;
  VoiceService._internal();

  // Real Speech to Text instance
  final SpeechToText _speechToText = SpeechToText();

  // Real Text to Speech instance
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _sttAvailable = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  String _selectedLanguage = 'en-IN';
  double _speechRate = 0.5;
  double _pitch = 1.0;
  double _volume = 0.8;

  // Callbacks
  Function(String)? onResult;
  Function(String)? onPartialResult;
  Function()? onListeningStarted;
  Function()? onListeningStopped;
  Function(String)? onError;
  Function(double)? onSoundLevelChange;
  Function()? onSpeakingStarted;
  Function()? onSpeakingCompleted;

  /// Request microphone permission at runtime
  Future<bool> requestMicPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// Initialize voice services
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Request mic permission first
      final micGranted = await requestMicPermission();
      if (!micGranted) {
        debugPrint('Microphone permission denied');
        onError?.call('Microphone permission is required for voice features');
      }

      // Initialize Speech to Text
      _sttAvailable = await _speechToText.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: kDebugMode,
      );

      debugPrint('STT available: $_sttAvailable');

      // Initialize Text to Speech
      await _flutterTts.setLanguage(_selectedLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setPitch(_pitch);
      await _flutterTts.setVolume(_volume);

      // TTS completion handlers
      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        onSpeakingStarted?.call();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        onSpeakingCompleted?.call();
      });

      _flutterTts.setCancelHandler(() {
        _isSpeaking = false;
      });

      _flutterTts.setErrorHandler((message) {
        _isSpeaking = false;
        onError?.call('TTS Error: $message');
      });

      _isInitialized = true;
      return _isInitialized;
    } catch (e) {
      debugPrint('Voice Service Init Error: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Start listening for speech (real speech recognition)
  Future<void> startListening() async {
    if (!_isInitialized) {
      await initialize();
    }

    if (!_sttAvailable) {
      onError?.call('Speech recognition is not available on this device');
      return;
    }

    if (_isListening) return;

    // Stop TTS if speaking
    if (_isSpeaking) {
      await stopSpeaking();
    }

    try {
      _isListening = true;
      onListeningStarted?.call();

      await _speechToText.listen(
        onResult: _onSpeechResult,
        localeId: _selectedLanguage,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) {
          onSoundLevelChange?.call(level);
        },
        listenOptions: SpeechListenOptions(
          cancelOnError: true,
          listenMode: ListenMode.confirmation,
        ),
      );
    } catch (e) {
      _isListening = false;
      onError?.call('Failed to start listening: $e');
      onListeningStopped?.call();
    }
  }

  /// Handle speech recognition results
  void _onSpeechResult(SpeechRecognitionResult result) {
    if (result.finalResult) {
      final text = result.recognizedWords;
      if (text.isNotEmpty) {
        onResult?.call(text);
      }
      _isListening = false;
      onListeningStopped?.call();
    } else {
      // Partial result — live transcription
      onPartialResult?.call(result.recognizedWords);
    }
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.stop();
      _isListening = false;
      onListeningStopped?.call();
    } catch (e) {
      onError?.call('Failed to stop listening: $e');
    }
  }

  /// Cancel listening (discard results)
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speechToText.cancel();
      _isListening = false;
      onListeningStopped?.call();
    } catch (e) {
      onError?.call('Failed to cancel listening: $e');
    }
  }

  /// Speak text using real TTS
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Stop any current speech
    if (_isSpeaking) {
      await stopSpeaking();
    }

    // Auto-detect language and set TTS language accordingly
    final detectedLang = _detectTtsLanguage(text);
    if (detectedLang != _selectedLanguage) {
      await _flutterTts.setLanguage(detectedLang);
    }

    try {
      _isSpeaking = true;
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      // Restore original language on error
      await _flutterTts.setLanguage(_selectedLanguage);
      onError?.call('Failed to speak: $e');
    }
  }

  /// Detect TTS language code from text content using script detection
  String _detectTtsLanguage(String text) {
    for (final char in text.runes) {
      if (char >= 0x0900 && char <= 0x097F) return 'hi-IN'; // Hindi
      if (char >= 0x0B80 && char <= 0x0BFF) return 'ta-IN'; // Tamil
      if (char >= 0x0C00 && char <= 0x0C7F) return 'te-IN'; // Telugu
      if (char >= 0x0D00 && char <= 0x0D7F) return 'ml-IN'; // Malayalam
      if (char >= 0x0C80 && char <= 0x0CFF) return 'kn-IN'; // Kannada
      if (char >= 0x0980 && char <= 0x09FF) return 'bn-IN'; // Bengali
      if (char >= 0x0A80 && char <= 0x0AFF) return 'gu-IN'; // Gujarati
      if (char >= 0x0A00 && char <= 0x0A7F) return 'pa-IN'; // Punjabi
      if (char >= 0x0600 && char <= 0x06FF) return 'ur-PK'; // Urdu
    }
    return 'en-IN';
  }

  /// Stop speaking
  Future<void> stopSpeaking() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
    } catch (e) {
      onError?.call('Failed to stop speaking: $e');
    }
  }

  /// Pause speaking
  Future<void> pauseSpeaking() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      onError?.call('Failed to pause speaking: $e');
    }
  }

  /// Set language for voice services
  Future<void> setLanguage(String languageCode) async {
    _selectedLanguage = languageCode;
    await _flutterTts.setLanguage(languageCode);
  }

  /// Set speech rate (0.0 to 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  /// Set pitch (0.5 to 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  /// Get available languages from TTS engine
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      return [
        'en-IN', 'hi-IN', 'ta-IN', 'te-IN', 'ml-IN',
      ];
    }
  }

  /// Get available voices from TTS engine
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return voices
          .map<Map<String, String>>(
              (v) => Map<String, String>.from(v as Map))
          .toList();
    } catch (e) {
      return [
        {'name': 'Default', 'locale': 'en-IN'},
      ];
    }
  }

  /// Check if STT is available on device
  bool get isSttAvailable => _sttAvailable;

  /// Get available STT locales
  Future<List<LocaleName>> getSttLocales() async {
    if (!_isInitialized) await initialize();
    return _speechToText.locales();
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERNAL HANDLERS
  // ═══════════════════════════════════════════════════════════════

  void _onSpeechStatus(String status) {
    debugPrint('STT Status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      onListeningStopped?.call();
    }
  }

  void _onSpeechError(SpeechRecognitionError error) {
    debugPrint('STT Error: ${error.errorMsg} (permanent: ${error.permanent})');
    _isListening = false;
    if (error.permanent) {
      onError?.call('Speech recognition error: ${error.errorMsg}');
    }
    onListeningStopped?.call();
  }

  // Getters
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;
  String get currentLanguage => _selectedLanguage;
  double get currentSpeechRate => _speechRate;
  double get currentPitch => _pitch;
  double get currentVolume => _volume;

  /// Dispose resources
  void dispose() {
    stopListening();
    stopSpeaking();
    _flutterTts.stop();
  }
}


/// Language codes for supported languages
class VoiceLanguages {
  static const String english = 'en-IN';
  static const String hindi = 'hi-IN';
  static const String tamil = 'ta-IN';
  static const String telugu = 'te-IN';
  static const String malayalam = 'ml-IN';

  static String getDisplayName(String code) {
    switch (code) {
      case english:
        return 'English';
      case hindi:
        return 'हिंदी (Hindi)';
      case tamil:
        return 'தமிழ் (Tamil)';
      case telugu:
        return 'తెలుగు (Telugu)';
      case malayalam:
        return 'മലയാളം (Malayalam)';
      default:
        return 'English';
    }
  }
}
