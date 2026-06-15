import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviews;
  final String image;
  final String? badge;
  final String? badgeColor;
  final bool inStock;
  final List<String> tags;

  const Product({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.category,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviews,
    required this.image,
    this.badge,
    this.badgeColor,
    required this.inStock,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, name, subtitle, category, price, originalPrice, rating, reviews, image, badge, badgeColor, inStock, tags];
}

class CartItem extends Equatable {
  final Product product;
  final int qty;

  const CartItem({
    required this.product,
    required this.qty,
  });

  CartItem copyWith({
    Product? product,
    int? qty,
  }) {
    return CartItem(
      product: product ?? this.product,
      qty: qty ?? this.qty,
    );
  }

  @override
  List<Object?> get props => [product, qty];
}
