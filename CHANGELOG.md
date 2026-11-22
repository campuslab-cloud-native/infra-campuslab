# Changelog

Todos los cambios relevantes de este repositorio se documentan aquí.
El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el versionamiento sigue [SemVer](https://semver.org/lang/es/).

## [Sin publicar]

- `report` recibe `KAFKA_BOOTSTRAP_SERVERS` y `REPORT_KAFKA_ENABLED` y se conecta a `kafka-net`.

## [1.0.0] - 2026-11-22

Primera versión estable.

- Compose de la aplicación (Oracle, microservicios y BFF), con variables de entorno por `.env`.
- Imágenes de los servicios etiquetadas con la versión (`CAMPUSLAB_VERSION`).
