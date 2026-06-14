import 'package:equatable/equatable.dart';
import 'package:art_mobile/features/supply/data/models/product_model.dart';

class SupplyState extends Equatable {
  final List<Product> products;
  final List<CartItem> cart;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;

  const SupplyState({
    this.products = const [],
    this.cart = const [],
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isLoading = false,
  });

  List<Product> get filteredProducts {
    var filtered = products;
    if (selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == selectedCategory).toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    return filtered;
  }

  int get cartCount => cart.fold(0, (sum, item) => sum + item.qty);

  double get cartTotal => cart.fold(0, (sum, item) => sum + (item.product.price * item.qty));

  SupplyState copyWith({
    List<Product>? products,
    List<CartItem>? cart,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
  }) {
    return SupplyState(
      products: products ?? this.products,
      cart: cart ?? this.cart,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [products, cart, selectedCategory, searchQuery, isLoading];
}
