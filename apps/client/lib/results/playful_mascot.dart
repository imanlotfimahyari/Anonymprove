import 'package:flutter/material.dart';

import 'playful_result.dart';

class PlayfulMascot extends StatelessWidget {
  const PlayfulMascot({required this.character, this.size = 84, super.key});

  final PlayfulCharacter character;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _PlayfulMascotPainter(
          character: character,
          colors: Theme.of(context).colorScheme,
        ),
      ),
    );
  }
}

class _PlayfulMascotPainter extends CustomPainter {
  const _PlayfulMascotPainter({required this.character, required this.colors});

  final PlayfulCharacter character;
  final ColorScheme colors;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas.save();
    canvas.scale(scale);

    final background = Paint()..color = colors.primaryContainer;
    final body = Paint()..color = colors.secondaryContainer;
    final accent = Paint()..color = colors.surface;
    final ink = Paint()
      ..color = colors.onPrimaryContainer
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(const Offset(50, 50), 48, background);

    switch (character) {
      case PlayfulCharacter.thoughtfulOwl:
        _drawOwl(canvas, body, accent, ink);
      case PlayfulCharacter.helpingOctopus:
        _drawOctopus(canvas, body, accent, ink);
      case PlayfulCharacter.clearSignalFox:
        _drawFox(canvas, body, accent, ink);
      case PlayfulCharacter.steadyTurtle:
        _drawTurtle(canvas, body, accent, ink);
      case PlayfulCharacter.respectfulHedgehog:
        _drawHedgehog(canvas, body, accent, ink);
      case PlayfulCharacter.calmElephant:
        _drawElephant(canvas, body, accent, ink);
      case PlayfulCharacter.balancedCapybara:
        _drawCapybara(canvas, body, accent, ink);
    }

    canvas.restore();
  }

  void _drawOwl(Canvas canvas, Paint body, Paint accent, Paint ink) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 57), width: 52, height: 58),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 57), width: 52, height: 58),
      ink,
    );

    _filledEye(canvas, const Offset(39, 47), accent, ink, 11);
    _filledEye(canvas, const Offset(61, 47), accent, ink, 11);

    final beak = Path()
      ..moveTo(46, 59)
      ..lineTo(54, 59)
      ..lineTo(50, 67)
      ..close();

    canvas.drawPath(beak, accent);
    canvas.drawPath(beak, ink);

    canvas.drawLine(const Offset(35, 74), const Offset(29, 82), ink);
    canvas.drawLine(const Offset(65, 74), const Offset(71, 82), ink);
  }

  void _drawOctopus(Canvas canvas, Paint body, Paint accent, Paint ink) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 43), width: 50, height: 42),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 43), width: 50, height: 42),
      ink,
    );

    _simpleEyes(canvas, const Offset(42, 42), const Offset(58, 42), ink);

    for (final x in [31.0, 42.0, 53.0, 64.0]) {
      final tentacle = Path()
        ..moveTo(x, 59)
        ..quadraticBezierTo(x - 7, 72, x, 82)
        ..quadraticBezierTo(x + 6, 88, x + 10, 79);
      canvas.drawPath(tentacle, ink);
    }

    canvas.drawArc(const Rect.fromLTWH(43, 47, 14, 12), 0.2, 2.7, false, ink);
  }

  void _drawFox(Canvas canvas, Paint body, Paint accent, Paint ink) {
    final leftEar = Path()
      ..moveTo(29, 38)
      ..lineTo(31, 17)
      ..lineTo(44, 34)
      ..close();

    final rightEar = Path()
      ..moveTo(56, 34)
      ..lineTo(69, 17)
      ..lineTo(71, 38)
      ..close();

    canvas.drawPath(leftEar, body);
    canvas.drawPath(rightEar, body);
    canvas.drawPath(leftEar, ink);
    canvas.drawPath(rightEar, ink);

    final face = Path()
      ..moveTo(28, 38)
      ..quadraticBezierTo(50, 25, 72, 38)
      ..quadraticBezierTo(68, 70, 50, 82)
      ..quadraticBezierTo(32, 70, 28, 38)
      ..close();

    canvas.drawPath(face, body);
    canvas.drawPath(face, ink);

    _simpleEyes(canvas, const Offset(41, 48), const Offset(59, 48), ink);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 63), width: 27, height: 18),
      accent,
    );

    canvas.drawCircle(
      const Offset(50, 61),
      3.5,
      ink..style = PaintingStyle.fill,
    );
    ink.style = PaintingStyle.stroke;

    canvas.drawArc(const Rect.fromLTWH(43, 61, 14, 10), 0.1, 2.9, false, ink);
  }

  void _drawTurtle(Canvas canvas, Paint body, Paint accent, Paint ink) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(48, 54), width: 55, height: 40),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(48, 54), width: 55, height: 40),
      ink,
    );

    canvas.drawCircle(const Offset(77, 52), 10, accent);
    canvas.drawCircle(const Offset(77, 52), 10, ink);

    canvas.drawCircle(
      const Offset(80, 49),
      2.5,
      ink..style = PaintingStyle.fill,
    );
    ink.style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(32, 72), const Offset(27, 82), ink);
    canvas.drawLine(const Offset(57, 72), const Offset(62, 82), ink);

    canvas.drawLine(const Offset(33, 46), const Offset(63, 64), ink);
    canvas.drawLine(const Offset(63, 46), const Offset(33, 64), ink);
  }

  void _drawHedgehog(Canvas canvas, Paint body, Paint accent, Paint ink) {
    final spikes = Path()
      ..moveTo(25, 66)
      ..lineTo(19, 53)
      ..lineTo(28, 50)
      ..lineTo(21, 39)
      ..lineTo(32, 38)
      ..lineTo(30, 25)
      ..lineTo(42, 31)
      ..lineTo(50, 20)
      ..lineTo(57, 33)
      ..lineTo(70, 28)
      ..lineTo(68, 43)
      ..lineTo(78, 48)
      ..lineTo(69, 57)
      ..lineTo(73, 69)
      ..close();

    canvas.drawPath(spikes, body);
    canvas.drawPath(spikes, ink);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(55, 56), width: 40, height: 35),
      accent,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(55, 56), width: 40, height: 35),
      ink,
    );

    canvas.drawCircle(
      const Offset(60, 50),
      2.5,
      ink..style = PaintingStyle.fill,
    );
    canvas.drawCircle(const Offset(75, 58), 3, ink);
    ink.style = PaintingStyle.stroke;
  }

  void _drawElephant(Canvas canvas, Paint body, Paint accent, Paint ink) {
    canvas.drawCircle(const Offset(31, 48), 17, accent);
    canvas.drawCircle(const Offset(69, 48), 17, accent);
    canvas.drawCircle(const Offset(31, 48), 17, ink);
    canvas.drawCircle(const Offset(69, 48), 17, ink);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 49), width: 43, height: 50),
      body,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 49), width: 43, height: 50),
      ink,
    );

    _simpleEyes(canvas, const Offset(42, 44), const Offset(58, 44), ink);

    final trunk = Path()
      ..moveTo(47, 59)
      ..quadraticBezierTo(46, 76, 52, 82)
      ..quadraticBezierTo(58, 86, 61, 77);
    canvas.drawPath(trunk, ink);
  }

  void _drawCapybara(Canvas canvas, Paint body, Paint accent, Paint ink) {
    canvas.drawCircle(const Offset(34, 29), 7, body);
    canvas.drawCircle(const Offset(66, 29), 7, body);
    canvas.drawCircle(const Offset(34, 29), 7, ink);
    canvas.drawCircle(const Offset(66, 29), 7, ink);

    final head = RRect.fromRectAndRadius(
      const Rect.fromLTWH(27, 28, 46, 52),
      const Radius.circular(18),
    );

    canvas.drawRRect(head, body);
    canvas.drawRRect(head, ink);

    _simpleEyes(canvas, const Offset(41, 48), const Offset(59, 48), ink);

    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 64), width: 26, height: 17),
      accent,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(50, 64), width: 26, height: 17),
      ink,
    );

    canvas.drawCircle(
      const Offset(50, 60),
      2.7,
      ink..style = PaintingStyle.fill,
    );
    ink.style = PaintingStyle.stroke;
  }

  void _filledEye(
    Canvas canvas,
    Offset center,
    Paint fill,
    Paint ink,
    double radius,
  ) {
    canvas.drawCircle(center, radius, fill);
    canvas.drawCircle(center, radius, ink);

    final pupil = Paint()..color = colors.onPrimaryContainer;
    canvas.drawCircle(center, 3.5, pupil);
  }

  void _simpleEyes(Canvas canvas, Offset left, Offset right, Paint ink) {
    final pupil = Paint()..color = colors.onPrimaryContainer;
    canvas.drawCircle(left, 3, pupil);
    canvas.drawCircle(right, 3, pupil);
  }

  @override
  bool shouldRepaint(covariant _PlayfulMascotPainter oldDelegate) {
    return oldDelegate.character != character || oldDelegate.colors != colors;
  }
}
