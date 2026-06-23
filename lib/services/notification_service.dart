/// Stub de servicio de notificaciones locales (preparado para implementación futura).
class NotificationService {
  /// Inicializa el plugin de notificaciones locales.
  Future<void> init() async {
    // TODO: Configurar flutter_local_notifications
    // - Solicitar permisos en iOS/Android
    // - Crear canal de notificaciones en Android
  }

  /// Programa recordatorio para registrar síntomas diarios.
  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    // TODO: Programar notificación diaria recurrente
  }

  /// Programa alerta de próximo periodo.
  Future<void> schedulePeriodReminder({required DateTime date, int daysBefore = 2}) async {
    // TODO: Programar notificación X días antes del periodo
  }

  /// Programa alerta de ventana fértil.
  Future<void> scheduleFertileWindowReminder({required DateTime startDate}) async {
    // TODO: Programar notificación al inicio de ventana fértil
  }

  /// Cancela todas las notificaciones programadas.
  Future<void> cancelAll() async {
    // TODO: Cancelar todas las notificaciones
  }
}
