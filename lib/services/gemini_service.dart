import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

/// Gemini AI Service for multilingual legal assistance
/// Detects user language, responds in layman terms in their own language
class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  // ═══════════════════════════════════════════════════════════════
  // CONFIGURATION — Replace with your Gemini API Key
  // ═══════════════════════════════════════════════════════════════
  static const String _apiKey = 'AIzaSyCBPd73j9ES9CkxhpzRc7vFIo7YC3bkHzI';

  // Model priority: try primary first, fallback on quota errors
  static const String _primaryModel = 'gemini-2.5-flash';
  static const String _fallbackModel = 'gemini-2.5-flash-lite';

  GenerativeModel? _model;
  GenerativeModel? _fallbackModelInstance;
  ChatSession? _chatSession;
  bool _isInitialized = false;
  String? _lastError;
  String _activeModelName = _primaryModel;

  // System instruction for the legal AI
  static const String _systemPrompt =
      '''You are "Rightly AI" — a legal awareness assistant for Indian citizens.

RULES:
1. DETECT the user's language automatically from their message.
2. ALWAYS reply in the SAME language the user used.
3. Explain legal concepts in SIMPLE LAYMAN TERMS that anyone can understand.
4. Use everyday analogies and examples.
5. Reference specific Indian laws, articles, and sections when relevant.
6. If mentioning legal terms, explain them in parentheses.
7. Be empathetic, supportive, and encouraging.
8. For serious criminal matters, always advise consulting a lawyer.
9. Provide simple step-by-step guidance when suggesting actions.
10. Keep answers SHORT — under 100 words. Be concise and clear.

You support: English, Hindi, Tamil, Telugu, Malayalam, Kannada, Bengali, Marathi, Gujarati, Punjabi, Urdu.

FORMAT:
- DO NOT use any markdown formatting. No ** or * or # symbols.
- Use plain text only. No bold, no italics, no headers.
- Keep paragraphs short (2-3 sentences max).
- Use numbered lists for steps.
- End with one practical next step.''';

  // Language mapping
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'hi': 'Hindi',
    'ta': 'Tamil',
    'te': 'Telugu',
    'ml': 'Malayalam',
    'kn': 'Kannada',
    'bn': 'Bengali',
    'mr': 'Marathi',
    'gu': 'Gujarati',
    'pa': 'Punjabi',
    'ur': 'Urdu',
  };

  /// Create a GenerativeModel with given model name
  GenerativeModel _createModel(String modelName) {
    return GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topP: 0.95,
        topK: 40,
        maxOutputTokens: 800,
      ),
      systemInstruction: Content.text(_systemPrompt),
    );
  }

  /// Initialize the Gemini model
  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _model = _createModel(_primaryModel);
      _fallbackModelInstance = _createModel(_fallbackModel);
      _activeModelName = _primaryModel;
      _isInitialized = true;
      _lastError = null;
      debugPrint('Gemini AI initialized: primary=$_primaryModel, fallback=$_fallbackModel');
    } catch (e) {
      _isInitialized = false;
      _lastError = e.toString();
      debugPrint('Gemini AI init error: $e');
    }
  }

  /// Start a new chat session
  void startNewChat() {
    if (_model != null) {
      _chatSession = _model!.startChat();
    }
  }

  /// Check if error is a quota/rate limit error
  bool _isQuotaError(dynamic error) {
    final msg = error.toString().toLowerCase();
    return msg.contains('429') ||
        msg.contains('quota') ||
        msg.contains('rate') ||
        msg.contains('resource_exhausted') ||
        msg.contains('too many requests');
  }

  /// Send a message and get AI response with auto language detection
  /// Automatically falls back to secondary model on quota errors
  Future<String> sendMessage(String userMessage) async {
    if (!_isInitialized || _model == null) {
      await initialize();
      if (!_isInitialized) {
        return _getErrorResponse(userMessage, 'Failed to initialize AI service');
      }
    }

    // Try primary model via chat session
    try {
      if (_chatSession == null) startNewChat();

      final response = await _chatSession!.sendMessage(
        Content.text(userMessage),
      );

      _lastError = null;
      return response.text ?? 'I could not process your request. Please try again.';
    } catch (e) {
      debugPrint('Primary model ($_activeModelName) error: $e');
      _lastError = e.toString();
      _chatSession = null;

      // If quota error, try fallback Gemini model, then Railway
      if (_isQuotaError(e) && _fallbackModelInstance != null) {
        return _tryFallbackModel(userMessage);
      }

      // Non-quota Gemini error — try Railway backend directly
      return _tryRailwayFallback(userMessage);
    }
  }

  /// Try fallback model when primary is quota-limited
  Future<String> _tryFallbackModel(String userMessage) async {
    try {
      debugPrint('Trying fallback model: $_fallbackModel');
      final response = await _fallbackModelInstance!.generateContent([
        Content.text(userMessage),
      ]);

      _lastError = null;
      return response.text ?? 'I could not process your request. Please try again.';
    } catch (e) {
      debugPrint('Fallback model ($_fallbackModel) error: $e');
      _lastError = e.toString();

      // Both Gemini models failed — try Railway backend as final fallback
      return _tryRailwayFallback(userMessage);
    }
  }

  /// Final fallback: try Railway backend when all Gemini models fail
  Future<String> _tryRailwayFallback(String userMessage) async {
    try {
      debugPrint('Trying Railway backend fallback...');
      final answer = await askLegalQuestion(userMessage);
      _lastError = null;
      return answer;
    } catch (e) {
      debugPrint('Railway backend fallback error: $e');
      _lastError = e.toString();
      return _getErrorResponse(userMessage,
          'All AI services are unavailable. Please try again later.');
    }
  }

  /// Stream response for real-time typing effect
  Stream<String> streamMessage(String userMessage) async* {
    if (!_isInitialized || _model == null) {
      await initialize();
      if (!_isInitialized) {
        yield _getErrorResponse(userMessage, 'AI not initialized');
        return;
      }
    }

    try {
      final response = _model!.generateContentStream([
        Content.text(userMessage),
      ]);

      String fullResponse = '';
      await for (final chunk in response) {
        final text = chunk.text ?? '';
        fullResponse += text;
        yield fullResponse;
      }
    } catch (e) {
      if (_isQuotaError(e) && _fallbackModelInstance != null) {
        try {
          final fallbackResponse = await _fallbackModelInstance!.generateContent([
            Content.text(userMessage),
          ]);
          yield fallbackResponse.text ?? _getErrorResponse(userMessage, e.toString());
        } catch (e2) {
          // Both Gemini models failed — try Railway backend
          try {
            final railwayAnswer = await askLegalQuestion(userMessage);
            yield railwayAnswer;
          } catch (e3) {
            yield _getErrorResponse(userMessage, 'All AI services are unavailable.');
          }
        }
      } else {
        // Non-quota error — try Railway backend directly
        try {
          final railwayAnswer = await askLegalQuestion(userMessage);
          yield railwayAnswer;
        } catch (e2) {
          yield _getErrorResponse(userMessage, e.toString());
        }
      }
    }
  }

  /// Get legal steps suggestion for a specific legal issue
  Future<String> getLegalSteps(String issue, {String language = 'en'}) async {
    final langName = _languageNames[language] ?? 'English';
    final prompt = '''
The user needs step-by-step legal guidance for: "$issue"

Respond in $langName language.

Provide:
1. Immediate steps to take
2. Which laws/sections apply
3. Where to file complaint/case
4. Documents needed
5. Expected timeline
6. Whether they need a lawyer
7. Estimated costs (if applicable)
8. Emergency contacts/helplines

Keep it simple and actionable for a common person.''';

    return sendMessage(prompt);
  }

  /// Get lawyer consultation suggestions
  Future<String> getLawyerAdvice(String specialization, String issue,
      {String language = 'en'}) async {
    final langName = _languageNames[language] ?? 'English';
    final prompt = '''
The user wants to consult a $specialization lawyer about: "$issue"

Respond in $langName.

Provide:
1. Key questions to ask the lawyer
2. Documents to prepare before meeting
3. What to expect in consultation
4. Typical fee range for this type of case
5. Rights during legal proceedings
6. Alternative dispute resolution options

Keep language simple for a layperson.''';

    return sendMessage(prompt);
  }

  /// Detect language from text (simple heuristic)
  String detectLanguage(String text) {
    for (final char in text.runes) {
      if (char >= 0x0900 && char <= 0x097F) return 'hi'; // Devanagari
      if (char >= 0x0B80 && char <= 0x0BFF) return 'ta'; // Tamil
      if (char >= 0x0C00 && char <= 0x0C7F) return 'te'; // Telugu
      if (char >= 0x0D00 && char <= 0x0D7F) return 'ml'; // Malayalam
      if (char >= 0x0C80 && char <= 0x0CFF) return 'kn'; // Kannada
      if (char >= 0x0980 && char <= 0x09FF) return 'bn'; // Bengali
      if (char >= 0x0A80 && char <= 0x0AFF) return 'gu'; // Gujarati
      if (char >= 0x0A00 && char <= 0x0A7F) return 'pa'; // Gurmukhi (Punjabi)
      if (char >= 0x0600 && char <= 0x06FF) return 'ur'; // Arabic script (Urdu)
    }
    return 'en';
  }

  /// Error response that tells the user what actually went wrong
  String _getErrorResponse(String query, String errorDetail) {
    final lang = detectLanguage(query);
    final isQuota = errorDetail.toLowerCase().contains('quota') ||
        errorDetail.toLowerCase().contains('429') ||
        errorDetail.toLowerCase().contains('rate');

    if (isQuota) {
      switch (lang) {
        case 'hi':
          return '''AI सेवा अस्थायी रूप से व्यस्त

API की दैनिक सीमा समाप्त हो गई है। कृपया कुछ मिनट बाद पुनः प्रयास करें।

📞 तत्काल सहायता के लिए: आपातकालीन 112 | महिला हेल्पलाइन 181''';
        case 'ta':
          return '''AI சேவை தற்காலிகமாக பிஸியாக உள்ளது

API தினசரி வரம்பை எட்டிவிட்டது. சில நிமிடங்களில் மீண்டும் முயற்சிக்கவும்.

📞 உடனடி உதவி: அவசரம் 112 | பெண்கள் உதவி 181''';
        default:
          return '''AI Service Temporarily Busy

The API daily limit has been reached. Please try again in a few minutes.

📞 For immediate help: Emergency 112 | Women Helpline 181

💡 Tip: Try asking shorter questions or wait a moment before retrying.''';
      }
    }

    // Generic error
    switch (lang) {
      case 'hi':
        return '''⚠️ AI से कनेक्ट नहीं हो पा रहा

कृपया अपना इंटरनेट कनेक्शन जांचें और पुनः प्रयास करें।

📞 तत्काल सहायता: आपातकालीन 112 | महिला हेल्पलाइन 181''';
      case 'ta':
        return '''⚠️ AI உடன் இணைக்க முடியவில்லை

உங்கள் இணைய இணைப்பை சரிபார்த்து மீண்டும் முயற்சிக்கவும்.

📞 உடனடி உதவி: அவசரம் 112 | பெண்கள் உதவி 181''';
      default:
        return '''Could Not Connect to AI

Please check your internet connection and try again.

📞 For immediate help: Emergency 112 | Women Helpline 181

💡 If this persists, restart the app.''';
    }
  }

  // Getters
  bool get isInitialized => _isInitialized;
  String? get lastError => _lastError;

  /// Ask a legal question via the Railway backend API
  static Future<String> askLegalQuestion(String question) async {
    final response = await http.post(
      Uri.parse('https://legal-ai-backend-production-a632.up.railway.app/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'question': question}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['answer'];
    }
    throw Exception('Failed to get answer');
  }

  /// Dispose resources
  void dispose() {
    _chatSession = null;
    _model = null;
    _isInitialized = false;
  }
}
