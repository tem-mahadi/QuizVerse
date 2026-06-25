import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Quiz answer option tile with animated selection/correct/incorrect states
class QuizOptionTile extends StatelessWidget {
  final String option;
  final String serial;
  final bool isSelected;
  final bool isCorrectAnswer;
  final bool answerSubmitted;
  final VoidCallback? onTap;

  const QuizOptionTile({
    super.key,
    required this.option,
    required this.serial,
    this.isSelected = false,
    this.isCorrectAnswer = false,
    this.answerSubmitted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color borderColor;
    Color textColor;
    Color serialBgColor;

    if (answerSubmitted && isCorrectAnswer) {
      // This is the correct answer — always show green
      bgColor = AppColors.correct.withValues(alpha: 0.15);
      borderColor = AppColors.correct;
      textColor = AppColors.correct;
      serialBgColor = AppColors.correct.withValues(alpha: 0.3);
    } else if (answerSubmitted && isSelected && !isCorrectAnswer) {
      // User selected this but it's wrong
      bgColor = AppColors.incorrect.withValues(alpha: 0.15);
      borderColor = AppColors.incorrect;
      textColor = AppColors.incorrect;
      serialBgColor = AppColors.incorrect.withValues(alpha: 0.3);
    } else if (isSelected) {
      // Selected but not yet submitted
      bgColor = AppColors.primary.withValues(alpha: 0.15);
      borderColor = AppColors.primary;
      textColor = AppColors.primaryLight;
      serialBgColor = AppColors.primary.withValues(alpha: 0.3);
    } else {
      // Default state
      bgColor = AppColors.glassWhite;
      borderColor = AppColors.glassBorder;
      textColor = AppColors.textPrimary;
      serialBgColor = AppColors.glassWhite;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: borderColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Serial badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: serialBgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                serial,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Option text
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            // Status icon
            if (answerSubmitted && isCorrectAnswer)
              Icon(Icons.check_circle_rounded, color: AppColors.correct, size: 24)
            else if (answerSubmitted && isSelected && !isCorrectAnswer)
              Icon(Icons.cancel_rounded, color: AppColors.incorrect, size: 24),
          ],
        ),
      ),
    );
  }
}
