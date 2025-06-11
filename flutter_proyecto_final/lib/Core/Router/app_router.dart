import 'package:go_router/go_router.dart';
import 'package:flutter_proyecto_final/Presentation/Screens/patron_vibracion.dart';
import 'package:flutter_proyecto_final/Presentation/Screens/stop_alarma.dart';
import 'package:flutter_proyecto_final/Presentation/Screens/patron_luz.dart';
import 'package:flutter_proyecto_final/Presentation/Screens/home_screen.dart';
import 'package:flutter_proyecto_final/Presentation/Screens/editar_alarma.dart';
import 'package:flutter_proyecto_final/Presentation/Screens/bluetooth.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(),
    ),
    GoRoute(
      path: '/editar',
      builder: (context, state) => EditarAlarma(),
    ),
    GoRoute(
      path: '/luz',
      builder: (context, state) => PatronLuz(),
    ),
    GoRoute(
      path: '/vibracion',
      builder: (context, state) => PatronVibracion(),
    ),
    GoRoute(
      path: '/stop',
      builder: (context, state) => StopAlarma(),
    ),
    GoRoute(
      path: '/bluetooth',
      builder: (context, state) => const BluetoothScreen(),
    )
  ]
);
