import 'package:equatable/equatable.dart';

// Base abstract class for domain entities
abstract class Entity extends Equatable {
  const Entity();

  @override
  List<Object?> get props => [];
}

// Base abstract class for data models
abstract class DataModel<T extends Entity> {
  T toDomain();

  Map<String, dynamic> toJson();
}
