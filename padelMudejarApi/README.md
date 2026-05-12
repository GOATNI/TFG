# PadelMudéjar API

REST API Backend para Club de Pádel "Mudéjar"

## Requisitos Previos

- Java 25
- Maven 3.9+
- MySQL 8.0+

## Configuración de Base de Datos

Crear base de datos:
```sql
CREATE DATABASE padelApp;
```

Actualizar credenciales en `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/padelApp
spring.datasource.username=root
spring.datasource.password=tuContraseña
```

## Compilar y Ejecutar

### Compilar
```bash
mvn clean package
```

### Ejecutar
```bash
mvn spring-boot:run
```

La API estará disponible en: `http://localhost:3000`

## Estructura del Proyecto

### Módulos de Desarrollo

**Desarrollador A (Socios y Abonos):**
- Gestión de Socios
- Gestión de Abonos Temporada
- Tipos de Abono

**Desarrollador B (Instalaciones y Reservas):**
- Gestión de Administradores
- Gestión de Instalaciones (Pistas)
- Gestión de Reservas

## Endpoints Principales

### Socios
- `POST /api/socios` - Crear socio
- `GET /api/socios` - Listar socios
- `GET /api/socios/{dni}` - Obtener socio
- `PUT /api/socios/{dni}` - Actualizar socio
- `DELETE /api/socios/{dni}` - Eliminar socio

### Abonos
- `POST /api/abonos` - Crear abono
- `GET /api/abonos` - Listar abonos
- `GET /api/abonos/{id}` - Obtener abono
- `GET /api/abonos/socio/{dni}` - Abonos por socio
- `DELETE /api/abonos/{id}` - Cancelar abono

### Administradores
- `POST /api/administradores` - Crear administrador
- `GET /api/administradores` - Listar administradores
- `GET /api/administradores/{dni}` - Obtener administrador
- `DELETE /api/administradores/{dni}` - Desactivar administrador

### Instalaciones
- `GET /api/instalaciones` - Listar instalaciones
- `GET /api/instalaciones/{id}` - Obtener instalación
- `GET /api/instalaciones/estado/{estado}` - Filtrar por estado
- `PATCH /api/instalaciones/{id}/estado` - Cambiar estado
- `PATCH /api/instalaciones/{id}/tecnico` - Asignar técnico

### Reservas
- `POST /api/reservas` - Crear reserva
- `GET /api/reservas` - Listar reservas
- `GET /api/reservas/{id}` - Obtener reserva
- `GET /api/reservas/socio/{dni}` - Reservas por socio
- `DELETE /api/reservas/{id}` - Cancelar reserva

## Tecnologías

- Spring Boot 4.0.4
- Spring Data JPA
- MySQL 8.0
- Lombok
- ModelMapper
- Jakarta Bean Validation

