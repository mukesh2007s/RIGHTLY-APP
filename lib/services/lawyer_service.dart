import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/lawyer_model.dart';

/// Lawyer Service — manages lawyer data, ratings, and search
class LawyerService {
  static final LawyerService _instance = LawyerService._internal();
  factory LawyerService() => _instance;
  LawyerService._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'rightly_lawyers.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE lawyers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT,
        officeAddress TEXT,
        specialization TEXT,
        experience INTEGER DEFAULT 0,
        rating REAL DEFAULT 0.0,
        reviewCount INTEGER DEFAULT 0,
        profileImage TEXT,
        bio TEXT,
        languages TEXT DEFAULT 'English',
        isVerified INTEGER DEFAULT 0,
        isOnline INTEGER DEFAULT 0,
        location TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        lawyerId TEXT NOT NULL,
        userId TEXT NOT NULL,
        userName TEXT,
        rating REAL NOT NULL,
        reviewText TEXT,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (lawyerId) REFERENCES lawyers(id)
      )
    ''');

    // Insert sample lawyers
    await _insertSampleLawyers(db);
  }

  Future<void> _insertSampleLawyers(Database db) async {
    final lawyers = [
      {
        'id': 'L001',
        'name': 'Adv. Rajesh Kumar',
        'phone': '+91 98765 43210',
        'email': 'rajesh.kumar@legalaid.in',
        'officeAddress': '42, High Court Road, Chennai - 600104',
        'specialization': 'Criminal Law',
        'experience': 15,
        'rating': 4.8,
        'reviewCount': 124,
        'bio': 'Senior criminal lawyer with 15+ years of experience in the Madras High Court. Specializing in bail applications, criminal appeals, and white-collar crime defense.',
        'languages': 'English,Tamil,Hindi',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Chennai',
      },
      {
        'id': 'L002',
        'name': 'Adv. Priya Sharma',
        'phone': '+91 87654 32109',
        'email': 'priya.sharma@lawfirm.in',
        'officeAddress': '15, MG Road, Bengaluru - 560001',
        'specialization': 'Family Law',
        'experience': 12,
        'rating': 4.9,
        'reviewCount': 98,
        'bio': 'Expert in family law, divorce proceedings, child custody, and domestic violence cases. Known for compassionate and result-oriented approach.',
        'languages': 'English,Hindi,Kannada',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Bengaluru',
      },
      {
        'id': 'L003',
        'name': 'Adv. Mohammed Ismail',
        'phone': '+91 76543 21098',
        'email': 'ismail.legal@gmail.com',
        'officeAddress': '8, Law Chamber Complex, Hyderabad - 500003',
        'specialization': 'Civil Law',
        'experience': 20,
        'rating': 4.7,
        'reviewCount': 156,
        'bio': 'Veteran civil litigation lawyer. Expert in property disputes, land acquisition matters, contract law, and civil rights cases.',
        'languages': 'English,Telugu,Hindi,Urdu',
        'isVerified': 1,
        'isOnline': 0,
        'location': 'Hyderabad',
      },
      {
        'id': 'L004',
        'name': 'Adv. Sneha Patel',
        'phone': '+91 65432 10987',
        'email': 'sneha.patel@cyberlaw.in',
        'officeAddress': '23, Satellite Road, Ahmedabad - 380015',
        'specialization': 'Cyber Law',
        'experience': 8,
        'rating': 4.6,
        'reviewCount': 67,
        'bio': 'Specialized in cyber crime, data privacy, IT Act cases, online fraud, and digital intellectual property rights.',
        'languages': 'English,Hindi,Gujarati',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Ahmedabad',
      },
      {
        'id': 'L005',
        'name': 'Adv. Karthik Rajan',
        'phone': '+91 54321 09876',
        'email': 'karthik.rajan@corporatelaw.in',
        'officeAddress': '5th Floor, Legal Tower, T Nagar, Chennai - 600017',
        'specialization': 'Corporate Law',
        'experience': 18,
        'rating': 4.9,
        'reviewCount': 203,
        'bio': 'Corporate law specialist handling mergers & acquisitions, company formation, SEBI compliance, and startup legal advisory.',
        'languages': 'English,Tamil',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Chennai',
      },
      {
        'id': 'L006',
        'name': 'Adv. Anita Deshmukh',
        'phone': '+91 43210 98765',
        'email': 'anita.legal@womenrights.in',
        'officeAddress': '101, FC Road, Pune - 411004',
        'specialization': 'Women\'s Rights',
        'experience': 14,
        'rating': 4.8,
        'reviewCount': 145,
        'bio': 'Passionate women\'s rights advocate. Expert in dowry harassment, workplace sexual harassment (POSH Act), domestic violence, and gender discrimination cases.',
        'languages': 'English,Hindi,Marathi',
        'isVerified': 1,
        'isOnline': 0,
        'location': 'Pune',
      },
      {
        'id': 'L007',
        'name': 'Adv. Suresh Menon',
        'phone': '+91 32109 87654',
        'email': 'suresh.menon@propertylaw.in',
        'officeAddress': '67, Ernakulam Junction, Kochi - 682011',
        'specialization': 'Property Law',
        'experience': 22,
        'rating': 4.7,
        'reviewCount': 178,
        'bio': 'Senior property law expert handling real estate transactions, title verification, land disputes, RERA compliance, and property registration.',
        'languages': 'English,Malayalam,Hindi',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Kochi',
      },
      {
        'id': 'L008',
        'name': 'Adv. Deepa Nair',
        'phone': '+91 21098 76543',
        'email': 'deepa.nair@consumerlaw.in',
        'officeAddress': '34, Brigade Road, Bengaluru - 560025',
        'specialization': 'Consumer Rights',
        'experience': 10,
        'rating': 4.5,
        'reviewCount': 89,
        'bio': 'Consumer rights champion. Handles product liability, service deficiency, unfair trade practices, and e-commerce dispute resolution.',
        'languages': 'English,Kannada,Malayalam',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Bengaluru',
      },
      {
        'id': 'L009',
        'name': 'Adv. Vikram Singh',
        'phone': '+91 10987 65432',
        'email': 'vikram.singh@laborlaw.in',
        'officeAddress': '78, Connaught Place, New Delhi - 110001',
        'specialization': 'Labor Law',
        'experience': 16,
        'rating': 4.6,
        'reviewCount': 112,
        'bio': 'Expert in labor and employment law. Handles wrongful termination, workplace safety, PF/ESI disputes, and industrial tribunal matters.',
        'languages': 'English,Hindi,Punjabi',
        'isVerified': 1,
        'isOnline': 0,
        'location': 'New Delhi',
      },
      {
        'id': 'L010',
        'name': 'Adv. Lakshmi Sundaram',
        'phone': '+91 09876 54321',
        'email': 'lakshmi.s@constitutionallaw.in',
        'officeAddress': '12, Anna Salai, Chennai - 600002',
        'specialization': 'Constitutional Law',
        'experience': 25,
        'rating': 5.0,
        'reviewCount': 267,
        'bio': 'Distinguished constitutional law expert and senior advocate. Argued landmark PIL cases in Supreme Court. Expert in fundamental rights, writ petitions, and public interest litigation.',
        'languages': 'English,Tamil,Hindi',
        'isVerified': 1,
        'isOnline': 1,
        'location': 'Chennai',
      },
    ];

    for (final lawyer in lawyers) {
      await db.insert('lawyers', lawyer);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LAWYER CRUD OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Get all lawyers
  Future<List<LawyerModel>> getAllLawyers() async {
    final db = await database;
    final result = await db.query('lawyers', orderBy: 'rating DESC');
    return result.map((json) => LawyerModel.fromJson(json)).toList();
  }

  /// Get lawyer by ID
  Future<LawyerModel?> getLawyerById(String id) async {
    final db = await database;
    final result = await db.query('lawyers', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return LawyerModel.fromJson(result.first);
  }

  /// Search lawyers by name or specialization
  Future<List<LawyerModel>> searchLawyers(String query) async {
    final db = await database;
    final result = await db.query(
      'lawyers',
      where: 'name LIKE ? OR specialization LIKE ? OR location LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'rating DESC',
    );
    return result.map((json) => LawyerModel.fromJson(json)).toList();
  }

  /// Filter lawyers by specialization
  Future<List<LawyerModel>> filterBySpecialization(String specialization) async {
    final db = await database;
    final result = await db.query(
      'lawyers',
      where: 'specialization = ?',
      whereArgs: [specialization],
      orderBy: 'rating DESC',
    );
    return result.map((json) => LawyerModel.fromJson(json)).toList();
  }

  /// Filter lawyers by minimum rating
  Future<List<LawyerModel>> filterByRating(double minRating) async {
    final db = await database;
    final result = await db.query(
      'lawyers',
      where: 'rating >= ?',
      whereArgs: [minRating],
      orderBy: 'rating DESC',
    );
    return result.map((json) => LawyerModel.fromJson(json)).toList();
  }

  /// Get all unique specializations
  Future<List<String>> getSpecializations() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT specialization FROM lawyers ORDER BY specialization',
    );
    return result.map((row) => row['specialization'] as String).toList();
  }

  // ═══════════════════════════════════════════════════════════════
  // REVIEW OPERATIONS
  // ═══════════════════════════════════════════════════════════════

  /// Add a review for a lawyer
  Future<void> addReview(ReviewModel review) async {
    final db = await database;
    await db.insert('reviews', review.toJson());

    // Update lawyer rating
    await _updateLawyerRating(review.lawyerId);
  }

  /// Get reviews for a lawyer
  Future<List<ReviewModel>> getReviews(String lawyerId) async {
    final db = await database;
    final result = await db.query(
      'reviews',
      where: 'lawyerId = ?',
      whereArgs: [lawyerId],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => ReviewModel.fromJson(json)).toList();
  }

  /// Check if user has already reviewed a lawyer
  Future<bool> hasUserReviewed(String lawyerId, String userId) async {
    final db = await database;
    final result = await db.query(
      'reviews',
      where: 'lawyerId = ? AND userId = ?',
      whereArgs: [lawyerId, userId],
    );
    return result.isNotEmpty;
  }

  /// Update lawyer average rating after new review
  Future<void> _updateLawyerRating(String lawyerId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT AVG(rating) as avgRating, COUNT(*) as count FROM reviews WHERE lawyerId = ?',
      [lawyerId],
    );

    if (result.isNotEmpty) {
      final avgRating = (result.first['avgRating'] as num?)?.toDouble() ?? 0.0;
      final count = (result.first['count'] as int?) ?? 0;
      await db.update(
        'lawyers',
        {'rating': avgRating, 'reviewCount': count},
        where: 'id = ?',
        whereArgs: [lawyerId],
      );
    }
  }
}
