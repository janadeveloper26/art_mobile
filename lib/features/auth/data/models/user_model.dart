import 'package:art_mobile/core/models/base_models.dart';
import 'package:art_mobile/features/auth/domain/entities/user_entity.dart';

class UserModel extends DataModel<UserEntity> {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? bio;
  final DateTime createdAt;
  final bool isSubscribed;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.bio,
    required this.createdAt,
    required this.isSubscribed,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImage: json['profileImage'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isSubscribed: json['isSubscribed'] as bool? ?? false,
    );
  }

  @override
  UserEntity toDomain() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      profileImage: profileImage,
      bio: bio,
      createdAt: createdAt,
      isSubscribed: isSubscribed,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
      'isSubscribed': isSubscribed,
    };
  }
}
