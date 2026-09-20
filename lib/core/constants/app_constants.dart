/// Application Constants for Rightly
class AppConstants {
  AppConstants._();

  // ═══════════════════════════════════════════════════════════════
  // APP INFO
  // ═══════════════════════════════════════════════════════════════
  
  static const String appName = 'Rightly';
  static const String appTagline = 'AI Legal Awareness Assistant';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  
  // ═══════════════════════════════════════════════════════════════
  // API ENDPOINTS
  // ═══════════════════════════════════════════════════════════════
  
  static const String geminiApiBaseUrl = 'https://generativelanguage.googleapis.com/v1beta';
  static const String openAiApiBaseUrl = 'https://api.openai.com/v1';
  
  // ═══════════════════════════════════════════════════════════════
  // STORAGE KEYS
  // ═══════════════════════════════════════════════════════════════
  
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keySelectedLanguage = 'selected_language';
  static const String keyAiMode = 'ai_mode';
  static const String keyVoiceEnabled = 'voice_enabled';
  static const String keySelectedVoice = 'selected_voice';
  static const String keyUserId = 'user_id';
  static const String keyAuthToken = 'auth_token';
  static const String keyThemeMode = 'theme_mode';
  
  // ═══════════════════════════════════════════════════════════════
  // SUPPORTED LANGUAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ta': 'தமிழ் (Tamil)',
    'hi': 'हिंदी (Hindi)',
    'te': 'తెలుగు (Telugu)',
    'ml': 'മലയാളം (Malayalam)',
  };
  
  static const String defaultLanguage = 'en';
  
  // ═══════════════════════════════════════════════════════════════
  // AI CONFIGURATION
  // ═══════════════════════════════════════════════════════════════
  
  static const String defaultAiModel = 'gemini-pro';
  static const String offlineAiModel = 'tinyllama';
  static const int maxTokens = 2048;
  static const double temperature = 0.7;
  
  // ═══════════════════════════════════════════════════════════════
  // ANIMATION DURATIONS
  // ═══════════════════════════════════════════════════════════════
  
  static const int splashDuration = 3000; // milliseconds
  static const int pageTransitionDuration = 300;
  static const int typingAnimationDuration = 50;
  
  // ═══════════════════════════════════════════════════════════════
  // CHAT CONFIGURATION
  // ═══════════════════════════════════════════════════════════════
  
  static const int maxMessageLength = 5000;
  static const int maxChatHistory = 100;
  
  // ═══════════════════════════════════════════════════════════════
  // DATABASE
  // ═══════════════════════════════════════════════════════════════
  
  static const String databaseName = 'rightly.db';
  static const int databaseVersion = 1;
  
  // ═══════════════════════════════════════════════════════════════
  // LEGAL TOPICS
  // ═══════════════════════════════════════════════════════════════
  
  static const List<String> legalCategories = [
    'Fundamental Rights',
    'Consumer Rights',
    'Women\'s Rights',
    'Labor Laws',
    'Property Laws',
    'Criminal Law',
    'Family Law',
    'Cyber Law',
    'RTI Act',
    'Environmental Law',
  ];
}


/// AI Mode Options
enum AiMode {
  offline('Offline', 'Uses local AI model'),
  online('Online', 'Uses cloud AI for better responses');
  
  final String title;
  final String description;
  
  const AiMode(this.title, this.description);
}


/// Chat Message Types
enum MessageType {
  user,
  ai,
  system,
  error,
}


/// Voice Assistant States
enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}


/// Call States
enum CallState {
  idle,
  incoming,
  connecting,
  active,
  ended,
}
