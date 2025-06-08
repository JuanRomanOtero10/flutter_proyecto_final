import 'package:flutter/material.dart';
import 'package:flutter_proyecto_final/Entities/alarm.dart';
import 'package:go_router/go_router.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Alarma> alarmas = [
    Alarma(
      hora: const TimeOfDay(hour: 7, minute: 30),
      diasRepeticion: [1, 2, 3, 4, 5],
      vibracion: true,
      luz: false,
      activa: true,
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Agregar alarma',
            onPressed: () {
              context.push('/editar');
            },
          ),
        ],
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.push('/test_bluetooth'),
          child: const Text("Probar Bluetooth"),
        ),
      ),
    );
  }
}