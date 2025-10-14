import 'package:flutter/material.dart';
import '../../core/theme/theme.dart';

class MetricBar extends StatefulWidget {
  final String label;
  final int value; // 0-100
  final Color? color;
  final bool animate;

  const MetricBar({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.animate = true,
  });

  @override
  State<MetricBar> createState() => _MetricBarState();
}

class _MetricBarState extends State<MetricBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.value / 100.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label,
                style: WFTextStyles.labelMedium.copyWith(
                  fontSize: 16, // Bigger text
                  fontWeight: FontWeight.w700, // Thicker text
                  color: Colors.black, // Black text for analyze page
                )),
            Text('${widget.value}%',
                style: WFTextStyles.labelMedium.copyWith(
                  color: Colors.black, // Black text for analyze page
                  fontSize: 16, // Bigger text
                  fontWeight: FontWeight.w700, // Thicker text
                )),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: WFColors.gray700.withOpacity(0.6),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: widget.color != null
                        ? LinearGradient(colors: [widget.color!, widget.color!])
                        : WFGradients
                            .buttonGradient, // Default to button gradient for danger metrics
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
