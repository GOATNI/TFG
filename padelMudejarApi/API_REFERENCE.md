# API Reference Guide

## Request/Response Examples

### 1. Crear Socio

**POST** `/api/socios`

```json
{
  "dniUsuario": "12345678A",
  "nombre": "Juan",
  "apellidos": "García López",
  "edad": 35,
  "telefono": "612345678",
  "correoElectronico": "juan@example.com",
  "idCarnet": "CARNET001"
}
```

**Response (201 Created):**
```json
{
  "dniUsuario": "12345678A",
  "nombre": "Juan",
  "apellidos": "García López",
  "edad": 35,
  "telefono": "612345678",
  "correoElectronico": "juan@example.com",
  "idCarnet": "CARNET001",
  "idPago": null
}
```

### 2. Crear Abono

**POST** `/api/abonos`

```json
{
  "dniSocio": "12345678A",
  "idTipoAbono": 1,
  "fechaInicio": "2025-03-22"
}
```

**Response (201 Created):**
```json
{
  "idAbono": 1,
  "dniSocio": "12345678A",
  "idTipoAbono": 1,
  "fechaInicio": "2025-03-22",
  "fechaFin": "2025-05-22",
  "estado": "ACTIVO"
}
```

### 3. Crear Reserva

**POST** `/api/reservas`

```json
{
  "dniSocio": "12345678A",
  "dniAdministrador": "87654321B",
  "idInstalacion": "PISTA1",
  "duracion": 1.5,
  "fechaHora": "2025-04-15T10:00:00"
}
```

**Response (201 Created):**
```json
{
  "idReserva": 1,
  "dniSocio": "12345678A",
  "dniAdministrador": "87654321B",
  "idInstalacion": "PISTA1",
  "duracion": 1.5,
  "fechaHora": "2025-04-15T10:00:00",
  "estadoReserva": "OCUPADA"
}
```

### 4. Cambiar Estado de Instalación

**PATCH** `/api/instalaciones/{id}/estado`

```json
{
  "nuevoEstado": "MANTENIMIENTO"
}
```

## Error Handling

Todos los errores retornan la siguiente estructura:

```json
{
  "status": 404,
  "error": "Not Found",
  "message": "Socio no encontrado con DNI: 12345678A",
  "timestamp": "2025-03-22T10:30:00"
}
```

### Códigos de Error Comunes

- **400 Bad Request**: Validación fallida o regla de negocio
- **404 Not Found**: Recurso no encontrado
- **500 Internal Server Error**: Error del servidor

## Validaciones

### DNI
- Formato: 8 dígitos + 1 letra (ej: 12345678A)

### Teléfono
- 9 dígitos (ej: 612345678)

### Email
- Formato válido de correo electrónico

### Edad
- Mínimo 18 años para socios

### Fechas
- Las reservas deben ser en el futuro
- La duración del abono se calcula automáticamente

## Estados

### EstadoAbono
- ACTIVO
- CANCELADO
- EXPIRADO

### EstadoPista
- ACTIVA
- MANTENIMIENTO
- FUERA_DE_SERVICIO

### EstadoReserva
- OCUPADA
- LIBRE
- CANCELADA

## Métodos de Pago

- EFECTIVO
- TARJETA_CREDITO
- TARJETA_DEBITO
- TRANSFERENCIA_BANCARIA
- PAYPAL

## Especialidades Técnico

- ELECTRICISTA
- FONTANERO
- CARPINTERIA
- MANTENIMIENTO_GENERAL
- LIMPIEZA_PROFUNDA

