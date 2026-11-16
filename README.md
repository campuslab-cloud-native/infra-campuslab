# infra-campuslab

Infraestructura general de CampusLab.

## Tecnologías

- AWS EC2
- AWS API Gateway
- Docker
- Docker Compose

## Arquitectura

```text
Angular
↓
Azure AD / MSAL
↓
JWT
↓
AWS API Gateway
↓
ms-campuslab-bff
↓
Microservicios de dominio
```

## Instancias EC2

```text
ec2-apps
ec2-mq
ec2-kafka
```

## ec2-apps

```text
ms-campuslab-bff
ms-campuslab-bookings
ms-campuslab-catalog
ms-campuslab-notify
ms-campuslab-report
ms-campuslab-audit
```

## ec2-mq

```text
RabbitMQ
RabbitMQ Management
```

## ec2-kafka

```text
Kafka
Zookeeper
Kafka UI
```

## Docker Compose

```text
/apps/compose.yml
/mq/compose.yml
/kafka/compose.yml
```

Para iniciar la base Oracle local, define `ORACLE_PASSWORD`,
`CATALOG_DB_PASSWORD`, `BOOKINGS_DB_PASSWORD` y `AUDIT_DB_PASSWORD` en un
archivo `.env` local no versionado. El script de inicialización usa esas
variables para crear los usuarios de los servicios.

Los scripts de inicialización de Oracle solo se ejecutan cuando se crea el
volumen de datos por primera vez. Si el volumen ya existe, la rotación de
contraseñas debe autorizarse y ejecutarse manualmente en Oracle, coordinada con
la actualización de los secretos de despliegue. No se modifican aquí las
credenciales de bases desplegadas.

## API Gateway

Tipo:

```text
HTTP API
```

Autorización:

```text
JWT Authorizer
```

Issuer:

```text
https://login.microsoftonline.com/<TENANT_ID>/v2.0
```

Audience:

```text
api://<API_CLIENT_ID>
```

## Flujo seguro

```text
JWT
↓
AWS API Gateway
↓
ms-campuslab-bff
↓
Microservicio de dominio
```

## Puertos principales

```text
HTTP APIs internas
5672 RabbitMQ
9092 Kafka
```

## Despliegue

Los componentes de CampusLab serán desplegados mediante Docker y Docker Compose sobre instancias AWS EC2.
