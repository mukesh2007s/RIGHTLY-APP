import 'package:equatable/equatable.dart';

/// Chat Message Model
class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageRole role;
  final DateTime timestamp;
  final String? language;
  final bool isAnimating;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.role,
    required this.timestamp,
    this.language,
    this.isAnimating = false,
    this.status = MessageStatus.sent,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageRole? role,
    DateTime? timestamp,
    String? language,
    bool? isAnimating,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      role: role ?? this.role,
      timestamp: timestamp ?? this.timestamp,
      language: language ?? this.language,
      isAnimating: isAnimating ?? this.isAnimating,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'role': role.name,
      'timestamp': timestamp.toIso8601String(),
      'language': language,
      'status': status.name,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => MessageRole.user,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      language: json['language'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
    );
  }

  @override
  List<Object?> get props => [id, content, role, timestamp, language, isAnimating, status];
}

/// Message Role Enum
enum MessageRole {
  user,
  assistant,
  system,
}

/// Message Status Enum
enum MessageStatus {
  sending,
  sent,
  delivered,
  error,
}


/// User Model
class UserModel extends Equatable {
  final String id;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String preferredLanguage;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
    this.preferredLanguage = 'en',
    required this.createdAt,
    this.lastLoginAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? preferredLanguage,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'preferredLanguage': preferredLanguage,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: json['lastLoginAt'] != null
          ? DateTime.parse(json['lastLoginAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl, preferredLanguage, createdAt, lastLoginAt];
}


/// Legal Topic Model
class LegalTopic extends Equatable {
  final int id;
  final String title;
  final String titleTamil;
  final String titleHindi;
  final String titleTelugu;
  final String titleMalayalam;
  final String description;
  final String content;
  final String category;
  final String? iconName;
  final List<String> keywords;
  final DateTime createdAt;

  const LegalTopic({
    required this.id,
    required this.title,
    this.titleTamil = '',
    this.titleHindi = '',
    this.titleTelugu = '',
    this.titleMalayalam = '',
    required this.description,
    required this.content,
    required this.category,
    this.iconName,
    this.keywords = const [],
    required this.createdAt,
  });

  String getLocalizedTitle(String languageCode) {
    switch (languageCode) {
      case 'ta':
        return titleTamil.isNotEmpty ? titleTamil : title;
      case 'hi':
        return titleHindi.isNotEmpty ? titleHindi : title;
      case 'te':
        return titleTelugu.isNotEmpty ? titleTelugu : title;
      case 'ml':
        return titleMalayalam.isNotEmpty ? titleMalayalam : title;
      default:
        return title;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'titleTamil': titleTamil,
      'titleHindi': titleHindi,
      'titleTelugu': titleTelugu,
      'titleMalayalam': titleMalayalam,
      'description': description,
      'content': content,
      'category': category,
      'iconName': iconName,
      'keywords': keywords,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LegalTopic.fromJson(Map<String, dynamic> json) {
    return LegalTopic(
      id: json['id'] as int,
      title: json['title'] as String,
      titleTamil: json['titleTamil'] as String? ?? '',
      titleHindi: json['titleHindi'] as String? ?? '',
      titleTelugu: json['titleTelugu'] as String? ?? '',
      titleMalayalam: json['titleMalayalam'] as String? ?? '',
      description: json['description'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      iconName: json['iconName'] as String?,
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, title, description, content, category];
}


/// Chat Conversation Model
class ChatConversation extends Equatable {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatConversation({
    required this.id,
    required this.title,
    this.messages = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  ChatConversation copyWith({
    String? id,
    String? title,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      title: title ?? this.title,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, title, messages, createdAt, updatedAt];
}


/// App Settings Model
class AppSettings extends Equatable {
  final String language;
  final bool isOnlineMode;
  final bool voiceEnabled;
  final String selectedVoice;
  final double voiceSpeed;
  final double voicePitch;
  final bool hapticFeedback;
  final bool notifications;

  const AppSettings({
    this.language = 'en',
    this.isOnlineMode = true,
    this.voiceEnabled = true,
    this.selectedVoice = 'default',
    this.voiceSpeed = 1.0,
    this.voicePitch = 1.0,
    this.hapticFeedback = true,
    this.notifications = true,
  });

  AppSettings copyWith({
    String? language,
    bool? isOnlineMode,
    bool? voiceEnabled,
    String? selectedVoice,
    double? voiceSpeed,
    double? voicePitch,
    bool? hapticFeedback,
    bool? notifications,
  }) {
    return AppSettings(
      language: language ?? this.language,
      isOnlineMode: isOnlineMode ?? this.isOnlineMode,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      selectedVoice: selectedVoice ?? this.selectedVoice,
      voiceSpeed: voiceSpeed ?? this.voiceSpeed,
      voicePitch: voicePitch ?? this.voicePitch,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      notifications: notifications ?? this.notifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'isOnlineMode': isOnlineMode,
      'voiceEnabled': voiceEnabled,
      'selectedVoice': selectedVoice,
      'voiceSpeed': voiceSpeed,
      'voicePitch': voicePitch,
      'hapticFeedback': hapticFeedback,
      'notifications': notifications,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      language: json['language'] as String? ?? 'en',
      isOnlineMode: json['isOnlineMode'] as bool? ?? true,
      voiceEnabled: json['voiceEnabled'] as bool? ?? true,
      selectedVoice: json['selectedVoice'] as String? ?? 'default',
      voiceSpeed: (json['voiceSpeed'] as num?)?.toDouble() ?? 1.0,
      voicePitch: (json['voicePitch'] as num?)?.toDouble() ?? 1.0,
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      notifications: json['notifications'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        language,
        isOnlineMode,
        voiceEnabled,
        selectedVoice,
        voiceSpeed,
        voicePitch,
        hapticFeedback,
        notifications,
      ];
}
