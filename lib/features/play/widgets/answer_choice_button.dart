import 'package:flutter/material.dart';
import 'package:world_builders/core/theme.dart';
import 'package:world_builders/core/widgets/wb_icons.dart';
import 'package:world_builders/core/widgets/wb_pressable.dart';

enum AnswerState { idle, correct, wrong, dimmed }

class AnswerChoiceButton extends StatefulWidget {
  final String text;
  final int index;
  final AnswerState state;
  final VoidCallback? onTap;
  const AnswerChoiceButton({super.key, required this.text,
      required this.index, required this.state, this.onTap});

  @override
  State<AnswerChoiceButton> createState() => _AnswerChoiceButtonState();
}

class _AnswerChoiceButtonState extends State<AnswerChoiceButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _pressing = false;

  static const _labels = ['A', 'B', 'C', 'D'];

  // Vibrant state colours
  static const _correctBg    = Color(0xFF30D158);
  static const _correctBorder= Color(0xFF25A348);
  static const _wrongBg      = Color(0xFFFF3B30);
  static const _wrongBorder  = Color(0xFFCC2F27);
  static const _idleBg       = Color(0xFF1E1C30);
  static const _idleBorder   = Color(0xFF2E2B46);
  static const _dimBg        = Color(0xFF13121E);
  static const _dimBorder    = Color(0xFF1A1828);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 440));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.1), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.1, end: 0.96), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 0.96, end: 1.0), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(AnswerChoiceButton old) {
    super.didUpdateWidget(old);
    if (widget.state == AnswerState.correct && old.state != AnswerState.correct) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Color get _bg => switch (widget.state) {
    AnswerState.correct => _correctBg,
    AnswerState.wrong   => _wrongBg,
    AnswerState.dimmed  => _dimBg,
    AnswerState.idle    => _idleBg,
  };

  Color get _border => switch (widget.state) {
    AnswerState.correct => _correctBorder,
    AnswerState.wrong   => _wrongBorder,
    AnswerState.dimmed  => _dimBorder,
    AnswerState.idle    => _idleBorder,
  };

  Color get _textColor => switch (widget.state) {
    AnswerState.dimmed => Colors.white.withValues(alpha: 0.2),
    _                  => Colors.white,
  };

  Color get _labelBg => switch (widget.state) {
    AnswerState.idle    => Colors.white.withValues(alpha: 0.1),
    AnswerState.dimmed  => Colors.white.withValues(alpha: 0.03),
    _                   => Colors.white.withValues(alpha: 0.22),
  };

  @override
  Widget build(BuildContext context) {
    final isIdle = widget.state == AnswerState.idle;
    return GestureDetector(
      onTapDown: isIdle ? (_) => setState(() => _pressing = true) : null,
      onTapUp: isIdle ? (_) { setState(() => _pressing = false); widget.onTap?.call(); } : null,
      onTapCancel: isIdle ? () => setState(() => _pressing = false) : null,
      child: AnimatedBuilder(
        animation: _scale,
        builder: (_, child) => Transform.scale(
          scale: widget.state == AnswerState.correct
              ? _scale.value
              : (_pressing ? 0.97 : 1.0),
          child: child,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border, width: 1.5),
            boxShadow: widget.state == AnswerState.correct
                ? [BoxShadow(color: _correctBg.withValues(alpha: 0.4), blurRadius: 16, offset: const Offset(0,5))]
                : isIdle && !_pressing
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 10, offset: const Offset(0,3))]
                    : [],
          ),
          child: Row(children: [
            // Letter badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 34, height: 34,
              decoration: BoxDecoration(color: _labelBg, borderRadius: BorderRadius.circular(10)),
              alignment: Alignment.center,
              child: Text(_labels[widget.index % 4],
                  style: WBText.display(14, color: _textColor)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(widget.text,
                  style: WBText.body(16, color: _textColor, weight: FontWeight.w700)),
            ),
            if (widget.state == AnswerState.correct || widget.state == AnswerState.wrong)
              _StateCircle(isCorrect: widget.state == AnswerState.correct),
          ]),
        ),
      ),
    );
  }
}

class _StateCircle extends StatelessWidget {
  final bool isCorrect;
  const _StateCircle({required this.isCorrect});

  @override
  Widget build(BuildContext context) => Container(
    width: 28, height: 28,
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
    child: CustomPaint(painter: _TickCross(isCorrect)),
  );
}

class _TickCross extends CustomPainter {
  final bool isCorrect;
  _TickCross(this.isCorrect);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final cx = size.width / 2; final cy = size.height / 2; final r = size.width * 0.22;
    if (isCorrect) {
      canvas.drawPath(Path()
        ..moveTo(cx - r*1.3, cy)
        ..lineTo(cx - r*0.1, cy + r*1.1)
        ..lineTo(cx + r*1.5, cy - r*1.2), p);
    } else {
      canvas.drawLine(Offset(cx-r, cy-r), Offset(cx+r, cy+r), p);
      canvas.drawLine(Offset(cx+r, cy-r), Offset(cx-r, cy+r), p);
    }
  }

  @override
  bool shouldRepaint(_TickCross o) => o.isCorrect != isCorrect;
}
