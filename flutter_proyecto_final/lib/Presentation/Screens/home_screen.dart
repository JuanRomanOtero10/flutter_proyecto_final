import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Presentation/providers.dart';



class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final alarmas = ref.watch(alarmasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarmas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/editar');
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: alarmas.length,
        itemBuilder: (context, index) {
          final alarma = alarmas[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(alarma.hora.format(context)),
              subtitle: Text(
                alarma.activa ? 'Activa/n' : 'Desactivada /n'
                'Luz: ${alarma.patronLuz ?? 'Ninguna'}\n'
                'Vibración: ${alarma.patronVibracion ?? 'Ninguna'}',
                style: TextStyle(fontSize: 14),
                ),
              trailing: Switch(
                value: alarma.activa,
                onChanged: (val) {
                  final nuevasAlarmas = [...alarmas];
                  nuevasAlarmas[index] = alarma.copyWith(activa: val);
                  ref.read(alarmasProvider.notifier).state = nuevasAlarmas;
                },
              ),
              onTap: () {
                context.push('/editar', extra: {'index': index, 'alarma': alarma});
              },
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ElevatedButton.icon(
          icon: const Icon(Icons.bluetooth),
          label: const Text('Conectar Bluetooth'),
          onPressed: () {
            context.push('/bluetooth');
          },
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50), // botón alto y ancho completo
          ),
        ),
      ),
    );
  }
}