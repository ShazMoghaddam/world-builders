import 'package:flutter/material.dart';

/// Reusable pressable button used across the whole app.
/// Press = scale down + darken. Release = spring back.
/// Use this everywhere instead of GestureDetector + Container.
class WBButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color color;
  final BorderRadius? radius;
  final EdgeInsets padding;
  final List<BoxShadow>? shadows;
  final Border? border;

  const WBButton({
    super.key,
    required this.child,
    required this.color,
    this.onTap,
    this.radius,
    this.padding = const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
    this.shadows,
    this.border,
  });

  @override
  State<WBButton> createState() => _WBButtonState();
}

class _WBButtonState extends State<WBButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _brightness;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 200),
    );
    _scale = Tween(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _brightness = Tween(begin: 1.0, end: 0.82)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final br = widget.radius ?? BorderRadius.circular(18);
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null ? (_) {
        _ctrl.reverse();
        widget.onTap!();
      } : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, child) => Transform.scale(
          scale: _scale.value,
          child: ColorFiltered(
            colorFilter: ColorFilter.matrix([
              _brightness.value,0,0,0,0,
              0,_brightness.value,0,0,0,
              0,0,_brightness.value,0,0,
              0,0,0,1,0,
            ]),
            child: child,
          ),
        ),
        child: Container(
          width: double.infinity,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: br,
            border: widget.border,
            boxShadow: widget.shadows,
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Small pill/icon button (close, back, skip etc)
class WBIconButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color bgColor;
  final Color borderColor;
  final double size;
  final double radius;

  const WBIconButton({
    super.key,
    required this.child,
    required this.bgColor,
    required this.borderColor,
    this.onTap,
    this.size = 38,
    this.radius = 12,
  });

  @override
  State<WBIconButton> createState() => _WBIconButtonState();
}

class _WBIconButtonState extends State<WBIconButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => _ctrl.forward() : null,
      onTapUp: widget.onTap != null ? (_) { _ctrl.reverse(); widget.onTap!(); } : null,
      onTapCancel: widget.onTap != null ? () => _ctrl.reverse() : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: widget.size, height: widget.size,
          decoration: BoxDecoration(
            color: widget.bgColor,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: widget.borderColor),
          ),
          alignment: Alignment.center,
          child: widget.child,
        ),
      ),
    );
  }
}
