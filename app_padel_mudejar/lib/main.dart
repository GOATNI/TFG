import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const PadelMudejarApp());
}

class PadelMudejarApp extends StatelessWidget {
  const PadelMudejarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..cargarSesion(),
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          final router = createRouter(auth);
          return MaterialApp.router(
            title: 'Club de Pádel Mudéjar',
            theme: AppTheme.theme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            locale: const Locale('es', 'ES'),
          );
        },
      ),
    );
  }
}