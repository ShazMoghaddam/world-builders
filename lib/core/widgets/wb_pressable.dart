import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Universal press-feedback wrapper.
/// Wraps ANY widget with scale + color-fade on tap.
/// Use this for cards, list tiles, zone rows — anything that isn't already a WBButton.
class WBPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const WBPressable({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius,
  });

  @override
  State<WBPressable> createState() => _WBPressableState();
}

class _WBPressableState extends State<WBPressable>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    _fade = Tween(begin: 1.0, end: 0.78).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.onTap == null) return;
    _ctrl.forward();
  }

  void _onTapUp(_) {
    if (widget.onTap == null) return;
    _ctrl.reverse();
    HapticFeedback.selectionClick();
    widget.onTap!();
  }

  void _onTapCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final br = widget.borderRadius ?? BorderRadius.circular(20);
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: Opacity(opacity: _fade.value, child: child),
        ),
        child: ClipRRect(borderRadius: br, child: widget.child),
      ),
    );
  }
}
