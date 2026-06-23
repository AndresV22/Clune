# Changelog

Todos los cambios relevantes de Clune se documentan en este archivo.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/),
y el proyecto adhiere a [Versionado Semántico](https://semver.org/lang/es/).

## [1.0.0] - 2026-06-19

Primera versión funcional de Clune: seguimiento del ciclo, registro diario completo, perfil, respaldo local y contenido educativo en Home.

### Añadido

#### Ciclo y navegación
- Pantalla Home con anillo de ciclo interactivo (explorar días, volver a hoy).
- Navegación inferior: Ciclo, Calendario, Seguimiento, Análisis y Artículos.
- Calendario mensual con tipos de día (menstruación, fértil, ovulación).
- Onboarding inicial con perfil básico.

#### Registro diario
- Modelo `DailyLog` ampliado: sangrado (flujo y color), dolor (6 niveles), cólicos, flujo vaginal, actividad sexual, deseo, ánimo (incl. enojada), energía, SPM, síntomas, antojos, digestión, heces, calidad de sueño, nota diaria y medicación.
- Secciones **personalizables** (`LogSectionsSettingsView`).
- Botón flotante **Guardar registro**.
- Validación de nota diaria (solo letras, números y espacios).

#### Predicciones y análisis
- Predicción de próximo periodo y **próxima ventana fértil**.
- Predicciones personalizadas de dolor y ánimo (≥ 30 registros).
- Recordatorio de medicación para el dolor.
- Pantalla de análisis con gráficos de historial (ciclo, periodo, dolor, síntomas, ánimo).

#### Sincronización ciclo ↔ sangrado
- `CycleSyncService`: si se registra sangrado y el periodo predicho era futuro, actualiza `CycleRecord` y refresca predicciones.

#### Perfil y respaldo
- `ProfileView`: nombre, anticonceptivos, medicación, personalización del registro.
- `DataBackupService` con formato `clune_backup_v1` (exportar / importar vía `file_picker`).
- Respaldo incluye perfil, ciclos, registros, preferencias de secciones y **modo oscuro**.

#### Home y contenido educativo
- `HormoneInfoService` y tarjeta de sub-fase hormonal (E2, PG, FSH).
- Artículos sugeridos según fase del ciclo.
- Aviso de anticonceptivo hormonal en Home.
- Enlace **Posible día fértil** con sheet educativo sobre ventana fértil e indicadores.
- Footer: «Con amor para la Popolli <3».

#### UI y experiencia
- Modo oscuro con tema `CluneThemeColors` y textos adaptados.
- Menú hamburguesa simplificado: modo oscuro, perfil y personalizar seguimiento.
- Easter egg en el título «Tu ciclo actual» (5 toques).

#### Artículos
- Biblioteca local JSON con artículos educativos por categoría.
- Vista de detalle con fuentes y disclaimer médico.

#### Internacionalización
- Traducciones principales en `es_es.dart`.
- Stub parcial en `en_us.dart`.

### Corregido
- Solapamiento visual entre segmentos de menstruación y ventana fértil en el anillo.
- Promedio de duración de periodo basado en últimos ciclos completados (2–10 días).
- Overflow del menú hamburguesa en pantallas pequeñas (scroll).
- Clave de traducción faltante `menu_dark_mode`.
- Textos en modo oscuro en registro diario e historial de periodos.

### Técnico
- Isar 3 con `build_runner` para modelos generados.
- GetX: bindings, rutas nombradas y controladores por pantalla.
- Dependencias: `fl_chart`, `file_picker`, `share_plus`, `google_fonts`, `shared_preferences`.

---

[1.0.0]: https://github.com/AndresV22/Clune/releases/tag/v1.0.0
