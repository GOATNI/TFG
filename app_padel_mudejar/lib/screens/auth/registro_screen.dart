import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/logo_widget.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final result = await auth.registrar({
      'dni': _dniCtrl.text.trim().toUpperCase(),
      'nombre': _nombreCtrl.text.trim(),
      'apellidos': _apellidosCtrl.text.trim(),
      'correoElectronico': _emailCtrl.text.trim(),
      'telefono': _telefonoCtrl.text.trim(),
      'edad': int.tryParse(_edadCtrl.text.trim()) ?? 0,
    });

    if (!mounted) return;

    if (result['success'] == true) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Error al registrarse'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 40),

                const LogoWidget()
                    .animate()
                    .fadeIn(duration: 500.ms),

                const SizedBox(height: 24),

                Text(
                  'Registro',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 8),

                Text(
                  'Crea tu cuenta de socio',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 32),

                _buildField(
                  controller: _nombreCtrl,
                  hint: 'Nombre',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  delay: 300,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _apellidosCtrl,
                  hint: 'Apellidos',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  delay: 350,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _dniCtrl,
                  hint: 'DNI (ej: 12345678A)',
                  icon: Icons.badge_rounded,
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (v.length != 9) return 'El DNI debe tener 9 caracteres';
                    return null;
                  },
                  delay: 400,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _emailCtrl,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (!v.contains('@')) return 'Email inválido';
                    return null;
                  },
                  delay: 450,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _telefonoCtrl,
                  hint: 'Teléfono',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Campo requerido' : null,
                  delay: 500,
                ),
                const SizedBox(height: 12),
                _buildField(
                  controller: _edadCtrl,
                  hint: 'Edad',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo requerido';
                    if (int.tryParse(v) == null) return 'Introduce un número válido';
                    return null;
                  },
                  delay: 550,
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _registrar,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Registrarse'),
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya eres socio? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/login'),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 650.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    required int delay,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: AppTheme.primary, size: 20),
      ),
      validator: validator,
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: -0.15, end: 0);
  }
}