# infra-campuslab

Repositorio de infraestructura de CampusLab. Los archivos Compose coordinan
servicios de aplicaciones y Oracle; Kafka y RabbitMQ se administran desde sus
repositorios y deben estar disponibles en la red antes de iniciar los clientes.

## Estructura y alcance

- `compose.yml`: entorno local de aplicaciones y Oracle. Los contextos de build
  apuntan a los repositorios `ms-campuslab-*` hermanos de este directorio.
- `compose.aws.yml`: overlay para ejecutar el Compose base en EC2. No es un
  archivo independiente y no crea Kafka ni RabbitMQ.
- No existe un `compose.aws.yml` común para los repositorios de microservicios;
  el único overlay AWS de esta distribución es el de `infra-campuslab`.

El Compose base publica el BFF en el puerto `8080`; las APIs de dominio no
publican puertos al host. Para el acceso público, el flujo documentado es
API Gateway → BFF → APIs internas. La configuración de un API Gateway o el
estado de una instancia AWS no se puede validar desde estos archivos Compose.

## Variables de entorno

Crear `.env` a partir de `.env.example` y sustituir los marcadores por valores
propios del entorno. No versionar `.env` ni guardar credenciales reales en
documentación.

| Variable | Uso |
|---|---|
| `ORACLE_PASSWORD` | Contraseña inicial del usuario administrador de Oracle Free |
| `CATALOG_DB_PASSWORD`, `BOOKINGS_DB_PASSWORD`, `AUDIT_DB_PASSWORD` | Usuarios de las bases de datos de los servicios |
| `RABBITMQ_HOST`, `RABBITMQ_USERNAME`, `RABBITMQ_PASSWORD` | Endpoint alcanzable desde la red de aplicaciones y credenciales del broker |
| `KAFKA_BOOTSTRAP_SERVERS` | Brokers alcanzables desde las aplicaciones |
| `AZURE_ISSUER_URI`, `AZURE_AUDIENCE` | Issuer y audience JWT que consume el BFF |
| `CORS_ALLOWED_ORIGINS` | Orígenes frontend permitidos por el BFF |

`SERVICES_HTTP_CONNECT_TIMEOUT` y `SERVICES_HTTP_READ_TIMEOUT` son opcionales;
el BFF usa `2s` y `5s` cuando no se especifican.

Las variables de conexión a RabbitMQ y Kafka deben usar nombres DNS o endpoints
resolubles desde los contenedores. No fijar direcciones IP en este README. El
ejemplo local de Kafka usa los nombres internos de su Compose; para AWS se
deben indicar los brokers alcanzables desde EC2.

## Conectividad entre servicios

| Dependencia | Puerto | Conexión desde aplicaciones |
|---|---:|---|
| Oracle Free del Compose base | `1521` | Servicio `oracle` en `campuslab-network` |
| RabbitMQ externo | `5672` | `RABBITMQ_HOST`; debe ser alcanzable desde la red de aplicaciones |
| Kafka local | `29092` interno; `9092`–`9094` publicados | `KAFKA_BOOTSTRAP_SERVERS` usa los listeners internos desde la red Docker |
| BFF | `8080` | Único puerto de aplicación publicado por el Compose base |

## Despliegue local

Requisitos: Docker Compose, los repositorios de aplicación clonados como
directorios hermanos y un broker RabbitMQ accesible desde los contenedores.

1. Iniciar Kafka desde `ms-campuslab-kafka` para crear la red externa
   `campuslab-kafka_kafka-net` requerida por el Compose local:

   ```bash
   docker compose up -d
   ```

2. Iniciar/verificar RabbitMQ desde su entorno local o proporcionar en
   `RABBITMQ_HOST` un endpoint alcanzable desde `campuslab-network`. El Compose
   de infraestructura no crea ni conecta automáticamente el broker.

3. Copiar `.env.example` a `.env`, ajustar las variables y, desde
   `infra-campuslab`, iniciar Oracle y las aplicaciones:

   ```bash
   docker compose config
   docker compose up -d --build
   docker compose ps
   ```

   Oracle espera estar saludable antes de iniciar Catalog, Bookings y Audit.
   Bookings espera además que Catalog haya iniciado.

4. Para apagar el conjunto local:

   ```bash
   docker compose down
   ```

Los scripts de inicialización de Oracle se ejecutan solamente al crear el
volumen por primera vez. Si el volumen ya existe, la rotación de contraseñas
requiere una operación coordinada en Oracle y en los secretos del despliegue.

## Despliegue en AWS

En EC2, usar el Compose base junto con su overlay:

```bash
docker compose -f compose.yml -f compose.aws.yml config
docker compose -f compose.yml -f compose.aws.yml up -d --build
docker compose -f compose.yml -f compose.aws.yml ps
```

El overlay coloca Bookings y Audit en la red de aplicaciones en vez de la red
Docker local de Kafka, y agrega `restart: unless-stopped` a Audit y Report.
Por ello, en AWS `KAFKA_BOOTSTRAP_SERVERS` debe apuntar a brokers alcanzables
por la red de EC2. RabbitMQ también es externo a este Compose y se alcanza con
`RABBITMQ_HOST`. La topología desplegada, DNS, Security Groups y secretos se
administran fuera de este repositorio; no asumir que el Compose local describe
el estado real de AWS.

## Reinicio automático

En el Compose base tienen `restart: unless-stopped`: Oracle, Catalog, Bookings,
Notify y BFF. En el overlay AWS se añade esa política a Audit y Report. La
política reinicia los contenedores detenidos salvo que se detengan
explícitamente; no sustituye health checks ni supervisión del despliegue.
