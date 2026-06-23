import 'package:intl/intl.dart';

/// Utilidades para manipulación y formato de fechas.
class AppDateUtils {
  AppDateUtils._();

  /// Normaliza una fecha a medianoche (sin hora).
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Diferencia en días entre dos fechas normalizadas.
  static int daysBetween(DateTime from, DateTime to) {
    final start = normalizeDate(from);
    final end = normalizeDate(to);
    return end.difference(start).inDays;
  }

  /// Formato corto: "18 Feb".
  static String formatShortDate(DateTime date, {String locale = 'es_ES'}) {
    return DateFormat('d MMM', locale).format(date);
  }

  /// Formato completo: "Hoy, 18 Feb" o "18 Feb 2026".
  static String formatTodayOrDate(DateTime date, {String locale = 'es_ES'}) {
    final today = normalizeDate(DateTime.now());
    final target = normalizeDate(date);
    if (target == today) {
      return 'Hoy, ${formatShortDate(date, locale: locale)}';
    }
    return DateFormat('d MMM yyyy', locale).format(date);
  }

  /// Formato de rango: "Del 14 al 19 de marzo".
  static String formatDateRange(DateTime start, DateTime end, {String locale = 'es_ES'}) {
    if (start.month == end.month) {
      return 'Del ${start.day} al ${end.day} de ${DateFormat('MMMM', locale).format(end)}';
    }
    return 'Del ${formatShortDate(start, locale: locale)} al ${formatShortDate(end, locale: locale)}';
  }

  /// Verifica si una fecha está dentro de un rango inclusive.
  static bool isDateInRange(DateTime date, DateTime start, DateTime end) {
    final d = normalizeDate(date);
    final s = normalizeDate(start);
    final e = normalizeDate(end);
    return !d.isBefore(s) && !d.isAfter(e);
  }

  /// Primer día del mes.
  static DateTime firstDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Último día del mes.
  static DateTime lastDayOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  /// Días del mes para calendario (incluye padding inicial, semana empieza en lunes).
  static List<DateTime?> getCalendarDays(DateTime month) {
    final first = firstDayOfMonth(month);
    final last = lastDayOfMonth(month);
    // Lunes = 0, Domingo = 6
    final startWeekday = (first.weekday - 1) % 7;
    final days = <DateTime?>[];

    for (var i = 0; i < startWeekday; i++) {
      days.add(null);
    }
    for (var d = first.day; d <= last.day; d++) {
      days.add(DateTime(month.year, month.month, d));
    }
    return days;
  }
}
