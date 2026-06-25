import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/quiz_category_model.dart';
import '../service/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/category_grid_card.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/shimmer_loading.dart';
import 'quiz_page.dart';

class QuizCategories extends StatefulWidget {
  const QuizCategories({super.key});

  @override
  State<QuizCategories> createState() => _QuizCategoriesState();
}

class _QuizCategoriesState extends State<QuizCategories>
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
      duration: const Duration(milliseconds: 1200),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Quiz Categories',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadQuizCategories,
            color: AppColors.primary,
            backgroundColor: AppColors.bgMid,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Info text
                Text(
                  'Choose a category and test your knowledge!',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Content
                if (isLoading)
                  const ShimmerGrid(count: 6)
                else if (errorMessage != null)
                  _buildError()
                else if (allCategories.isEmpty)
                  _buildEmpty()
                else
                  _buildGrid(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemCount: allCategories.length,
      itemBuilder: (context, index) {
        final cat = allCategories[index];
        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            final delay = index * 0.1;
            final raw = (_animController.value - delay).clamp(0.0, 1.0);
            final divisor = (1.0 - delay).clamp(0.01, 1.0);
            final animValue = (raw / divisor).clamp(0.0, 1.0);
            return Opacity(
              opacity: animValue,
              child: Transform.translate(
                offset: Offset(0, 30 * (1 - animValue)),
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

  Widget _buildError() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.neonRed, size: 56),
          const SizedBox(height: 16),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 20),
          GradientButton(
            text: 'Try Again',
            icon: Icons.refresh_rounded,
            height: 44,
            onPressed: loadQuizCategories,
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return GlassCard(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Icon(Icons.category_outlined, color: AppColors.textMuted, size: 56),
          const SizedBox(height: 16),
          Text(
            'No categories available yet.',
            style: GoogleFonts.outfit(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
