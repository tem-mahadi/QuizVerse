import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/quiz_category_model.dart';
import '../model/quiz_ques_model.dart';
import '../service/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/numeric_serial_to_abc.dart';
import '../widgets/cosmic_background.dart';
import '../widgets/cosmic_timer.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/quiz_option_tile.dart';
import 'result_page.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.category});

  final QuizCategory category;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  int? selectedAnswerIndex;
  bool answerSubmitted = false;
  int obtainedMark = 0;
  int totalCorrect = 0;
  int progress = 0;
  List<QuizQuestion> questions = [];
  bool isLoading = true;
  String? errorMessage;
  late AnimationController _questionAnim;

  @override
  void initState() {
    super.initState();
    _questionAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    loadAllQuestionsOfThisCategory();
  }

  @override
  void dispose() {
    _questionAnim.dispose();
    super.dispose();
  }

  void setAnswer(int currentIndex) {
    if (answerSubmitted) return;
    setState(() {
      selectedAnswerIndex = selectedAnswerIndex == currentIndex ? null : currentIndex;
    });
  }

  void submitAnswer() {
    if (selectedAnswerIndex == null) return;

    final isCorrect = selectedAnswerIndex == questions[progress].answerIndex;
    setState(() {
      answerSubmitted = true;
      if (isCorrect) {
        totalCorrect++;
        obtainedMark += questions[progress].mark;
      }
    });
  }

  void _onTimeUp() {
    if (!answerSubmitted) {
      submitAnswer();
    }
  }

  void prepareNextQuestion() {
    if (progress < questions.length - 1) {
      setState(() {
        progress++;
        answerSubmitted = false;
        selectedAnswerIndex = null;
      });
      _questionAnim.forward(from: 0);
    } else {
      // Quiz over — navigate to result page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(
            categoryName: widget.category.name,
            totalQuestions: questions.length,
            totalCorrect: totalCorrect,
            obtainedMark: obtainedMark,
          ),
        ),
      );
    }
  }

  Future<void> loadAllQuestionsOfThisCategory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final allQuestions = await ApiService().fetchQuestions(widget.category.id);
      if (mounted) {
        setState(() {
          questions = (List<QuizQuestion>.from(allQuestions)..shuffle()).take(5).toList();
          isLoading = false;
        });
        _questionAnim.forward(from: 0);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${widget.category.name} Quiz',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Score badge
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: AppColors.neonYellow, size: 18),
                const SizedBox(width: 4),
                Text(
                  '$obtainedMark',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : errorMessage != null
                  ? _buildError()
                  : questions.isEmpty
                      ? _buildNoQuestions()
                      : _buildQuizContent(),
        ),
      ),
    );
  }

  Widget _buildQuizContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress header
          _buildProgressHeader(),
          const SizedBox(height: 8),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (progress + 1) / questions.length,
              backgroundColor: AppColors.glassWhite,
              color: AppColors.primary,
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 24),

          // Question + Options (scrollable)
          Expanded(
            child: AnimatedBuilder(
              animation: _questionAnim,
              builder: (context, child) {
                final fadeValue = Curves.easeOut.transform(_questionAnim.value.clamp(0.0, 1.0));
                return Opacity(
                  opacity: fadeValue,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - fadeValue), 0),
                    child: child,
                  ),
                );
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Question card
                    GlassCard(
                      padding: const EdgeInsets.all(20),
                      borderColor: AppColors.accent.withValues(alpha: 0.3),
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          questions[progress].question,
                          style: GoogleFonts.outfit(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Answer options
                    ...List.generate(
                      questions[progress].options.length,
                      (i) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: QuizOptionTile(
                          option: questions[progress].options[i],
                          serial: numericSerialToAbc(i).toUpperCase(),
                          isSelected: selectedAnswerIndex == i,
                          isCorrectAnswer: questions[progress].answerIndex == i,
                          answerSubmitted: answerSubmitted,
                          onTap: answerSubmitted ? null : () => setAnswer(i),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Feedback text
          if (answerSubmitted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selectedAnswerIndex == questions[progress].answerIndex
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: selectedAnswerIndex == questions[progress].answerIndex
                        ? AppColors.correct
                        : AppColors.incorrect,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    selectedAnswerIndex == questions[progress].answerIndex
                        ? 'Correct! Well done 🎉'
                        : 'Incorrect! Keep trying 💪',
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: selectedAnswerIndex == questions[progress].answerIndex
                          ? AppColors.correct
                          : AppColors.incorrect,
                    ),
                  ),
                ],
              ),
            ),

          // Action button
          if (selectedAnswerIndex != null || answerSubmitted)
            SafeArea(
              child: answerSubmitted
                  ? GradientButton(
                      text: progress < questions.length - 1 ? 'Next Question' : 'See Results',
                      icon: progress < questions.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.emoji_events_rounded,
                      onPressed: prepareNextQuestion,
                    )
                  : GradientButton(
                      text: 'Submit Answer',
                      icon: Icons.check_rounded,
                      gradient: AppColors.accentGradient,
                      onPressed: submitAnswer,
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${progress + 1}',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${questions.length}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Timer
        CosmicTimer(
          key: ValueKey(progress),
          totalSeconds: 30,
          onTimeUp: _onTimeUp,
        ),
      ],
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.neonRed, size: 56),
              const SizedBox(height: 16),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Retry',
                icon: Icons.refresh_rounded,
                height: 44,
                onPressed: loadAllQuestionsOfThisCategory,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoQuestions() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.quiz_outlined, color: AppColors.textMuted, size: 56),
              const SizedBox(height: 16),
              Text(
                '${widget.category.name} quiz is not available right now!',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              GradientButton(
                text: 'Go Back',
                icon: Icons.arrow_back_rounded,
                height: 44,
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
