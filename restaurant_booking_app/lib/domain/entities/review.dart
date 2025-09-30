import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String comment;
  final List<String> photos;
  final DateTime createdAt;
  final String? venueResponse;
  final DateTime? venueResponseDate;

  const Review({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.comment,
    this.photos = const [],
    required this.createdAt,
    this.venueResponse,
    this.venueResponseDate,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatarUrl,
        rating,
        comment,
        photos,
        createdAt,
        venueResponse,
        venueResponseDate,
      ];

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      userName: json['user_name'] as String,
      userAvatarUrl: json['user_avatar_url'] as String?,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      photos: List<String>.from(json['photos'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      venueResponse: json['venue_response'] as String?,
      venueResponseDate: json['venue_response_date'] != null
          ? DateTime.parse(json['venue_response_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user_name': userName,
      if (userAvatarUrl != null) 'user_avatar_url': userAvatarUrl,
      'rating': rating,
      'comment': comment,
      'photos': photos,
      'created_at': createdAt.toIso8601String(),
      if (venueResponse != null) 'venue_response': venueResponse,
      if (venueResponseDate != null)
        'venue_response_date': venueResponseDate!.toIso8601String(),
    };
  }
}
