import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Circular countdown timer with neon glow and color transitions
class CosmicTimer extends StatefulWidget {
  final int totalSeconds;
  final VoidCallback? onTimeUp;

  const CosmicTimer({
    super.key,
    this.totalSeconds = 30,
    this.onTimeUp,
  });

  @override
  State<CosmicTimer> createState() => _CosmicTimerState();
}

class _CosmicTimerState extends State<CosmicTimer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.totalSeconds),
    );

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onTimeUp?.call();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getTimerColor(double progress) {
    if (progress < 0.5) return AppColors.neonGreen;
    if (progress < 0.75) return AppColors.neonYellow;
    return AppColors.neonRed;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        final remaining = ((1 - progress) * widget.totalSeconds).ceil();
        final color = _getTimerColor(progress);

        return Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  color: AppColors.glassWhite,
                ),
              ),
              // Progress circle (counts down)
              SizedBox(
                width: 56,
                height: 56,
                child: CircularProgressIndicator(
                  value: 1 - progress,
                  strokeWidth: 4,
                  backgroundColor: Colors.transparent,
                  color: color,
                  strokeCap: StrokeCap.round,
                ),
              ),
              // Time text
              Text(
                '$remaining',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
