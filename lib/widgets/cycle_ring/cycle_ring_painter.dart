import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:clune/app/theme/app_colors.dart';

/// Punto de color dentro del anillo de ciclo.
class CycleDot {
  final int day;
  final Color color;

  const CycleDot({required this.day, required this.color});
}

/// Datos necesarios para dibujar el anillo de ciclo.
class CycleRingData {
  final int cycleLength;
  final int periodLength;
  final int currentDay;
  final int fertileStart;
  final int fertileEnd;
  final int ovulationDay;
  final List<CycleDot> dots;

  /// True si el día seleccionado es el día real de hoy.
  final bool isToday;

  const CycleRingData({
    required this.cycleLength,
    required this.periodLength,
    required this.currentDay,
    required this.fertileStart,
    required this.fertileEnd,
    required this.ovulationDay,
    required this.dots,
    this.isToday = true,
  });
}

/// CustomPainter que dibuja el anillo circular del ciclo menstrual.
class CycleRingPainter extends CustomPainter {
  final CycleRingData data;
  final bool isDark;
  final Color ringTrackColor;

  /// Grosor del trazo del anillo.
  static const double strokeWidth = 10.0;

  /// Radio del badge del día actual.
  static const double badgeRadius = 22.0;

  CycleRingPainter({
    required this.data,
    this.isDark = false,
    this.ringTrackColor = AppColors.lightGray,
  });

  Color get _menstruationStart =>
      isDark ? const Color(0xFFE04B5A) : AppColors.primaryRed;

  Color get _menstruationEnd =>
      isDark ? const Color(0xFF9E5A62) : AppColors.primaryPink;

  Color get _fertileColor =>
      isDark ? const Color(0xFF1A9BAF) : AppColors.primaryTeal;

  Color get _ovulationColor =>
      isDark ? const Color(0xFF9B8AFF) : AppColors.purple;

  /// Evita solapamiento visual entre menstruación y ventana fértil.
  ({int periodLength, int fertileStart, int fertileEnd}) _resolvedSegments() {
    final maxPeriodEnd = (data.fertileStart - 1).clamp(1, data.cycleLength);
    final period = data.periodLength.clamp(1, maxPeriodEnd);
    final fertileStart = data.fertileStart.clamp(period + 1, data.cycleLength);
    final fertileEnd = data.fertileEnd.clamp(fertileStart, data.cycleLength);
    return (
      periodLength: period,
      fertileStart: fertileStart,
      fertileEnd: fertileEnd,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth - badgeRadius;

    // Anillo base
    _drawArc(canvas, center, radius, 0, data.cycleLength, ringTrackColor);

    // Segmento de menstruación (rojo → rosado)
    final segments = _resolvedSegments();
    if (segments.periodLength > 0) {
      _drawGradientArc(
        canvas,
        center,
        radius,
        0,
        segments.periodLength,
        _menstruationStart,
        _menstruationEnd,
      );
    }

    // Segmento de ventana fértil (turquesa)
    if (segments.fertileStart <= segments.fertileEnd &&
        segments.fertileStart <= data.cycleLength) {
      _drawArc(
        canvas,
        center,
        radius,
        segments.fertileStart - 1,
        segments.fertileEnd,
        _fertileColor,
      );
    }

    // Punto de ovulación (morado)
    _drawOvulationDot(canvas, center, radius, data.ovulationDay);

    // Puntos interiores de registros diarios
    _drawInnerDots(canvas, center, radius);

    // Badge del día seleccionado
    _drawCurrentDayBadge(canvas, center, radius, data.currentDay, data.isToday);
  }

  /// Convierte una posición táctil en día del ciclo (1-indexed), o null si está fuera del anillo.
  static int? positionToCycleDay({
    required Offset position,
    required Size size,
    required int cycleLength,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = position.dx - center.dx;
    final dy = position.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final radius = math.min(size.width, size.height) / 2 - strokeWidth - badgeRadius;
    final innerBound = radius - strokeWidth - 16;
    final outerBound = radius + strokeWidth + badgeRadius + 28;

    if (distance < innerBound || distance > outerBound) return null;

    var angle = math.atan2(dy, dx) + math.pi / 2;
    if (angle < 0) angle += 2 * math.pi;

    final fraction = angle / (2 * math.pi);
    final day = (fraction * cycleLength).floor() + 1;
    return day.clamp(1, cycleLength);
  }

  /// Convierte día del ciclo (1-indexed) a ángulo en radianes.
  /// El ciclo comienza arriba (-π/2) y avanza en sentido horario.
  double _dayToAngle(int day) {
    final fraction = (day - 0.5) / data.cycleLength;
    return -math.pi / 2 + fraction * 2 * math.pi;
  }

  /// Dibuja un arco sólido entre dos días del ciclo.
  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    int startDay,
    int endDay,
    Color color,
  ) {
    if (startDay >= endDay) return;
    final startAngle = _dayToAngle(startDay + 1);
    final endAngle = _dayToAngle(endDay + 1);
    var sweep = endAngle - startAngle;
    if (sweep < 0) sweep += 2 * math.pi;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweep,
      false,
      paint,
    );
  }

  /// Dibuja arco con gradiente de color.
  void _drawGradientArc(
    Canvas canvas,
    Offset center,
    double radius,
    int startDay,
    int endDay,
    Color startColor,
    Color endColor,
  ) {
    if (startDay >= endDay) return;
    final startAngle = _dayToAngle(startDay + 1);
    final endAngle = _dayToAngle(endDay + 1);
    var sweep = endAngle - startAngle;
    if (sweep < 0) sweep += 2 * math.pi;

    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweep,
        colors: [startColor, endColor],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(rect, startAngle, sweep, false, paint);
  }

  /// Dibuja punto morado en el día de ovulación.
  void _drawOvulationDot(Canvas canvas, Offset center, double radius, int day) {
    final angle = _dayToAngle(day);
    final x = center.dx + radius * math.cos(angle);
    final y = center.dy + radius * math.sin(angle);

    canvas.drawCircle(
      Offset(x, y),
      6,
      Paint()..color = _ovulationColor,
    );
  }

  /// Dibuja puntos interiores de registros diarios.
  void _drawInnerDots(Canvas canvas, Offset center, double radius) {
    final innerRadius = radius - strokeWidth - 8;
    final dotsByDay = <int, List<CycleDot>>{};

    for (final dot in data.dots) {
      dotsByDay.putIfAbsent(dot.day, () => []).add(dot);
    }

    dotsByDay.forEach((day, dots) {
      final angle = _dayToAngle(day);
      for (var i = 0; i < dots.length; i++) {
        final offset = (i - (dots.length - 1) / 2) * 5.0;
        final r = innerRadius - offset.abs();
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);

        canvas.drawCircle(
          Offset(x, y),
          4,
          Paint()..color = dots[i].color,
        );
      }
    });
  }

  /// Dibuja badge con el día seleccionado y flecha hacia el anillo.
  void _drawCurrentDayBadge(
    Canvas canvas,
    Offset center,
    double radius,
    int day,
    bool isToday,
  ) {
    final angle = _dayToAngle(day);
    final badgeDistance = radius + strokeWidth / 2 + badgeRadius + 4;
    final bx = center.dx + badgeDistance * math.cos(angle);
    final by = center.dy + badgeDistance * math.sin(angle);
    final badgeCenter = Offset(bx, by);

    final badgeFill = isToday
        ? (isDark ? const Color(0xFF2A2A2A) : Colors.white)
        : (isDark ? const Color(0xFF1A3A40) : AppColors.lightTeal);
    final badgeTextColor =
        isDark ? const Color(0xFFF5F5F5) : AppColors.darkText;
    final arrowColor =
        isDark ? const Color(0xFF888888) : AppColors.mediumGray;

    // Sombra suave
    canvas.drawCircle(
      badgeCenter,
      badgeRadius + 2,
      Paint()
        ..color = Colors.black.withValues(alpha: isDark ? 0.25 : 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    canvas.drawCircle(
      badgeCenter,
      badgeRadius,
      Paint()..color = badgeFill,
    );

    // Borde turquesa al explorar
    if (!isToday) {
      canvas.drawCircle(
        badgeCenter,
        badgeRadius,
        Paint()
          ..color = AppColors.primaryTeal
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Texto "Día N"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Día $day',
        style: TextStyle(
          color: badgeTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      badgeCenter - Offset(textPainter.width / 2, textPainter.height / 2),
    );

    // Flecha hacia el anillo
    final arrowStart = badgeCenter +
        Offset(
          -math.cos(angle) * (badgeRadius + 2),
          -math.sin(angle) * (badgeRadius + 2),
        );
    final arrowEnd = Offset(
      center.dx + (radius + strokeWidth / 2) * math.cos(angle),
      center.dy + (radius + strokeWidth / 2) * math.sin(angle),
    );

    canvas.drawLine(
      arrowStart,
      arrowEnd,
      Paint()
        ..color = arrowColor
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(covariant CycleRingPainter oldDelegate) {
    return oldDelegate.data.cycleLength != data.cycleLength ||
        oldDelegate.data.currentDay != data.currentDay ||
        oldDelegate.data.isToday != data.isToday ||
        oldDelegate.data.dots.length != data.dots.length ||
        oldDelegate.isDark != isDark ||
        oldDelegate.ringTrackColor != ringTrackColor;
  }
}
