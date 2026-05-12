import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _socio;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get socio => _socio;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _socio != null;

  String get dni => _socio?['dniUsuario'] ?? '';
  String get nombre => _socio?['usuario']?['nombre'] ?? '';
  String get apellidos => _socio?['usuario']?['apellidos'] ?? '';
  String get nombreCompleto => '$nombre $apellidos'.trim();
  String get email => _socio?['correoElectronico'] ?? '';
  String get telefono => _socio?['usuario']?['telefono'] ?? '';
  String get idCarnet => _socio?['idCarnet']?.toString() ?? '';

  /// Carga sesión guardada al abrir la app
  Future<void> cargarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    final dniGuardado = prefs.getString('dni_sesion');
    if (dniGuardado != null) {
      try {
        _socio = await ApiService.getSocio(dniGuardado);
        notifyListeners();
      } catch (_) {
        await prefs.remove('dni_sesion');
      }
    }
  }

  /// Login por DNI
  Future<bool> login(String dni) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final esSocio = await ApiService.isSocio(dni);
      if (!esSocio) {
        _error = 'El DNI no está registrado como socio.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _socio = await ApiService.getSocio(dni);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dni_sesion', dni);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Error al iniciar sesión. Comprueba tu conexión.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registro de nuevo socio
  Future<Map<String, dynamic>> registrar(Map<String, dynamic> datos) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await ApiService.registrarSocio(datos);
      if (result['success'] == true) {
        _socio = result['data'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('dni_sesion', datos['dniUsuario']);
      }
      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      print('ERROR REGISTRO: $e');
      _error = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Error : $e' };
    }
  }

  /// Actualizar datos del perfil
  Future<bool> actualizarPerfil(Map<String, dynamic> datos) async {
    try {
      final result = await ApiService.actualizarSocio(dni, datos);
      if (result['success'] == true) {
        _socio = await ApiService.getSocio(dni);
        notifyListeners();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Cerrar sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('dni_sesion');
    _socio = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}