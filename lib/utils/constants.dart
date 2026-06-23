/// Constantes globales de la aplicación.
class AppConstants {
  AppConstants._();

  /// Duración de ciclo por defecto cuando no hay historial.
  static const int defaultCycleLength = 28;

  /// Duración de periodo por defecto cuando no hay historial.
  static const int defaultPeriodLength = 5;

  /// Días típicos antes de ovulación respecto al próximo periodo.
  static const int lutealPhaseLength = 14;

  /// Días previos a ovulación incluidos en ventana fértil.
  static const int fertileDaysBefore = 5;

  /// Días posteriores a ovulación incluidos en ventana fértil.
  static const int fertileDaysAfter = 1;

  /// Ciclos analizados para predicción de síntomas.
  static const int symptomPredictionCycles = 6;

  /// Registros mínimos para predicciones personalizadas de dolor y ánimo.
  static const int minimumLogsForPredictions = 30;

  /// Umbral de desviación estándar para regularidad.
  static const double veryRegularStdDev = 2.0;
  static const double regularStdDev = 5.0;
}
