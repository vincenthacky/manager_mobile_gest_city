import 'package:flutter/material.dart';

/// Simple skeleton placeholder implementation that mimics a skeleton loader
/// using pulsing grey boxes. This avoids depending on a specific third-party
/// package while delivering a professional loading state.
class SkeletonPlaceholder extends StatefulWidget {
  final double borderRadius;
  final Color baseColor;
  final Color highlightColor;
  final EdgeInsetsGeometry? padding;

  const SkeletonPlaceholder({
    super.key,
    this.borderRadius = 8.0,
    this.baseColor = const Color(0xFFE6E9EE),
    this.highlightColor = const Color(0xFFF5F7FA),
    this.padding,
  });

  @override
  State<SkeletonPlaceholder> createState() => _SkeletonPlaceholderState();
}

class _SkeletonPlaceholderState extends State<SkeletonPlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _skeletonBox({required double width, required double height}) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: widget.baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding ?? const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          _skeletonBox(width: 220, height: 28),
          const SizedBox(height: 12),
          _skeletonBox(width: 180, height: 14),
          const SizedBox(height: 20),

          // Stat cards skeleton row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(width: 40, height: 14),
                      const SizedBox(height: 12),
                      _skeletonBox(width: double.infinity, height: 18),
                      const SizedBox(height: 8),
                      _skeletonBox(width: 120, height: 12),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(width: 40, height: 14),
                      const SizedBox(height: 12),
                      _skeletonBox(width: double.infinity, height: 18),
                      const SizedBox(height: 8),
                      _skeletonBox(width: 120, height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Action cards skeleton
          Column(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _skeletonBox(width: 44, height: 44),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _skeletonBox(width: double.infinity, height: 14),
                            const SizedBox(height: 8),
                            _skeletonBox(width: 150, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          // Recent contributions list skeleton
          Column(
            children: List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _skeletonBox(width: 40, height: 40),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _skeletonBox(width: double.infinity, height: 14),
                            const SizedBox(height: 6),
                            _skeletonBox(width: 140, height: 12),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
