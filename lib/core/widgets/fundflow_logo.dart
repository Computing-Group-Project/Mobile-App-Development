import 'package:flutter/material.dart';

/// Custom FundFlow logo — two stacked cards on a teal rounded square.
class FundFlowLogo extends StatelessWidget {
  final double size;

  const FundFlowLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF01C38D),
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF01C38D).withValues(alpha: 0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _LogoPainter(),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cardW = size.width * 0.62;
    final cardH = size.height * 0.40;
    final radius = Radius.circular(size.width * 0.10);

    // ── Back card (semi-transparent white, offset up-left) ──────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.46, size.height * 0.42),
          width: cardW,
          height: cardH,
        ),
        radius,
      ),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.30)
        ..style = PaintingStyle.fill,
    );

    // ── Front card (solid white, offset down-right) ──────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width * 0.54, size.height * 0.57),
          width: cardW,
          height: cardH,
        ),
        radius,
      ),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );

    // ── Teal strip across top of front card (like a card header) ────────────
    final stripRect = Rect.fromLTWH(
      size.width * 0.54 - cardW / 2,
      size.height * 0.57 - cardH / 2,
      cardW,
      cardH * 0.30,
    );
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.54, size.height * 0.57),
        width: cardW,
        height: cardH,
      ),
      radius,
    ));
    canvas.drawRect(
      stripRect,
      Paint()
        ..color = const Color(0xFF01C38D).withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );
    canvas.restore();

    // ── Coin circle on front card ────────────────────────────────────────────
    canvas.drawCircle(
      Offset(size.width * 0.64, size.height * 0.60),
      size.width * 0.075,
      Paint()
        ..color = const Color(0xFF01C38D)
        ..style = PaintingStyle.fill,
    );

    // ── Small upward-right arrow (flow indicator) ────────────────────────────
    final arrowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = size.width * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final ax = size.width * 0.375;
    final ay = size.height * 0.625;
    final tipX = ax + size.width * 0.095;
    final tipY = ay - size.height * 0.095;

    // Arrow shaft
    canvas.drawLine(Offset(ax, ay), Offset(tipX, tipY), arrowPaint);
    // Arrow head
    canvas.drawLine(Offset(tipX, tipY), Offset(tipX - size.width * 0.055, tipY), arrowPaint);
    canvas.drawLine(Offset(tipX, tipY), Offset(tipX, tipY + size.height * 0.055), arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
