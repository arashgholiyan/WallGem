import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/wallpaper.dart';
import 'wallpaper_card.dart';

/// Interactive draggable card stack with 3D depth layers and dynamic stamps.
class SwipeableCardStack extends StatefulWidget {
  final List<Wallpaper> deck;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final VoidCallback onSwipeUp;

  const SwipeableCardStack({
    super.key,
    required this.deck,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.onSwipeUp,
  });

  @override
  State<SwipeableCardStack> createState() => _SwipeableCardStackState();
}

class _SwipeableCardStackState extends State<SwipeableCardStack> {
  Offset _dragOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    if (widget.deck.isEmpty) {
      return const SizedBox.shrink();
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final cardWidth = min(880.0, screenWidth * 0.9);
    final cardHeight = min(530.0, screenHeight * 0.60);

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.deck.length > 2)
            _buildStaticCard(
              widget.deck[2],
              scale: 0.90,
              translateY: 36,
              opacity: 0.4,
            ),
          if (widget.deck.length > 1)
            _buildStaticCard(
              widget.deck[1],
              scale: 0.95,
              translateY: 18,
              opacity: 0.75,
            ),
          if (widget.deck.isNotEmpty) _buildTopDraggableCard(widget.deck[0]),
        ],
      ),
    );
  }

  Widget _buildStaticCard(
    Wallpaper wallpaper, {
    required double scale,
    required double translateY,
    required double opacity,
  }) {
    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(0, translateY),
        child: Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: WallpaperCard(wallpaper: wallpaper),
          ),
        ),
      ),
    );
  }

  Widget _buildTopDraggableCard(Wallpaper wallpaper) {
    final rotateAngle = _dragOffset.dx * 0.0008;

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
        });
      },
      onPanEnd: (details) {
        if (_dragOffset.dy < -120 && _dragOffset.dx.abs() < 80) {
          widget.onSwipeUp();
        } else if (_dragOffset.dx > 130) {
          widget.onSwipeRight();
        } else if (_dragOffset.dx < -130) {
          widget.onSwipeLeft();
        }

        setState(() {
          _dragOffset = Offset.zero;
        });
      },
      child: RepaintBoundary(
        child: Transform.translate(
          offset: _dragOffset,
          child: Transform.rotate(
            angle: rotateAngle,
            child: Stack(
              children: [
                WallpaperCard(wallpaper: wallpaper),

              // LIKE Stamp
              if (_dragOffset.dx > 20)
                Positioned(
                  top: 30,
                  right: 30,
                  child: Opacity(
                    opacity: (_dragOffset.dx / 120).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: 0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.like, width: 3),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black87,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.likeGlow,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Text(
                          'LIKE',
                          style: TextStyle(
                            color: AppColors.like,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // PASS Stamp
              if (_dragOffset.dx < -20)
                Positioned(
                  top: 30,
                  left: 30,
                  child: Opacity(
                    opacity: (-_dragOffset.dx / 120).clamp(0.0, 1.0),
                    child: Transform.rotate(
                      angle: -0.2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.pass, width: 3),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black87,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.passGlow,
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Text(
                          'PASS',
                          style: TextStyle(
                            color: AppColors.pass,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              // APPLY NOW Stamp
              if (_dragOffset.dy < -40)
                Positioned(
                  top: 50,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: (-_dragOffset.dy / 100).clamp(0.0, 1.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.star, width: 3),
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black87,
                          boxShadow: const [
                            BoxShadow(
                              color: AppColors.starGlow,
                              blurRadius: 24,
                            ),
                          ],
                        ),
                        child: const Text(
                          '★ APPLY NOW',
                          style: TextStyle(
                            color: AppColors.star,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
