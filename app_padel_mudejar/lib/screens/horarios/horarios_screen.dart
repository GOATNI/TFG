import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../core/api_service.dart';
import '../../core/theme.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  List<dynamic> _instalaciones = [];
  Map<String, Map<String, dynamic>> _resenasPorPista = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final inst = await ApiService.getInstalaciones();
      final Map<String, Map<String, dynamic>> resenas = {};
      for (final i in inst) {
        try {
          final r = await ApiService.getResenas(i['idInstalacion']);
          print(
            'ESTADOS: ${inst.map((i) => "${i['nombre']}: ${i['estadoPista']}").toList()}',
          );
          resenas[i['idInstalacion']] = r;
        } catch (_) {}
      }
      setState(() {
        _instalaciones = inst;
        _resenasPorPista = resenas;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  void _mostrarResenas(
    BuildContext context,
    dynamic instalacion,
    Map<String, dynamic>? resenas,
  ) {
    if (resenas == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResenasPistaBottomSheet(
        nombreInstalacion: instalacion['nombre'] ?? '',
        resenas: resenas,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Pistas')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : RefreshIndicator(
              onRefresh: _cargar,
              color: AppTheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _instalaciones.length,
                itemBuilder: (context, i) {
                  final inst = _instalaciones[i];
                  final resenas = _resenasPorPista[inst['idInstalacion']];
                  return _PistaCard(
                        instalacion: inst,
                        resenas: resenas,
                        onTap: () =>
                            context.push('/horarios/detalle', extra: inst),
                        onResenasTap: () =>
                            _mostrarResenas(context, inst, resenas),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: i * 80))
                      .slideY(begin: 0.1, end: 0);
                },
              ),
            ),
    );
  }
}

class _PistaCard extends StatelessWidget {
  final dynamic instalacion;
  final Map<String, dynamic>? resenas;
  final VoidCallback onTap;
  final VoidCallback onResenasTap;

  const _PistaCard({
    required this.instalacion,
    required this.resenas,
    required this.onTap,
    required this.onResenasTap,
  });

  @override
  Widget build(BuildContext context) {
    final estado = instalacion['estadoPista'] as String? ?? '';
    final activa = estado == 'ACTIVA';
    final imagenUrl = instalacion['imagen_url'] as String?;
    final promedio = resenas?['promedio'] as double?;
    final total = resenas?['total'] as int? ?? 0;

    return GestureDetector(
      onTap: activa ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Stack(
                children: [
                  imagenUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imagenUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 160,
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 160,
                            color: Colors.grey.shade100,
                            child: const Icon(
                              Icons.sports_tennis_rounded,
                              size: 60,
                              color: AppTheme.textLight,
                            ),
                          ),
                        )
                      : Container(
                          height: 160,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Icon(
                              Icons.sports_tennis_rounded,
                              size: 60,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: activa ? AppTheme.primary : AppTheme.danger,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            activa ? 'Disponible' : 'Mantenimiento',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!activa)
                    Container(
                      height: 160,
                      color: Colors.black.withOpacity(0.4),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instalacion['nombre'] ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          instalacion['tipo'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textMedium,
                          ),
                        ),
                        if (instalacion['ubicacion'] != null) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: AppTheme.textLight,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                instalacion['ubicacion'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textLight,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (promedio != null) ...[
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: onResenasTap,
                            child: Row(
                              children: [
                                ...List.generate(5, (i) {
                                  return Icon(
                                    i < promedio.floor()
                                        ? Icons.star_rounded
                                        : (i < promedio && promedio % 1 >= 0.5)
                                        ? Icons.star_half_rounded
                                        : Icons.star_outline_rounded,
                                    color: AppTheme.accent,
                                    size: 16,
                                  );
                                }),
                                const SizedBox(width: 6),
                                Text(
                                  '$promedio ($total reseñas)',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textMedium,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  size: 14,
                                  color: AppTheme.textLight,
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Sin reseñas aún',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (activa)
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppTheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResenasPistaBottomSheet extends StatelessWidget {
  final String nombreInstalacion;
  final Map<String, dynamic> resenas;

  const _ResenasPistaBottomSheet({
    required this.nombreInstalacion,
    required this.resenas,
  });

  @override
  Widget build(BuildContext context) {
    final lista = (resenas['resenas'] as List<dynamic>? ?? []);
    final promedio = resenas['promedio'] as double?;
    final total = resenas['total'] as int? ?? 0;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Título y promedio
          Text(
            'Reseñas — $nombreInstalacion',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          if (promedio != null)
            Row(
              children: [
                Text(
                  '$promedio',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < promedio.floor()
                              ? Icons.star_rounded
                              : (i < promedio && promedio % 1 >= 0.5)
                              ? Icons.star_half_rounded
                              : Icons.star_outline_rounded,
                          color: AppTheme.accent,
                          size: 20,
                        );
                      }),
                    ),
                    Text(
                      '$total reseñas',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          const Divider(height: 24),

          // Lista de reseñas
          Expanded(
            child: ListView.builder(
              itemCount: lista.length,
              itemBuilder: (context, i) {
                final r = lista[i];
                final puntuacion = r['puntuacion'] as int? ?? 0;
                final comentario = r['comentario'] as String?;
                final autor = r['nombreAutor'] as String? ?? 'Anónimo';
                final fecha = r['created_at'] as String? ?? '';
                final fechaCorta = fecha.isNotEmpty
                    ? fecha.substring(0, 10)
                    : '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppTheme.primary.withOpacity(0.1),
                        child: Text(
                          autor.isNotEmpty ? autor[0].toUpperCase() : 'A',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  autor,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                Text(
                                  fechaCorta,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textLight,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: List.generate(5, (j) {
                                return Icon(
                                  j < puntuacion
                                      ? Icons.star_rounded
                                      : Icons.star_outline_rounded,
                                  color: AppTheme.accent,
                                  size: 14,
                                );
                              }),
                            ),
                            if (comentario != null &&
                                comentario.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                comentario,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
