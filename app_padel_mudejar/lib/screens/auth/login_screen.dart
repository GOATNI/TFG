import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/logo_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _dniController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _verPassword = false;

  @override
  void dispose() {
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.login(
      _dniController.text.trim().toUpperCase(),
      _passwordController.text.trim(),
    );
    if (ok && mounted) context.go('/home');
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
                const SizedBox(height: 60),

                const LogoWidget()
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .slideY(begin: -0.3, end: 0),

                const SizedBox(height: 40),

                Text(
                  'Iniciar Sesión',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 8),

                Text(
                  'Accede con tu DNI y contraseña',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _dniController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    hintText: 'DNI (ej: 12345678A)',
                    prefixIcon: Icon(Icons.badge_rounded, color: AppTheme.primary),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Introduce tu DNI';
                    if (v.length != 9) return 'El DNI debe tener 9 caracteres';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),

                const SizedBox(height: 12),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_verPassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _verPassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                        color: AppTheme.textLight,
                      ),
                      onPressed: () => setState(() => _verPassword = !_verPassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Introduce tu contraseña';
                    return null;
                  },
                ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.2, end: 0),

                const SizedBox(height: 16),

                if (auth.error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.danger, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            auth.error!,
                            style: const TextStyle(color: AppTheme.danger, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().shake(),

                const SizedBox(height: 24),

                ElevatedButton(
                  onPressed: auth.isLoading ? null : _login,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No eres socio? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    GestureDetector(
                      onTap: () => context.go('/registro'),
                      child: const Text(
                        'Regístrate',
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}