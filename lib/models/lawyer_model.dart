import 'package:equatable/equatable.dart';

/// Lawyer Model — Professional legal practitioner
class LawyerModel extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String officeAddress;
  final String specialization;
  final int experience;
  final double rating;
  final int reviewCount;
  final String? profileImage;
  final String? bio;
  final List<String> languages;
  final bool isVerified;
  final bool isOnline;
  final String location;
  final double? latitude;
  final double? longitude;

  const LawyerModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.officeAddress,
    required this.specialization,
    this.experience = 0,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.profileImage,
    this.bio,
    this.languages = const ['English'],
    this.isVerified = false,
    this.isOnline = false,
    this.location = '',
    this.latitude,
    this.longitude,
  });

  LawyerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? officeAddress,
    String? specialization,
    int? experience,
    double? rating,
    int? reviewCount,
    String? profileImage,
    String? bio,
    List<String>? languages,
    bool? isVerified,
    bool? isOnline,
    String? location,
    double? latitude,
    double? longitude,
  }) {
    return LawyerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      officeAddress: officeAddress ?? this.officeAddress,
      specialization: specialization ?? this.specialization,
      experience: experience ?? this.experience,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      languages: languages ?? this.languages,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'officeAddress': officeAddress,
      'specialization': specialization,
      'experience': experience,
      'rating': rating,
      'reviewCount': reviewCount,
      'profileImage': profileImage,
      'bio': bio,
      'languages': languages.join(','),
      'isVerified': isVerified ? 1 : 0,
      'isOnline': isOnline ? 1 : 0,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  factory LawyerModel.fromJson(Map<String, dynamic> json) {
    return LawyerModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      officeAddress: json['officeAddress'] as String? ?? '',
      specialization: json['specialization'] as String? ?? 'General',
      experience: json['experience'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      profileImage: json['profileImage'] as String?,
      bio: json['bio'] as String?,
      languages: (json['languages'] is String)
          ? (json['languages'] as String).split(',')
          : (json['languages'] as List<dynamic>?)?.cast<String>() ?? ['English'],
      isVerified: json['isVerified'] == 1 || json['isVerified'] == true,
      isOnline: json['isOnline'] == 1 || json['isOnline'] == true,
      location: json['location'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  /// Get initials for avatar fallback
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  List<Object?> get props => [id, name, phone, email, specialization, rating];
}


/// Review Model — User review for a lawyer
class ReviewModel extends Equatable {
  final String id;
  final String lawyerId;
  final String userId;
  final String userName;
  final double rating;
  final String? reviewText;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.lawyerId,
    required this.userId,
    required this.userName,
    required this.rating,
    this.reviewText,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lawyerId': lawyerId,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'reviewText': reviewText,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      lawyerId: json['lawyerId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewText: json['reviewText'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  List<Object?> get props => [id, lawyerId, userId, rating];
}
