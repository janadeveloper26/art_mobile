import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:art_mobile/features/supply/domain/repositories/supply_repository.dart';
import 'package:art_mobile/features/supply/data/models/product_model.dart';
import 'supply_event.dart';
import 'supply_state.dart';

class SupplyBloc extends Bloc<SupplyEvent, SupplyState> {
  final ISupplyRepository repository;

  SupplyBloc(this.repository) : super(const SupplyState()) {
    on<LoadProducts>(_onLoadProducts);
    on<CategoryChanged>(_onCategoryChanged);
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<UpdateCartQty>(_onUpdateCartQty);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<SupplyState> emit) async {
    emit(state.copyWith(isLoading: true));
    try {
      final products = await repository.getProducts();
      emit(state.copyWith(
        products: products,
        isLoading: false,
      ));
    } catch (e) {
      // In a real app, emit error state. Here we'll just stop loading.
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onCategoryChanged(CategoryChanged event, Emitter<SupplyState> emit) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<SupplyState> emit) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onAddToCart(AddToCart event, Emitter<SupplyState> emit) {
    final cart = List<CartItem>.from(state.cart);
    final existingIndex = cart.indexWhere((item) => item.product.id == event.product.id);
    
    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      cart[existingIndex] = existingItem.copyWith(qty: existingItem.qty + 1);
    } else {
      cart.add(CartItem(product: event.product, qty: 1));
    }
    
    emit(state.copyWith(cart: cart));
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<SupplyState> emit) {
    final cart = List<CartItem>.from(state.cart);
    cart.removeWhere((item) => item.product.id == event.productId);
    emit(state.copyWith(cart: cart));
  }

  void _onUpdateCartQty(UpdateCartQty event, Emitter<SupplyState> emit) {
    final cart = List<CartItem>.from(state.cart);
    final existingIndex = cart.indexWhere((item) => item.product.id == event.productId);
    
    if (existingIndex >= 0) {
      final existingItem = cart[existingIndex];
      final newQty = existingItem.qty + event.delta;
      if (newQty > 0) {
        cart[existingIndex] = existingItem.copyWith(qty: newQty);
      } else {
        cart.removeAt(existingIndex);
      }
      emit(state.copyWith(cart: cart));
    }
  }
}
