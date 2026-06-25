import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/quiz_category_model.dart';
import '../service/api_service.dart';
import '../service/user_data.dart';
import '../theme/app_colors.dart';
import '../widgets/category_grid_card.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/shimmer_loading.dart';
import 'profile_page.dart';
import 'quiz_categories.dart';
import 'quiz_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<QuizCategory> allCategories = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    loadQuizCategories();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> loadQuizCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final categories = await ApiService().fetchCategories();
      if (mounted) {
        setState(() {
          allCategories = categories;
          isLoading = false;
        });
        _animController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadQuizCategories,
            color: AppColors.primary,
            backgroundColor: AppColors.bgMid,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // === Header ===
                _buildHeader(),
                const SizedBox(height: 28),

                // === Hero Banner ===
                _buildHeroBanner(),
                const SizedBox(height: 32),

                // === Categories Section ===
                _buildSectionTitle('Quiz Categories', onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizCategories()),
                  );
                }),
                const SizedBox(height: 16),
                _buildCategoryGrid(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Profile Picture
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ),
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                UserData.userImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.bgMid,
                  child: const Icon(Icons.person, color: AppColors.textMuted),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 14),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back 👋',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                UserData.userName,
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        // Profile icon
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          ),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: AppColors.textSecondary,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      borderColor: AppColors.primary.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🚀 Ready to Play?',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Challenge yourself with quizzes from various categories and test your knowledge!',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'Browse All Categories',
            icon: Icons.explore_rounded,
            gradient: AppColors.accentGradient,
            height: 48,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QuizCategories()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    if (isLoading) {
      return const ShimmerGrid(count: 4);
    }

    if (errorMessage != null) {
      return GlassCard(
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded, color: AppColors.neonRed, size: 48),
            const SizedBox(height: 12),
            Text(
              errorMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            GradientButton(
              text: 'Retry',
              icon: Icons.refresh_rounded,
              height: 44,
              onPressed: loadQuizCategories,
            ),
          ],
        ),
      );
    }

    if (allCategories.isEmpty) {
      return GlassCard(
        child: Center(
          child: Text(
            'No categories available',
            style: GoogleFonts.outfit(color: AppColors.textMuted),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: allCategories.length > 6 ? 6 : allCategories.length,
      itemBuilder: (context, index) {
        final cat = allCategories[index];
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.15;
            final animValue = (_animController.value - delay).clamp(0.0, 1.0) / (1.0 - delay).clamp(0.01, 1.0);
            return Opacity(
              opacity: animValue.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - animValue.clamp(0.0, 1.0))),
                child: child,
              ),
            );
          },
          child: CategoryGridCard(
            name: cat.name,
            description: cat.description,
            index: index,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => QuizPage(category: cat),
              ),
            ),
          ),
        );
      },
    );
  }
}
