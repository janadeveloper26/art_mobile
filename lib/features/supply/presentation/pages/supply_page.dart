import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/features/supply/data/models/product_model.dart';
import '../bloc/supply_bloc.dart';
import '../bloc/supply_event.dart';
import '../bloc/supply_state.dart';

class SupplyPage extends StatefulWidget {
  const SupplyPage({super.key});

  @override
  State<SupplyPage> createState() => _SupplyPageState();
}

class _SupplyPageState extends State<SupplyPage> {
  final List<String> _categories = ['All', 'Thread', 'Fabric', 'Tools', 'Dyes'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SupplyBloc()..add(LoadProducts()),
      child: AnimatedBuilder(
        animation: sl<ThemeManager>(),
        builder: (context, _) {
          final isDark = sl<ThemeManager>().isDarkMode;
          return Scaffold(
            backgroundColor: isDark ? ThemeColors.backgroundDark : const Color(0xFFFBFBFB),
            appBar: AppBar(
              backgroundColor: isDark ? ThemeColors.surfaceDark : Colors.white,
              elevation: 0,
              title: Text(
                'Aari Supplies',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF212121),
                ),
              ),
              actions: [
                BlocBuilder<SupplyBloc, SupplyState>(
                  builder: (context, state) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(LucideIcons.shoppingBag, color: isDark ? Colors.white : const Color(0xFF212121)),
                          onPressed: () {
                            // TODO: Open Cart
                          },
                        ),
                        if (state.cartCount > 0)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${state.cartCount}',
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                _buildSearchBar(isDark),
                _buildCategories(isDark),
                Expanded(child: _buildProductGrid(isDark)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return BlocBuilder<SupplyBloc, SupplyState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? ThemeColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.grey.shade200),
            ),
            child: TextField(
              onChanged: (val) => context.read<SupplyBloc>().add(SearchQueryChanged(val)),
              style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: 'Search threads, fabrics, tools...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400),
                prefixIcon: Icon(LucideIcons.search, color: Colors.grey.shade400, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategories(bool isDark) {
    return BlocBuilder<SupplyBloc, SupplyState>(
      builder: (context, state) {
        return SizedBox(
          height: 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final cat = _categories[index];
              final isActive = state.selectedCategory == cat;
              return GestureDetector(
                onTap: () => context.read<SupplyBloc>().add(CategoryChanged(cat)),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive ? const Color(0xFF6A1B9A) : (isDark ? ThemeColors.surfaceDark : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? Colors.transparent : (isDark ? ThemeColors.borderDark : Colors.grey.shade200)),
                  ),
                  child: Text(
                    cat,
                    style: GoogleFonts.outfit(
                      color: isActive ? Colors.white : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(bool isDark) {
    return BlocBuilder<SupplyBloc, SupplyState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final products = state.filteredProducts;
        if (products.isEmpty) {
          return Center(
            child: Text(
              'No products found.',
              style: GoogleFonts.outfit(color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            return _buildProductCard(context, products[index], isDark);
          },
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.05) : const Color(0xFFF8F6FB),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(LucideIcons.image, size: 40, color: Colors.grey),
                ),
                if (product.badge != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.badgeColor != null 
                            ? Color(int.parse('FF${product.badgeColor}', radix: 16)) 
                            : Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        product.badge!,
                        style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black45 : Colors.white70,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(LucideIcons.heart, size: 16, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF6A1B9A),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (product.inStock) {
                          context.read<SupplyBloc>().add(AddToCart(product));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: product.inStock ? const Color(0xFF6A1B9A) : Colors.grey,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.plus, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
