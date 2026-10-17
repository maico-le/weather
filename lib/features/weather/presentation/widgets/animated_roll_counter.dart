import 'package:flutter/material.dart';

/// Animated counter roll that smoothly ticks numbers upward or downward
/// whenever new weather data loads or the active city changes.
class AnimatedRollCounter extends StatefulWidget {
  final num value;
  final String prefix;
  final String suffix;
  final TextStyle style;
  final int decimals;
  final Duration duration;
  final Curve curve;

  const AnimatedRollCounter({
    super.key,
    required this.value,
    this.prefix = '',
    this.suffix = '',
    required this.style,
    this.decimals = 0,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedRollCounter> createState() => _AnimatedRollCounterState();
}

class _AnimatedRollCounterState extends State<AnimatedRollCounter> {
  late double _oldValue;

  @override
  void initState() {
    super.initState();
    // Start rolling from 0 on initial appearance
    _oldValue = 0;
  }

  @override
  void didUpdateWidget(covariant AnimatedRollCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value.toDouble();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: _oldValue, end: widget.value.toDouble()),
      duration: widget.duration,
      curve: widget.curve,
      builder: (context, val, child) {
        final formattedNumber = widget.decimals == 0
            ? val.round().toString()
            : val.toStringAsFixed(widget.decimals);
        return Text(
          '${widget.prefix}$formattedNumber${widget.suffix}',
          style: widget.style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
