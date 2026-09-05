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
