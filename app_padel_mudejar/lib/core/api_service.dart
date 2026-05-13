import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://clubpadelmudejar.starglob.com/api';

  // INSTALACIONES
  static Future<List<dynamic>> getInstalaciones({String? estado}) async {
    final uri = Uri.parse(
      '$baseUrl/instalaciones',
    ).replace(queryParameters: estado != null ? {'estado': estado} : null);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'] as List<dynamic>;
    throw Exception(body['message'] ?? 'Error al cargar instalaciones');
  }

  static Future<Map<String, dynamic>> getInstalacion(String id) async {
    final res = await http.get(Uri.parse('$baseUrl/instalaciones/$id'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Instalación no encontrada');
  }

  // DISPONIBILIDAD Y RESERVAS

  static Future<Map<String, dynamic>> getHorasDisponibles({
    required String fecha,
    required String instalacion,
    required int duracion,
  }) async {
    final uri = Uri.parse('$baseUrl/reservas/horas-disponibles').replace(
      queryParameters: {
        'fecha': fecha,
        'instalacion': instalacion,
        'duracion': duracion.toString(),
      },
    );
    final res = await http.get(uri);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getProximaDisponible({
    required String instalacion,
    required int duracion,
  }) async {
    final uri = Uri.parse('$baseUrl/reservas/proxima-disponible').replace(
      queryParameters: {
        'instalacion': instalacion,
        'duracion': duracion.toString(),
      },
    );
    final res = await http.get(uri);
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> crearReserva({
    required String dniSocio,
    required String instalacion,
    required int idTarifa,
    required String fechaHora,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/reservas'),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode({
        'dniSocio': dniSocio,
        'instalacion': instalacion,
        'idTarifa': idTarifa,
        'fechaHora': fechaHora,
      }),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> cancelarReserva(int idReserva) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/reservas/$idReserva/cancelar'),
      headers: {
      'Content-Type': 'application/json',
      'X-Requested-With' : 'XMLHttpRequest'
    },
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> getReserva(int idReserva) async {
    final res = await http.get(Uri.parse('$baseUrl/reservas/$idReserva'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Reserva no encontrada');
  }

  // SOCIOS

  static Future<bool> isSocio(String dni) async {
    final res = await http.get(Uri.parse('$baseUrl/socios/$dni/is-socio'));
    final body = jsonDecode(res.body);
    return body['isSocio'];
  }

  static Future<Map<String, dynamic>> getSocio(String dni) async {
    final res = await http.get(Uri.parse('$baseUrl/socios/$dni'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Socio no encontrado');
  }

  static Future<Map<String, dynamic>> getReservasSocio(String dni) async {
    final res = await http.get(Uri.parse('$baseUrl/socios/$dni/reservas'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar reservas');
  }

  static Future<Map<String, dynamic>> actualizarSocio(
    String dni,
    Map<String, dynamic> datos,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/socios/$dni'),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode(datos),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> registrarSocio(
    Map<String, dynamic> datos,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/socios'),
      headers: {
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
      },
      body: jsonEncode(datos),
    );
    print('STATUS REGISTRO: ${res.statusCode}');
    print('BODY REGISTRO: ${res.body}');
    return jsonDecode(res.body);
  }

  // TARIFAS

  static Future<List<dynamic>> getTarifas({bool soloActivas = true}) async {
    final uri = Uri.parse(
      '$baseUrl/tarifas',
    ).replace(queryParameters: soloActivas ? {'activa': 'true'} : null);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'] as List<dynamic>;
    throw Exception(body['message'] ?? 'Error al cargar tarifas');
  }

  // RESEÑAS
  static Future<Map<String, dynamic>> getResenas(String idInstalacion) async {
    final res = await http.get(Uri.parse('$baseUrl/instalaciones/resenas'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar reseña');
  }

  static Future<Map<String, dynamic>> crearResena(
    String idInstalacion,
    Map<String, dynamic> datos,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/instalaciones/$idInstalacion/resenas'),
      headers: {
      'Content-Type': 'application/json',
      'X-Requested-With' : 'XMLHttpRequest'
    },
      body: jsonEncode(datos),
    );
    return jsonDecode(res.body);
  }

  // ADMIN - SOCIOS

  static Future<Map<String, dynamic>> getSocios({
    String? buscar,
    int porPagina = 15,
    int pagina = 1,
  }) async {
    final params = <String, String>{
      'por_pagina': porPagina.toString(),
      'page': pagina.toString(),
    };
    if (buscar != null && buscar.isNotEmpty) params['buscar'] = buscar;
    final uri = Uri.parse('$baseUrl/socios').replace(queryParameters: params);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar socios');
  }

  static Future<Map<String, dynamic>> eliminarSocio(String dni) async {
    final res = await http.delete(Uri.parse('$baseUrl/socios/$dni'));
    return jsonDecode(res.body);
  }

  // ADMIN - RESERVAS

  static Future<Map<String, dynamic>> getReservas({
    String? estado,
    String? fehcaDesde,
    String? fechaHasta,
    int porPagina = 15,
    int pagina = 1,
  }) async {
    final params = <String, String>{
      'por_pagina': porPagina.toString(),
      'page': pagina.toString(),
    };
    if (estado != null) params['estado'] = estado;
    if (fehcaDesde != null) params['fecha_desde'] = fehcaDesde;
    if (fechaHasta != null) params['fecha_hasta'] = fechaHasta;

    final uri = Uri.parse('$baseUrl/reservas').replace(queryParameters: params);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar reservas');
  }

  // ADMIN - INSTALACIONES

  static Future<Map<String, dynamic>> crearInstalacion(
    Map<String, dynamic> datos,
  ) async {
    final res = await http.post(
      Uri.parse('$baseUrl/instalaciones'),
      headers: {
      'Content-Type': 'application/json',
      'X-Requested-With' : 'XMLHttpRequest'
    },
      body: jsonEncode(datos),
    );
    return jsonDecode(res.body);
  }

  static Future<Map<String, dynamic>> actualizarInstalacion(
    String id,
    Map<String, dynamic> datos,
  ) async {
    final res = await http.put(
      Uri.parse('$baseUrl/instalaciones/$id'),
      headers: {
      'Content-Type': 'application/json',
      'X-Requested-With' : 'XMLHttpRequest'
    },
      body: jsonEncode(datos),
    );
    return jsonDecode(res.body);
  }

  // ADMIN - REPORTES

  static Future<Map<String, dynamic>> getReporteResumen() async {
    final res = await http.get(Uri.parse('$baseUrl/reportes/resumen'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar resumen');
  }

  static Future<Map<String, dynamic>> getReporteReservas({
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final params = <String, String>{};
    if (fechaDesde != null) params['fecha_desde'] = fechaDesde;
    if (fechaHasta != null) params['fecha_hasta'] = fechaHasta;

    final uri = Uri.parse(
      '$baseUrl/reportes/reservas',
    ).replace(queryParameters: params.isNotEmpty ? params : null);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar reporte');
  }

  static Future<Map<String, dynamic>> getReporteSocios() async {
    final res = await http.get(Uri.parse('$baseUrl/reportes/socios'));
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar reporte');
  }

  static Future<Map<String, dynamic>> getReporteInstalaciones({
    String? fechaDesde,
    String? fechaHasta,
  }) async {
    final params = <String, String>{};
    if (fechaDesde != null) params['fecha_desde'] = fechaDesde;
    if (fechaHasta != null) params['fecha_hasta'] = fechaHasta;

    final uri = Uri.parse(
      '$baseUrl/reportes/instalaciones',
    ).replace(queryParameters: params.isNotEmpty ? params : null);
    final res = await http.get(uri);
    final body = jsonDecode(res.body);
    if (body['success'] == true) return body['data'];
    throw Exception(body['message'] ?? 'Error al cargar reporte instalaciones');
  }
}
