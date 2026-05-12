import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../core/api_service.dart';
import '../../core/theme.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  List<dynamic> _instalaciones = [];
  DateTime _fechaSeleccionada = DateTime.now();
  Map<String, List<Map<String, dynamic>>> _horasPorPista = {};
  bool _loading = true;
  bool _loadingHoras = false;

  @override
  void initState() {
    super.initState();
    _cargarInstalaciones();
  }

  Future<void> _cargarInstalaciones() async {
    try {
      final inst = await ApiService.getInstalaciones(estado: 'ACTIVA');
      setState(() {
        _instalaciones = inst;
        _loading = false;
      });
      _cargarHorasTodas();
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cargarHorasTodas() async {
    setState(() => _loadingHoras = true);
    final fecha = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
    final Map<String, List<Map<String, dynamic>>> resultado = {};

    for (final inst in _instalaciones) {
      try {
        final res = await ApiService.getHorasDisponibles(
          fecha: fecha,
          instalacion: inst['idInstalacion'],
          duracion: 60,
        );
        resultado[inst['idInstalacion']] =
            (res['horas'] as List<dynamic>? ?? [])
                .cast<Map<String, dynamic>>();
      } catch (_) {
        resultado[inst['idInstalacion']] = [];
      }
    }

    setState(() {
      _horasPorPista = resultado;
      _loadingHoras = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Horarios')),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                _buildSelectorFecha(),
                Expanded(
                  child: _loadingHoras
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppTheme.primary))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _instalaciones.length,
                          itemBuilder: (context, i) {
                            final inst = _instalaciones[i];
                            final horas =
                                _horasPorPista[inst['idInstalacion']] ?? [];
                            return _PistaHorariosCard(
                              instalacion: inst,
                              horas: horas,
                            ).animate().fadeIn(
                                delay: Duration(milliseconds: i * 100));
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildSelectorFecha() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SizedBox(
        height: 70,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 14,
          itemBuilder: (context, i) {
            final dia = DateTime.now().add(Duration(days: i));
            final selected = _isSameDay(dia, _fechaSeleccionada);
            return GestureDetector(
              onTap: () {
                setState(() => _fechaSeleccionada = dia);
                _cargarHorasTodas();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primary
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('EEE', 'es')
                          .format(dia)
                          .toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white70
                            : AppTheme.textMedium,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${dia.day}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: selected
                            ? Colors.white
                            : AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _PistaHorariosCard extends StatelessWidget {
  final dynamic instalacion;
  final List<Map<String, dynamic>> horas;

  const _PistaHorariosCard({
    required this.instalacion,
    required this.horas,
  });

  @override
  Widget build(BuildContext context) {
    final disponibles = horas.where((h) => h['disponible'] == true).length;
    final total = horas.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.sports_tennis_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  instalacion['nombre'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Text(
                '$disponibles/$total libres',
                style: TextStyle(
                  fontSize: 12,
                  color: disponibles > 0
                      ? AppTheme.primary
                      : AppTheme.danger,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (horas.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: horas.map((h) {
                final disponible = h['disponible'] as bool;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: disponible
                        ? AppTheme.primary.withOpacity(0.1)
                        : AppTheme.danger.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    h['hora'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: disponible
                          ? AppTheme.primary
                          : AppTheme.danger,
                    ),
                  ),
                );
              }).toList(),
            ),
          ] else
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Sin datos para este día',
                style:
                    TextStyle(color: AppTheme.textLight, fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }
}