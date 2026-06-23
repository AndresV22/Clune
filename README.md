# Clune

App de seguimiento del ciclo menstrual para iOS y Android, inspirada en la experiencia de [Clue](https://helloclue.com/). Diseñada para registrar síntomas con detalle, entender las fases del ciclo y tomar decisiones informadas con contenido educativo — todo con los datos guardados en el dispositivo.

> Información educativa. Clune no sustituye el consejo de un profesional de salud.

## Características

### Ciclo y predicciones
- **Anillo interactivo** con fases del ciclo, ventana fértil y exploración día a día.
- **Predicciones** de próximo periodo, ventana fértil, dolor y estado de ánimo (con historial suficiente).
- **Sincronización automática**: registrar sangrado puede actualizar el inicio del periodo si llegó antes de lo previsto.
- **Calendario** con colores por tipo de día y acceso rápido al registro.

### Registro diario
- Formulario extenso y **personalizable**: sangrado, dolor, ánimo, energía, antojos, sueño, nota diaria y más.
- Botón **flotante de guardar** para no depender de llegar al final del formulario.
- Historial de periodos integrado en el seguimiento.

### Perfil y datos
- **Perfil** con nombre, anticonceptivo y medicación para el dolor.
- **Exportar / importar** respaldo JSON (`clune_backup_v1`) con perfil, ciclos, registros, secciones visibles y **modo oscuro**.
- Importación con opción de combinar o reemplazar datos.

### Home y contenido
- Resumen del ciclo actual con mensajes según la fase o día fértil seleccionado.
- **Información hormonal** por sub-fase del ciclo (E2, progesterona, FSH).
- **Artículos sugeridos** según la fase del ciclo.
- Aviso cuando se usa anticonceptivo hormonal (ovulación/fertilidad pueden no aplicar).

### Experiencia
- **Modo oscuro** persistente.
- Interfaz en **español** (inglés parcial en traducciones).
- Menú rápido: perfil, personalización del registro y tema.

## Stack técnico

| Área | Tecnología |
|------|------------|
| Framework | Flutter 3.x / Dart 3.11+ |
| Estado y rutas | [GetX](https://pub.dev/packages/get) |
| Base de datos local | [Isar](https://isar.dev/) |
| Gráficos | [fl_chart](https://pub.dev/packages/fl_chart) |
| Respaldo | `file_picker`, `share_plus` |
| Preferencias | `shared_preferences` |

## Requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) compatible con Dart `^3.11.0`
- Xcode (iOS) o Android Studio / SDK (Android)
- Para iOS en dispositivo físico: cuenta de desarrollador Apple y confianza en el certificado de desarrollo

## Instalación y ejecución

```bash
# Clonar el repositorio
git clone git@github.com:AndresV22/Clune.git
cd Clune

# Dependencias
flutter pub get

# Generar código Isar (tras cambios en modelos)
dart run build_runner build --delete-conflicting-outputs

# Listar dispositivos
flutter devices

# Ejecutar
flutter run
```

### Iconos de la app

```bash
dart run flutter_launcher_icons
```

## Respaldo JSON

Formato `clune_backup_v1`:

```json
{
  "version": 1,
  "exportedAt": "2026-06-19T12:00:00.000Z",
  "profile": { },
  "cycles": [ ],
  "dailyLogs": [ ],
  "logSectionPreferences": { "enabledSectionIds": [ ] },
  "settings": { "darkMode": false }
}
```

Exportar e importar desde **Perfil → Exportar / Importar datos**.

> **Nota:** Isar no tiene migraciones formales entre versiones de esquema. Tras cambios importantes en modelos, conviene exportar antes de actualizar o reinstalar en dispositivos con datos antiguos.

## Estructura del proyecto

```
lib/
├── app/           # Tema, rutas, bindings
├── controllers/   # Lógica de pantallas (GetX)
├── models/        # Isar: DailyLog, UserProfile, CycleRecord
├── repositories/  # Acceso a datos
├── services/      # Predicciones, fases, respaldo, hormonas
├── views/         # UI por pantalla
├── widgets/       # Componentes reutilizables
├── translations/  # es_ES, en_US
└── utils/         # Enums, fechas, constantes
```

## Desarrollo

```bash
# Análisis estático
dart analyze lib

# Tests
flutter test
```

Tras modificar modelos `@collection` en `lib/models/`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Historial de versiones

Ver [CHANGELOG.md](CHANGELOG.md).

## Licencia

Proyecto privado. Todos los derechos reservados.
