/// Stub de servicio de sincronización con Firebase (implementación futura).
abstract class SyncService {
  /// Sincroniza datos locales con Firebase Firestore.
  Future<void> syncToCloud();

  /// Descarga datos de Firebase al almacenamiento local.
  Future<void> syncFromCloud();

  /// Verifica si hay cambios pendientes de sincronizar.
  Future<bool> hasPendingChanges();
}

/// Implementación local sin sincronización (placeholder).
class LocalSyncService implements SyncService {
  @override
  Future<void> syncToCloud() async {
    // TODO: Implementar sync con Firebase Firestore
  }

  @override
  Future<void> syncFromCloud() async {
    // TODO: Implementar descarga desde Firebase
  }

  @override
  Future<bool> hasPendingChanges() async => false;
}
