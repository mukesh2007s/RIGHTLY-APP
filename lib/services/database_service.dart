import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Database Service for Local Legal Knowledge Storage
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'rightly.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Legal Topics Table
    await db.execute('''
      CREATE TABLE legal_topics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        title TEXT NOT NULL,
        subtitle TEXT,
        description TEXT NOT NULL,
        articles TEXT,
        keywords TEXT,
        language TEXT DEFAULT 'en',
        is_bookmarked INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    // Chat History Table
    await db.execute('''
      CREATE TABLE chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        message TEXT NOT NULL,
        response TEXT,
        intent TEXT,
        is_user INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // User Preferences Table
    await db.execute('''
      CREATE TABLE user_preferences (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // Emergency Contacts Table
    await db.execute('''
      CREATE TABLE emergency_contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        number TEXT NOT NULL,
        description TEXT,
        category TEXT,
        is_national INTEGER DEFAULT 0
      )
    ''');

    // Lawyer Chat History Table (persistent per lawyer)
    await db.execute('''
      CREATE TABLE lawyer_chat_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        lawyer_id TEXT NOT NULL,
        message TEXT NOT NULL,
        is_user INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert default legal topics
    await _insertDefaultLegalTopics(db);
    
    // Insert default emergency contacts
    await _insertDefaultEmergencyContacts(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database migrations
    if (oldVersion < 2) {
      // Add lawyer chat history table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS lawyer_chat_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          lawyer_id TEXT NOT NULL,
          message TEXT NOT NULL,
          is_user INTEGER NOT NULL,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  /// Insert default legal topics
  Future<void> _insertDefaultLegalTopics(Database db) async {
    final topics = [
      {
        'category': 'fundamental',
        'title': 'Right to Equality',
        'subtitle': 'Articles 14-18',
        'description': 'Equality before law, prohibition of discrimination, equality of opportunity in public employment, abolition of untouchability and titles.',
        'articles': 'Article 14,Article 15,Article 16,Article 17,Article 18',
        'keywords': 'equality,discrimination,untouchability,caste',
        'language': 'en',
      },
      {
        'category': 'fundamental',
        'title': 'Right to Freedom',
        'subtitle': 'Articles 19-22',
        'description': 'Freedom of speech, assembly, association, movement, residence, and profession. Protection in respect of conviction for offences.',
        'articles': 'Article 19,Article 20,Article 21,Article 22',
        'keywords': 'freedom,speech,movement,arrest',
        'language': 'en',
      },
      {
        'category': 'criminal',
        'title': 'Rights During Arrest',
        'subtitle': 'CrPC Section 41-60',
        'description': 'Right to know grounds of arrest, right to inform relative, right to magistrate within 24 hours, right to lawyer.',
        'articles': 'Section 41,Section 50,Section 55,Section 56,Section 57',
        'keywords': 'arrest,police,detention,lawyer',
        'language': 'en',
      },
      {
        'category': 'consumer',
        'title': 'Consumer Rights',
        'subtitle': 'Consumer Protection Act 2019',
        'description': 'Right to safety, information, choice, be heard, redressal, and consumer education.',
        'articles': 'Section 2(9),Section 35,Section 38,Section 47',
        'keywords': 'consumer,refund,complaint,product',
        'language': 'en',
      },
      {
        'category': 'women',
        'title': 'Protection from Domestic Violence',
        'subtitle': 'DV Act 2005',
        'description': 'Protection against domestic violence, right to residence, protection orders, monetary relief.',
        'articles': 'Section 3,Section 17,Section 18,Section 19,Section 20',
        'keywords': 'domestic violence,women,protection,abuse',
        'language': 'en',
      },
    ];

    for (final topic in topics) {
      await db.insert('legal_topics', {
        ...topic,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Insert default emergency contacts
  Future<void> _insertDefaultEmergencyContacts(Database db) async {
    final contacts = [
      {
        'name': 'Police',
        'number': '100',
        'description': 'Emergency police assistance',
        'category': 'emergency',
        'is_national': 1,
      },
      {
        'name': 'Women Helpline',
        'number': '181',
        'description': 'Women in distress helpline',
        'category': 'women',
        'is_national': 1,
      },
      {
        'name': 'Child Helpline',
        'number': '1098',
        'description': '24x7 child helpline',
        'category': 'children',
        'is_national': 1,
      },
      {
        'name': 'National Human Rights Commission',
        'number': '14433',
        'description': 'Human rights complaints',
        'category': 'rights',
        'is_national': 1,
      },
      {
        'name': 'Ambulance',
        'number': '102',
        'description': 'Medical emergency',
        'category': 'medical',
        'is_national': 1,
      },
      {
        'name': 'Fire',
        'number': '101',
        'description': 'Fire emergency',
        'category': 'emergency',
        'is_national': 1,
      },
      {
        'name': 'National Emergency',
        'number': '112',
        'description': 'Single emergency number',
        'category': 'emergency',
        'is_national': 1,
      },
      {
        'name': 'Senior Citizen Helpline',
        'number': '14567',
        'description': 'Senior citizens assistance',
        'category': 'seniors',
        'is_national': 1,
      },
      {
        'name': 'Cyber Crime',
        'number': '1930',
        'description': 'Cyber crime reporting',
        'category': 'cyber',
        'is_national': 1,
      },
      {
        'name': 'Consumer Helpline',
        'number': '1800-11-4000',
        'description': 'Consumer complaints',
        'category': 'consumer',
        'is_national': 1,
      },
    ];

    for (final contact in contacts) {
      await db.insert('emergency_contacts', contact);
    }
  }

  // ============ LEGAL TOPICS ============

  /// Get all legal topics
  Future<List<Map<String, dynamic>>> getAllTopics() async {
    final db = await database;
    return await db.query('legal_topics', orderBy: 'category, title');
  }

  /// Get topics by category
  Future<List<Map<String, dynamic>>> getTopicsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'legal_topics',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'title',
    );
  }

  /// Search topics
  Future<List<Map<String, dynamic>>> searchTopics(String query) async {
    final db = await database;
    return await db.query(
      'legal_topics',
      where: 'title LIKE ? OR description LIKE ? OR keywords LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  /// Get bookmarked topics
  Future<List<Map<String, dynamic>>> getBookmarkedTopics() async {
    final db = await database;
    return await db.query(
      'legal_topics',
      where: 'is_bookmarked = 1',
      orderBy: 'title',
    );
  }

  /// Toggle topic bookmark
  Future<void> toggleBookmark(int topicId) async {
    final db = await database;
    final topic = await db.query(
      'legal_topics',
      where: 'id = ?',
      whereArgs: [topicId],
    );
    
    if (topic.isNotEmpty) {
      final isBookmarked = topic.first['is_bookmarked'] == 1;
      await db.update(
        'legal_topics',
        {'is_bookmarked': isBookmarked ? 0 : 1},
        where: 'id = ?',
        whereArgs: [topicId],
      );
    }
  }

  // ============ CHAT HISTORY ============

  /// Save chat message
  Future<int> saveChatMessage({
    required String message,
    String? response,
    String? intent,
    required bool isUser,
  }) async {
    final db = await database;
    return await db.insert('chat_history', {
      'message': message,
      'response': response,
      'intent': intent,
      'is_user': isUser ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get chat history
  Future<List<Map<String, dynamic>>> getChatHistory({int limit = 50}) async {
    final db = await database;
    return await db.query(
      'chat_history',
      orderBy: 'created_at DESC',
      limit: limit,
    );
  }

  /// Clear chat history
  Future<void> clearChatHistory() async {
    final db = await database;
    await db.delete('chat_history');
  }

  // ============ USER PREFERENCES ============

  /// Set preference
  Future<void> setPreference(String key, String value) async {
    final db = await database;
    await db.insert(
      'user_preferences',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get preference
  Future<String?> getPreference(String key) async {
    final db = await database;
    final result = await db.query(
      'user_preferences',
      where: 'key = ?',
      whereArgs: [key],
    );
    
    if (result.isNotEmpty) {
      return result.first['value'] as String?;
    }
    return null;
  }

  /// Get all preferences
  Future<Map<String, String>> getAllPreferences() async {
    final db = await database;
    final result = await db.query('user_preferences');
    
    return Map.fromEntries(
      result.map((row) => MapEntry(
        row['key'] as String,
        row['value'] as String,
      )),
    );
  }

  // ============ EMERGENCY CONTACTS ============

  /// Get all emergency contacts
  Future<List<Map<String, dynamic>>> getEmergencyContacts() async {
    final db = await database;
    return await db.query('emergency_contacts', orderBy: 'is_national DESC, name');
  }

  /// Get contacts by category
  Future<List<Map<String, dynamic>>> getContactsByCategory(String category) async {
    final db = await database;
    return await db.query(
      'emergency_contacts',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name',
    );
  }

  /// Add custom contact
  Future<int> addEmergencyContact({
    required String name,
    required String number,
    String? description,
    String? category,
  }) async {
    final db = await database;
    return await db.insert('emergency_contacts', {
      'name': name,
      'number': number,
      'description': description,
      'category': category ?? 'custom',
      'is_national': 0,
    });
  }

  /// Delete contact
  Future<void> deleteEmergencyContact(int id) async {
    final db = await database;
    await db.delete(
      'emergency_contacts',
      where: 'id = ? AND is_national = 0',
      whereArgs: [id],
    );
  }

  // ============ UTILITIES ============

  // ============ LAWYER CHAT HISTORY ============

  /// Save lawyer chat message
  Future<int> saveLawyerChatMessage({
    required String lawyerId,
    required String message,
    required bool isUser,
  }) async {
    final db = await database;
    return await db.insert('lawyer_chat_history', {
      'lawyer_id': lawyerId,
      'message': message,
      'is_user': isUser ? 1 : 0,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// Get lawyer chat history
  Future<List<Map<String, dynamic>>> getLawyerChatHistory(String lawyerId) async {
    final db = await database;
    return await db.query(
      'lawyer_chat_history',
      where: 'lawyer_id = ?',
      whereArgs: [lawyerId],
      orderBy: 'created_at ASC',
    );
  }

  /// Clear lawyer chat history for a specific lawyer
  Future<void> clearLawyerChatHistory(String lawyerId) async {
    final db = await database;
    await db.delete(
      'lawyer_chat_history',
      where: 'lawyer_id = ?',
      whereArgs: [lawyerId],
    );
  }

  // ============ DB UTILITIES ============

  /// Get database statistics
  Future<Map<String, int>> getStats() async {
    final db = await database;
    
    final topicsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM legal_topics'),
    ) ?? 0;
    
    final chatCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM chat_history'),
    ) ?? 0;
    
    final bookmarksCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM legal_topics WHERE is_bookmarked = 1'),
    ) ?? 0;
    
    return {
      'topics': topicsCount,
      'chats': chatCount,
      'bookmarks': bookmarksCount,
    };
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}


/// Database preference keys
class PreferenceKeys {
  static const String language = 'language';
  static const String voiceSpeed = 'voice_speed';
  static const String aiMode = 'ai_mode';
  static const String offlineMode = 'offline_mode';
  static const String notifications = 'notifications';
  static const String voiceFeedback = 'voice_feedback';
  static const String hapticFeedback = 'haptic_feedback';
  static const String fontSize = 'font_size';
  static const String onboardingComplete = 'onboarding_complete';
  static const String firstLaunch = 'first_launch';
}
