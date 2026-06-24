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

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: json['originalPrice'] != null ? (json['originalPrice'] as num).toDouble() : null,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviews: json['reviews'] as int? ?? 0,
      image: json['imageUrl'] as String? ?? json['image'] as String? ?? '',
      badge: json['badge'] as String?,
      badgeColor: json['badgeColor'] as String?,
      inStock: json['inStock'] as bool? ?? true,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
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
