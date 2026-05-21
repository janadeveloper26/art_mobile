import 'package:equatable/equatable.dart';
import 'package:art_mobile/features/supply/data/models/product_model.dart';

abstract class SupplyEvent extends Equatable {
  const SupplyEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends SupplyEvent {}

class CategoryChanged extends SupplyEvent {
  final String category;
  const CategoryChanged(this.category);

  @override
  List<Object?> get props => [category];
}

class SearchQueryChanged extends SupplyEvent {
  final String query;
  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class AddToCart extends SupplyEvent {
  final Product product;
  const AddToCart(this.product);

  @override
  List<Object?> get props => [product];
}

class RemoveFromCart extends SupplyEvent {
  final String productId;
  const RemoveFromCart(this.productId);

  @override
  List<Object?> get props => [productId];
}

class UpdateCartQty extends SupplyEvent {
  final String productId;
  final int delta;
  const UpdateCartQty(this.productId, this.delta);

  @override
  List<Object?> get props => [productId, delta];
}

class ToggleWishlist extends SupplyEvent {
  final String productId;
  const ToggleWishlist(this.productId);

  @override
  List<Object?> get props => [productId];
}
