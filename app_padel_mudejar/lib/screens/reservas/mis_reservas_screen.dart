import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
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

  void _mostrarEditarReserva(dynamic reserva) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (ctx) => _EditarReservaBottomSheet(
        reserva: reserva,
        dniSocio: auth.dni,
        onActualizada: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reserva actualizada'),
              backgroundColor: AppTheme.primary,
            ),
          );
          _cargar();
        },
      ),
    );
  }

  void _mostrarBottomSheetResena(dynamic reserva) {
    final auth = context.read<AuthProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ResenaBottomSheet(
        idInstalacion: reserva['idInstalacion'] ?? '',
        nombreInstalacion: reserva['instalacion'] ?? '',
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
                mostrarEditar: futuras && r['estado'] == 'CONFIRMADA',
                mostrarResena: !futuras && r['estado'] == 'CONFIRMADA',
                onCancelar: () => _cancelar(r['idReserva']),
                onEditar: () => _mostrarEditarReserva(r),
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
  final bool mostrarEditar;
  final bool mostrarResena;
  final VoidCallback onCancelar;
  final VoidCallback onEditar;
  final VoidCallback onResena;

  const _ReservaCard({
    required this.reserva,
    required this.mostrarCancelar,
    required this.mostrarEditar,
    required this.mostrarResena,
    required this.onCancelar,
    required this.onEditar,
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
          if (mostrarEditar || mostrarCancelar) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (mostrarEditar)
                  Expanded(
                    child: GestureDetector(
                      onTap: onEditar,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.edit_rounded,
                            color: AppTheme.secondary,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Editar',
                            style: TextStyle(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (mostrarEditar && mostrarCancelar)
                  Container(width: 1, height: 20, color: Colors.grey.shade200),
                if (mostrarCancelar)
                  Expanded(
                    child: GestureDetector(
                      onTap: onCancelar,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.cancel_outlined,
                            color: AppTheme.danger,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Cancelar',
                            style: TextStyle(
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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

class _EditarReservaBottomSheet extends StatefulWidget {
  final dynamic reserva;
  final String dniSocio;
  final VoidCallback onActualizada;

  const _EditarReservaBottomSheet({
    required this.reserva,
    required this.dniSocio,
    required this.onActualizada,
  });

  @override
  State<_EditarReservaBottomSheet> createState() =>
      _EditarReservaBottomSheetState();
}

class _EditarReservaBottomSheetState extends State<_EditarReservaBottomSheet> {
  List<dynamic> _instalaciones = [];
  List<dynamic> _tarifas = [];
  Map<String, dynamic>? _instalacionSeleccionada;
  Map<String, dynamic>? _tarifaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now().add(const Duration(days: 1));
  String? _horaSeleccionada;
  List<Map<String, dynamic>> _horas = [];
  bool _loading = true;
  bool _loadingHoras = false;
  bool _guardando = false;
  int _paso = 0;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    try {
      final inst = await ApiService.getInstalaciones(estado: 'ACTIVA');
      final tar = await ApiService.getTarifas();
      setState(() {
        _instalaciones = inst;
        _tarifas = tar;
        // Preseleccionar instalación actual
        _instalacionSeleccionada = inst.firstWhere(
          (i) => i['idInstalacion'] == widget.reserva['idInstalacion'],
          orElse: () => inst.isNotEmpty ? inst[0] : null,
        );
        // Preseleccionar tarifa actual
        _tarifaSeleccionada = tar.firstWhere(
          (t) => t['nombre'] == widget.reserva['tarifa'],
          orElse: () => tar.isNotEmpty ? tar[0] : null,
        );
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _cargarHoras() async {
    if (_instalacionSeleccionada == null || _tarifaSeleccionada == null) return;
    setState(() {
      _loadingHoras = true;
      _horaSeleccionada = null;
      _horas = [];
    });
    try {
      final fecha = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
      final result = await ApiService.getHorasDisponibles(
        fecha: fecha,
        instalacion: _instalacionSeleccionada!['idInstalacion'],
        duracion: _tarifaSeleccionada!['duracionMinutos'],
      );
      setState(() {
        _horas = (result['horas'] as List<dynamic>? ?? [])
            .cast<Map<String, dynamic>>();
        _loadingHoras = false;
      });
    } catch (_) {
      setState(() => _loadingHoras = false);
    }
  }

  Future<void> _guardar() async {
    if (_instalacionSeleccionada == null ||
        _tarifaSeleccionada == null ||
        _horaSeleccionada == null)
      return;
    setState(() => _guardando = true);

    final fecha = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
    final fechaHora = '$fecha $_horaSeleccionada:00';

    try {
      final result =
          await ApiService.reagendarReserva(widget.reserva['idReserva'], {
            'dniSocio': widget.dniSocio,
            'instalacion': _instalacionSeleccionada!['idInstalacion'],
            'idTarifa': _tarifaSeleccionada!['idTarifa'],
            'fechaHora': fechaHora,
          });
      if (mounted) {
        Navigator.pop(context);
        if (result['success'] == true) {
          widget.onActualizada();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Error al actualizar'),
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
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Header con pasos
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                if (_paso > 0)
                  GestureDetector(
                    onTap: () => setState(() => _paso--),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      size: 18,
                      color: AppTheme.textDark,
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  _paso == 0
                      ? 'Editar reserva — Pista'
                      : _paso == 1
                      ? 'Editar reserva — Fecha'
                      : 'Confirmar cambios',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _paso == 0
                        ? _buildPaso0()
                        : _paso == 1
                        ? _buildPaso1()
                        : _buildPaso2(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaso0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Elige una pista',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ..._instalaciones.map(
          (inst) => GestureDetector(
            onTap: () => setState(() => _instalacionSeleccionada = inst),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color:
                    _instalacionSeleccionada?['idInstalacion'] ==
                        inst['idInstalacion']
                    ? AppTheme.primary.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color:
                      _instalacionSeleccionada?['idInstalacion'] ==
                          inst['idInstalacion']
                      ? AppTheme.primary
                      : Colors.grey.shade200,
                  width:
                      _instalacionSeleccionada?['idInstalacion'] ==
                          inst['idInstalacion']
                      ? 2
                      : 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sports_tennis_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      inst['nombre'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (_instalacionSeleccionada?['idInstalacion'] ==
                      inst['idInstalacion'])
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primary,
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Elige la duración',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        ..._tarifas.map(
          (tar) => GestureDetector(
            onTap: () => setState(() => _tarifaSeleccionada = tar),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _tarifaSeleccionada?['idTarifa'] == tar['idTarifa']
                    ? AppTheme.primary.withOpacity(0.08)
                    : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _tarifaSeleccionada?['idTarifa'] == tar['idTarifa']
                      ? AppTheme.primary
                      : Colors.grey.shade200,
                  width: _tarifaSeleccionada?['idTarifa'] == tar['idTarifa']
                      ? 2
                      : 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '${tar['nombre']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Text(
                    '€${tar['precio']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  if (_tarifaSeleccionada?['idTarifa'] == tar['idTarifa']) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed:
              (_instalacionSeleccionada != null && _tarifaSeleccionada != null)
              ? () {
                  setState(() => _paso = 1);
                  _cargarHoras();
                }
              : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildPaso1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Selecciona la fecha',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: TableCalendar(
            firstDay: DateTime.now().add(const Duration(days: 1)),
            lastDay: DateTime.now().add(const Duration(days: 60)),
            focusedDay: _fechaSeleccionada,
            selectedDayPredicate: (day) => isSameDay(day, _fechaSeleccionada),
            onDaySelected: (selected, focused) {
              setState(() => _fechaSeleccionada = selected);
              _cargarHoras();
            },
            calendarStyle: CalendarStyle(
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
            locale: 'es_ES',
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Elige una hora',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingHoras)
          const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          )
        else if (_horas.isEmpty)
          const Center(
            child: Text(
              'No hay horas disponibles',
              style: TextStyle(color: AppTheme.textMedium),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _horas.map((h) {
              final hora = h['hora'] as String;
              final disponible = h['disponible'] as bool;
              final selected = _horaSeleccionada == hora;
              return GestureDetector(
                onTap: disponible
                    ? () => setState(() => _horaSeleccionada = hora)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: !disponible
                        ? Colors.grey.shade100
                        : selected
                        ? AppTheme.primary
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: selected ? AppTheme.primary : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    hora,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: !disponible
                          ? AppTheme.textLight
                          : selected
                          ? Colors.white
                          : AppTheme.textDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _horaSeleccionada != null
              ? () => setState(() => _paso = 2)
              : null,
          child: const Text('Continuar'),
        ),
      ],
    );
  }

  Widget _buildPaso2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Confirma los cambios',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _resumenRow(
                Icons.sports_tennis_rounded,
                'Pista',
                _instalacionSeleccionada?['nombre'] ?? '',
              ),
              const Divider(height: 24),
              _resumenRow(
                Icons.timer_rounded,
                'Duración',
                '${_tarifaSeleccionada?['duracionMinutos']} min',
              ),
              const Divider(height: 24),
              _resumenRow(
                Icons.calendar_today_rounded,
                'Fecha',
                DateFormat('EEEE d MMMM', 'es').format(_fechaSeleccionada),
              ),
              const Divider(height: 24),
              _resumenRow(
                Icons.access_time_rounded,
                'Hora',
                _horaSeleccionada ?? '',
              ),
              const Divider(height: 24),
              _resumenRow(
                Icons.euro_rounded,
                'Precio',
                '€${_tarifaSeleccionada?['precio']}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          child: _guardando
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Text('Confirmar cambios'),
        ),
      ],
    );
  }

  Widget _resumenRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textMedium, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
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
