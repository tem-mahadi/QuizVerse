import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_score_ring.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import 'home_page.dart';

class ResultPage extends StatefulWidget {
  final String categoryName;
  final int totalQuestions;
  final int totalCorrect;
  final int obtainedMark;

  const ResultPage({
    super.key,
    required this.categoryName,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.obtainedMark,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  String _getMessage() {
    final percentage = widget.totalQuestions > 0
        ? (widget.totalCorrect / widget.totalQuestions * 100)
        : 0;

    if (percentage >= 80) return 'Excellent! 🌟';
    if (percentage >= 60) return 'Great Job! 🎉';
    if (percentage >= 40) return 'Good Effort! 💪';
    return 'Keep Trying! 🚀';
  }

  String _getSubMessage() {
    final percentage = widget.totalQuestions > 0
        ? (widget.totalCorrect / widget.totalQuestions * 100)
        : 0;

    if (percentage >= 80) return 'You\'re a quiz master!';
    if (percentage >= 60) return 'Well done, keep it up!';
    if (percentage >= 40) return 'Not bad, room for improvement!';
    return 'Practice makes perfect!';
  }

  @override
  Widget build(BuildContext context) {
    final incorrect = widget.totalQuestions - widget.totalCorrect;

    return Scaffold(
      body: CosmicBackground(
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Spacer(flex: 1),

                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      widget.categoryName,
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Animated score ring
                  AnimatedScoreRing(
                    totalCorrect: widget.totalCorrect,
                    totalQuestions: widget.totalQuestions,
                    obtainedMark: widget.obtainedMark,
                  ),

                  const SizedBox(height: 28),

                  // Message
                  Text(
                    _getMessage(),
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _getSubMessage(),
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Stats row
                  GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.check_circle_rounded,
                          label: 'Correct',
                          value: '${widget.totalCorrect}',
                          color: AppColors.correct,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          icon: Icons.cancel_rounded,
                          label: 'Incorrect',
                          value: '$incorrect',
                          color: AppColors.incorrect,
                        ),
                        _buildDivider(),
                        _buildStatItem(
                          icon: Icons.star_rounded,
                          label: 'Score',
                          value: '${widget.obtainedMark}',
                          color: AppColors.neonYellow,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),

                  // Buttons
                  GradientButton(
                    text: 'Back to Home',
                    icon: Icons.home_rounded,
                    onPressed: () => Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false,
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.glassBorder,
    );
  }
}
