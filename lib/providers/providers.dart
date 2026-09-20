import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// App State Provider - Central state management
class AppStateProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════
  // USER STATE
  // ═══════════════════════════════════════════════════════════════
  
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void setUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // SETTINGS STATE
  // ═══════════════════════════════════════════════════════════════
  
  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  void updateSettings(AppSettings settings) {
    _settings = settings;
    notifyListeners();
  }

  void setLanguage(String language) {
    _settings = _settings.copyWith(language: language);
    notifyListeners();
  }

  void setAiMode(bool isOnline) {
    _settings = _settings.copyWith(isOnlineMode: isOnline);
    notifyListeners();
  }

  void setVoiceEnabled(bool enabled) {
    _settings = _settings.copyWith(voiceEnabled: enabled);
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // ONBOARDING STATE
  // ═══════════════════════════════════════════════════════════════
  
  bool _hasCompletedOnboarding = false;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void setOnboardingStatus(bool completed) {
    _hasCompletedOnboarding = completed;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // LOADING STATES
  // ═══════════════════════════════════════════════════════════════
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // ═══════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ═══════════════════════════════════════════════════════════════
  
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


/// Chat Provider - Manages chat conversations and messages
class ChatProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════
  // CONVERSATIONS
  // ═══════════════════════════════════════════════════════════════
  
  List<ChatConversation> _conversations = [];
  List<ChatConversation> get conversations => _conversations;

  ChatConversation? _currentConversation;
  ChatConversation? get currentConversation => _currentConversation;

  // ═══════════════════════════════════════════════════════════════
  // MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
  List<ChatMessage> _messages = [];
  List<ChatMessage> get messages => _messages;

  // ═══════════════════════════════════════════════════════════════
  // CHAT STATE
  // ═══════════════════════════════════════════════════════════════
  
  bool _isTyping = false;
  bool get isTyping => _isTyping;

  bool _isProcessing = false;
  bool get isProcessing => _isProcessing;

  String _streamingResponse = '';
  String get streamingResponse => _streamingResponse;

  // ═══════════════════════════════════════════════════════════════
  // METHODS
  // ═══════════════════════════════════════════════════════════════

  void startNewConversation() {
    final now = DateTime.now();
    _currentConversation = ChatConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Conversation',
      messages: [],
      createdAt: now,
      updatedAt: now,
    );
    _messages = [];
    notifyListeners();
  }

  void addMessage(ChatMessage message) {
    _messages = [..._messages, message];
    notifyListeners();
  }

  void updateLastMessage(ChatMessage message) {
    if (_messages.isNotEmpty) {
      _messages = [..._messages.sublist(0, _messages.length - 1), message];
      notifyListeners();
    }
  }

  void setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void updateStreamingResponse(String response) {
    _streamingResponse = response;
    notifyListeners();
  }

  void clearStreamingResponse() {
    _streamingResponse = '';
    notifyListeners();
  }

  void clearMessages() {
    _messages = [];
    _streamingResponse = '';
    notifyListeners();
  }

  void setConversations(List<ChatConversation> conversations) {
    _conversations = conversations;
    notifyListeners();
  }

  void selectConversation(ChatConversation conversation) {
    _currentConversation = conversation;
    _messages = conversation.messages;
    notifyListeners();
  }
}


/// Voice Assistant Provider
class VoiceProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════
  // VOICE STATE
  // ═══════════════════════════════════════════════════════════════
  
  VoiceAssistantState _state = VoiceAssistantState.idle;
  VoiceAssistantState get state => _state;

  String _recognizedText = '';
  String get recognizedText => _recognizedText;

  String _responseText = '';
  String get responseText => _responseText;

  double _soundLevel = 0.0;
  double get soundLevel => _soundLevel;

  bool _isListening = false;
  bool get isListening => _isListening;

  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  // ═══════════════════════════════════════════════════════════════
  // METHODS
  // ═══════════════════════════════════════════════════════════════

  void setState(VoiceAssistantState state) {
    _state = state;
    notifyListeners();
  }

  void setRecognizedText(String text) {
    _recognizedText = text;
    notifyListeners();
  }

  void setResponseText(String text) {
    _responseText = text;
    notifyListeners();
  }

  void setSoundLevel(double level) {
    _soundLevel = level;
    notifyListeners();
  }

  void setListening(bool listening) {
    _isListening = listening;
    _state = listening ? VoiceAssistantState.listening : VoiceAssistantState.idle;
    notifyListeners();
  }

  void setSpeaking(bool speaking) {
    _isSpeaking = speaking;
    _state = speaking ? VoiceAssistantState.speaking : VoiceAssistantState.idle;
    notifyListeners();
  }

  void reset() {
    _state = VoiceAssistantState.idle;
    _recognizedText = '';
    _responseText = '';
    _soundLevel = 0.0;
    _isListening = false;
    _isSpeaking = false;
    notifyListeners();
  }
}


/// Call Provider - Manages AI call interface state
class CallProvider extends ChangeNotifier {
  // ═══════════════════════════════════════════════════════════════
  // CALL STATE
  // ═══════════════════════════════════════════════════════════════
  
  CallAssistantState _state = CallAssistantState.idle;
  CallAssistantState get state => _state;

  Duration _callDuration = Duration.zero;
  Duration get callDuration => _callDuration;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isSpeakerOn = false;
  bool get isSpeakerOn => _isSpeakerOn;

  double _audioLevel = 0.0;
  double get audioLevel => _audioLevel;

  // ═══════════════════════════════════════════════════════════════
  // METHODS
  // ═══════════════════════════════════════════════════════════════

  void setState(CallAssistantState state) {
    _state = state;
    notifyListeners();
  }

  void updateDuration(Duration duration) {
    _callDuration = duration;
    notifyListeners();
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void toggleSpeaker() {
    _isSpeakerOn = !_isSpeakerOn;
    notifyListeners();
  }

  void setAudioLevel(double level) {
    _audioLevel = level;
    notifyListeners();
  }

  void startCall() {
    _state = CallAssistantState.connecting;
    _callDuration = Duration.zero;
    notifyListeners();
  }

  void connectCall() {
    _state = CallAssistantState.active;
    notifyListeners();
  }

  void endCall() {
    _state = CallAssistantState.ended;
    notifyListeners();
  }

  void reset() {
    _state = CallAssistantState.idle;
    _callDuration = Duration.zero;
    _isMuted = false;
    _isSpeakerOn = false;
    _audioLevel = 0.0;
    notifyListeners();
  }
}


/// Voice Assistant States
enum VoiceAssistantState {
  idle,
  listening,
  processing,
  speaking,
  error,
}


/// Call Assistant States
enum CallAssistantState {
  idle,
  incoming,
  connecting,
  active,
  ended,
}
