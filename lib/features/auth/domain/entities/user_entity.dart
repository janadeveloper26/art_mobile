import 'package:equatable/equatable.dart';
import 'package:art_mobile/core/models/base_models.dart';

class UserEntity extends Entity {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final String? bio;
  final DateTime createdAt;
  final bool isSubscribed;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    this.bio,
    required this.createdAt,
    required this.isSubscribed,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profileImage,
        bio,
        createdAt,
        isSubscribed,
      ];
}
