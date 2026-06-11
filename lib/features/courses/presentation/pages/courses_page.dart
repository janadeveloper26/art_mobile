import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:art_mobile/core/config/service_locator.dart';
import 'package:art_mobile/core/routing/app_routes.dart';
import 'package:art_mobile/core/theme/theme_colors.dart';
import 'package:art_mobile/core/theme/theme_manager.dart';
import '../bloc/explore/explore_bloc.dart';
import '../../data/models/course_model.dart';

class CoursesPage extends StatelessWidget {
  const CoursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExploreBloc(sl())..add(LoadExploreData()),
      child: const ExploreView(),
    );
  }
}

class ExploreView extends StatefulWidget {
  const ExploreView({super.key});

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sl<ThemeManager>(),
      builder: (context, _) {
        final isDark = sl<ThemeManager>().isDarkMode;
        return Scaffold(
          backgroundColor: isDark ? ThemeColors.backgroundDark : const Color(0xFFFBFBFB),
          body: SafeArea(
            child: BlocBuilder<ExploreBloc, ExploreState>(
              builder: (context, state) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Minimalist App Bar
                      SliverAppBar(
                        expandedHeight: 120, // Slightly reduced
                        floating: true,
                        pinned: true,
                        elevation: 0,
                        backgroundColor: isDark ? ThemeColors.backgroundDark : const Color(0xFFFBFBFB),
                        flexibleSpace: FlexibleSpaceBar(
                          background: Padding(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0), // Reduced top padding
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Discovery',
                                  style: GoogleFonts.outfit(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                  ),
                                ),
                                Text(
                                  'Find your next artistic journey',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
  
                  // Search & Filter Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          _buildSearchBar(isDark),
                          const SizedBox(height: 20),
                          if (state is ExploreLoaded) _buildFilterChips(state),
                        ],
                      ),
                    ),
                  ),
  
                  // Category List
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 8),
                      child: _buildCategoryRow(state, isDark),
                    ),
                  ),
  
                  // Results Metadata
                  SliverToBoxAdapter(
                    child: _buildResultsMetadata(state, isDark),
                  ),
  
                  // Course Grid
                  if (state is ExploreLoaded)
                    _buildCourseGrid(context, state, isDark)
                  else if (state is ExploreLoading)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))),
                    )
                  else if (state is ExploreError)
                    SliverFillRemaining(
                      child: Center(child: Text(state.message)),
                    )
                  else
                    const SliverFillRemaining(child: SizedBox.shrink()),
                ],
              ),
            );
          },
        ),
      ),
    );
  },
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: isDark ? ThemeColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6A1B9A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.grey.shade100),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(LucideIcons.search, color: const Color(0xFF6A1B9A).withOpacity(0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                context.read<ExploreBloc>().add(SearchCourses(val));
              },
              style: GoogleFonts.outfit(fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
              decoration: InputDecoration(
                hintText: 'Search skills, courses...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: Colors.grey.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 8),
          ),
          const Icon(LucideIcons.sliders, color: Color(0xFF6A1B9A), size: 18),
        ],
      ),
    );
  }

  Widget _buildFilterChips(ExploreLoaded state) {
    return SizedBox(
      height: 34,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.data.filters.length,
        itemBuilder: (context, index) {
          final filter = state.data.filters[index];
          final isActive = state.activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => context.read<ExploreBloc>().add(ChangeFilter(filter)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF6A1B9A) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? Colors.transparent : const Color(0xFF6A1B9A).withOpacity(0.1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  filter,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryRow(ExploreState state, bool isDark) {
    if (state is! ExploreLoaded) return const SizedBox.shrink();
    return SizedBox(
      height: 38,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        scrollDirection: Axis.horizontal,
        itemCount: state.data.categories.length,
        itemBuilder: (context, index) {
          final cat = state.data.categories[index];
          final isActive = state.activeCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => context.read<ExploreBloc>().add(ChangeCategory(cat)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF6A1B9A).withOpacity(0.08) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isActive ? const Color(0xFF6A1B9A) : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                    color: isActive ? const Color(0xFF6A1B9A) : Colors.grey.shade500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultsMetadata(ExploreState state, bool isDark) {
    if (state is! ExploreLoaded) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${state.data.courses.length} ',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  ),
                ),
                TextSpan(
                  text: 'results found',
                  style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                'Newest first',
                style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF6A1B9A), fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(LucideIcons.chevronDown, size: 14, color: Color(0xFF6A1B9A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCourseGrid(BuildContext context, ExploreLoaded state, bool isDark) {
    if (state.data.courses.isEmpty) {
      return SliverFillRemaining(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark ? ThemeColors.surfaceDark : const Color(0xFFF8F6FB),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.search, size: 32, color: Color(0xFF6A1B9A)),
            ),
            const SizedBox(height: 20),
            Text(
              'No matches found',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different skill or filter',
              style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 16,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final course = state.data.courses[index];
            return _buildCourseCard(context, course, isDark);
          },
          childCount: state.data.courses.length,
        ),
      ),
    );
  }

  Widget _buildCourseCard(BuildContext context, CourseSummary course, bool isDark) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.courseDetail, arguments: {'courseId': course.id}),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: isDark ? ThemeColors.borderDark : Colors.grey.shade50),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Badge
            Expanded(
              flex: 12,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      image: DecorationImage(image: _courseImageProvider(course.image), fit: BoxFit.cover),
                    ),
                  ),
                  if (course.discount != null)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFC107), borderRadius: BorderRadius.circular(8)),
                        child: Text(
                          course.discount!,
                          style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info
            Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.category.toUpperCase(),
                          style: GoogleFonts.outfit(fontSize: 9, fontWeight: FontWeight.w800, color: const Color(0xFF6A1B9A), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          course.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${course.originalPrice}',
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: Colors.grey.shade400,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            Text(
                              '₹${course.price}',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF6A1B9A),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F6FB),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.star, size: 10, color: Color(0xFFFFC107)),
                              const SizedBox(width: 2),
                              Text(
                                course.rating.toString(),
                                style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.bold, color: const Color(0xFF6A1B9A)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider _courseImageProvider(String image) {
    if (image.startsWith('http')) {
      return NetworkImage(image);
    }

    return AssetImage(image.isNotEmpty ? image : 'assets/images/aari_hero.png');
  }
}
