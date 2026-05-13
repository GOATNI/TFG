import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/api_service.dart';
import '../../core/theme.dart';
import '../../providers/auth_provider.dart';

class MisReservasScreen extends StatefulWidget {
  const MisReservasScreen({super.key});

  @override
  State<MisReservasScreen> createState() => _MisReservasScreenState();
}

class _MisReservasScreenState extends State<MisReservasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _datos;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargar();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    final auth = context.read<AuthProvider>();
    try {
      final datos = await ApiService.getReservasSocio(auth.dni);
      if (datos['pasadas'] != null && (datos['pasadas'] as List).isNotEmpty) {
        print('RESERVA PASADA: ${datos['pasadas'][0]}');
      }
      setState(() {
        _datos = datos;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancelar(int idReserva) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar reserva'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar esta reserva?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Sí, cancelar',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final result = await ApiService.cancelarReserva(idReserva);
    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva cancelada'),
            backgroundColor: AppTheme.primary,
          ),
        );
        _cargar();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['mensaje'] ?? 'Error al cancelar'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  void _mostrarBottomSheetResena(dynamic reserva) {
    final auth = context.read<AuthProvider>();
    final idInstalacion = reserva['idInstalacion'] ?? '';
    final nombreInstalacion = reserva['instalacion'] ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResenaBottomSheet(
        idInstalacion: idInstalacion,
        nombreInstalacion: nombreInstalacion,
        nombreAutor: auth.nombreCompleto,
        dniSocio: auth.dni,
        onEnviada: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('¡Reseña enviada! Gracias por tu opinión'),
              backgroundColor: AppTheme.primary,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textMedium,
          indicatorColor: AppTheme.primary,
          tabs: [
            Tab(text: 'Próximas (${_datos?['totalFuturas'] ?? 0})'),
            Tab(text: 'Historial (${_datos?['totalPasadas'] ?? 0})'),
          ],
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLista(
                  (_datos?['futuras'] as List<dynamic>? ?? []),
                  futuras: true,
                ),
                _buildLista(
                  (_datos?['pasadas'] as List<dynamic>? ?? []),
                  futuras: false,
                ),
              ],
            ),
    );
  }

  Widget _buildLista(List<dynamic> reservas, {required bool futuras}) {
    if (reservas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              futuras ? Icons.calendar_today_rounded : Icons.history_rounded,
              size: 60,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: 16),
            Text(
              futuras ? 'No tienes reservas próximas' : 'No tienes historial',
              style: const TextStyle(color: AppTheme.textMedium, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reservas.length,
        itemBuilder: (context, i) {
          final r = reservas[i];
          return _ReservaCard(
                reserva: r,
                mostrarCancelar: futuras && r['estado'] == 'CONFIRMADA',
                mostrarResena: !futuras && r['estado'] == 'CONFIRMADA',
                onCancelar: () => _cancelar(r['idReserva']),
                onResena: () => _mostrarBottomSheetResena(r),
              )
              .animate()
              .fadeIn(delay: Duration(milliseconds: i * 80))
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  final dynamic reserva;
  final bool mostrarCancelar;
  final bool mostrarResena;
  final VoidCallback onCancelar;
  final VoidCallback onResena;

  const _ReservaCard({
    required this.reserva,
    required this.mostrarCancelar,
    required this.mostrarResena,
    required this.onCancelar,
    required this.onResena,
  });

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'CONFIRMADA':
        return AppTheme.primary;
      case 'CANCELADA':
        return AppTheme.danger;
      default:
        return AppTheme.textMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = reserva['estado'] as String? ?? '';
    final fechaStr = reserva['fechaHora'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
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
                child: const Icon(
                  Icons.sports_tennis_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  reserva['instalacion'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _estadoColor(estado).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  estado,
                  style: TextStyle(
                    color: _estadoColor(estado),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _infoChip(Icons.calendar_today_rounded, fechaStr),
              const SizedBox(width: 12),
              _infoChip(Icons.timer_rounded, reserva['tarifa'] ?? ''),
            ],
          ),
          const SizedBox(height: 8),
          _infoChip(Icons.euro_rounded, '€${reserva['precio'] ?? '0'}'),
          if (mostrarCancelar) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onCancelar,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel_outlined, color: AppTheme.danger, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Cancelar reserva',
                    style: TextStyle(
                      color: AppTheme.danger,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (mostrarResena) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: onResena,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppTheme.accent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Dejar reseña',
                    style: TextStyle(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textMedium),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: AppTheme.textMedium, fontSize: 13),
        ),
      ],
    );
  }
}

class _ResenaBottomSheet extends StatefulWidget {
  final String idInstalacion;
  final String nombreInstalacion;
  final String nombreAutor;
  final String dniSocio;
  final VoidCallback onEnviada;

  const _ResenaBottomSheet({
    required this.idInstalacion,
    required this.nombreInstalacion,
    required this.nombreAutor,
    required this.dniSocio,
    required this.onEnviada,
  });

  @override
  State<_ResenaBottomSheet> createState() => _ResenaBottomSheetState();
}

class _ResenaBottomSheetState extends State<_ResenaBottomSheet> {
  int _puntuacion = 5;
  final _comentarioCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _comentarioCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    setState(() => _enviando = true);
    try {
      final result = await ApiService.crearResena(widget.idInstalacion, {
        'nombreAutor': widget.nombreAutor,
        'puntuacion': _puntuacion,
        'comentario': _comentarioCtrl.text.trim(),
        'dniSocio': widget.dniSocio,
      });
      if (mounted) {
        Navigator.pop(context);
        if (result['success'] == true) {
          widget.onEnviada();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al enviar reseña'),
              backgroundColor: AppTheme.danger,
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error de conexión'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          const Text(
            '¿Cómo fue tu partida?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.nombreInstalacion,
            style: const TextStyle(color: AppTheme.textMedium, fontSize: 14),
          ),
          const SizedBox(height: 24),
          const Text(
            'Puntuación',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(5, (i) {
              final estrella = i + 1;
              return GestureDetector(
                onTap: () => setState(() => _puntuacion = estrella),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    estrella <= _puntuacion
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: AppTheme.accent,
                    size: 36,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          const Text(
            'Comentario (opcional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _comentarioCtrl,
            maxLines: 3,
            maxLength: 500,
            decoration: InputDecoration(
              hintText: 'Cuéntanos tu experiencia...',
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primary, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _enviando ? null : _enviar,
            child: _enviando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Text('Enviar reseña'),
          ),
        ],
      ),
    );
  }
}
