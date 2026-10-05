# Changelog

Formato basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) · Versionado [SemVer](https://semver.org/lang/es/).

## [No publicado]

### Changed
- Reestructuración del repositorio: se eliminan las carpetas intermedias de datos y las capas de
  modelado (`staging`, `marts`) y se consolida la documentación en el README y el diccionario de datos.
- El script de carga unifica la creación de la tabla y la carga de las dos hojas en un solo archivo
  (`sql/00_carga.sql`), con las conversiones de fecha y de cliente vacío verificadas.
- La bitácora de trabajo sale del repositorio: es material de uso personal, no un entregable.

### Added
- `docs/diccionario-de-datos.md`: diccionario de columnas y notas de calidad del dato.
- `scripts/descargar_datos.py`: descarga y verifica el dataset original.

## [0.1.0] — Fase 0

### Added
- Estructura del repositorio, plantilla de pull request y de issue de pregunta de negocio.
- README con el problema de negocio, las preguntas a responder y las limitaciones del dataset.
