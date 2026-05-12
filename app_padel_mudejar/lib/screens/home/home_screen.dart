import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Header saludo
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, ${auth.nombre} 👋',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ).animate().fadeIn().slideX(begin: -0.2, end: 0),
                        const SizedBox(height: 4),
                        Text(
                          'Club de Pádel Mudéjar',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ).animate().fadeIn(delay: 100.ms),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppTheme.primary.withOpacity(0.15),
                    child: Text(
                      auth.nombre.isNotEmpty
                          ? auth.nombre[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(
                      begin: const Offset(0.8, 0.8)),
                ],
              ),

              const SizedBox(height: 24),

              // Banner
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF27AE60), Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 16,
                      bottom: 0,
                      child: Icon(
                        Icons.sports_tennis_rounded,
                        size: 120,
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            '¡A jugar!',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Reserva tu pista ahora',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.go('/reservar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.primary,
                              minimumSize: const Size(120, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Reservar',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              Text(
                'Acceso rápido',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 16),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 14),

              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _QuickCard(
                    icon: Icons.calendar_month_rounded,
                    label: 'Reservar\npista',
                    color: AppTheme.primary,
                    onTap: () => context.go('/reservar'),
                    delay: 500,
                  ),
                  _QuickCard(
                    icon: Icons.list_alt_rounded,
                    label: 'Ver mis\nreservas',
                    color: AppTheme.secondary,
                    onTap: () => context.go('/mis-reservas'),
                    delay: 550,
                  ),
                  _QuickCard(
                    icon: Icons.schedule_rounded,
                    label: 'Consultar\ndisponibilidad',
                    color: const Color(0xFF9B59B6),
                    onTap: () => context.go('/horarios'),
                    delay: 600,
                  ),
                  _QuickCard(
                    icon: Icons.person_rounded,
                    label: 'Mi\nperfil',
                    color: AppTheme.accent,
                    onTap: () => context.go('/perfil'),
                    delay: 650,
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int delay;

  const _QuickCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color.withOpacity(0.9),
                height: 1.3,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1),
          ),
    );
  }
}