import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/features/bingo/models/bingo_cell.dart';

class BingoCellWidget extends StatefulWidget {
  final BingoCell cell;
  final bool isInWinningLine;
  final VoidCallback? onTap;

  const BingoCellWidget({
    super.key,
    required this.cell,
    required this.isInWinningLine,
    this.onTap,
  });

  @override
  State<BingoCellWidget> createState() => _BingoCellWidgetState();
}

class _BingoCellWidgetState extends State<BingoCellWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.18), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.94), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(BingoCellWidget old) {
    super.didUpdateWidget(old);
    if (widget.cell.isCompleted && !old.cell.isCompleted) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Zone-category colour coding
  Color get _categoryColor {
    final id = widget.cell.id;
    if (id.startsWith('math')) return WBColors.mathAmber;
    if (id.startsWith('lit'))  return WBColors.litBlue;
    if (id.startsWith('sci'))  return WBColors.sciGreen;
    if (id.startsWith('life')) return WBColors.lifePurple;
    return WBColors.lifePurple; // free space
  }

  Color get _bgColor {
    if (widget.cell.isFree)        return WBColors.lifePurple;
    if (widget.isInWinningLine)    return WBColors.sciGreen;
    if (widget.cell.isCompleted)   return _categoryColor;
    return WBColors.cardWhite;
  }

  Color get _borderColor {
    if (widget.cell.isFree)        return WBColors.lifePurple;
    if (widget.isInWinningLine)    return WBColors.sciGreen;
    if (widget.cell.isCompleted)   return _categoryColor;
    return _categoryColor.withValues(alpha: 0.18);
  }

  Color get _textColor {
    if (widget.cell.isCompleted || widget.cell.isFree || widget.isInWinningLine) {
      return Colors.white;
    }
    return WBColors.textPrimary;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) => Transform.scale(
          scale: widget.cell.isCompleted ? _scale.value : 1.0,
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          decoration: BoxDecoration(
            color: _bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor, width: 1.5),
            boxShadow: (widget.cell.isCompleted || widget.isInWinningLine)
                ? [
                    BoxShadow(
                      color: _categoryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.cell.emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Text(
                  widget.cell.label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.cell.isCompleted && !widget.cell.isFree)
                Text('✓',
                    style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ),
    );
  }
}
