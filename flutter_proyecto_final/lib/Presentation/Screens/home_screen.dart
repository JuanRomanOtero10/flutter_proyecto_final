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
          Consumer(
            builder: (context, ref, _) {
              final bluetoothService = ref.watch(bluetoothServiceProvider);
              final color = bluetoothService.isConnected ? Colors.green : Colors.red;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 1.5),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ref.read(alarmaSeleccionadaProvider.notifier).state = null;
              ref.read(indexSeleccionadoProvider.notifier).state = null;
              ref.read(patronVibracionProvider.notifier).state = "Media";
              ref.read(patronLuzProvider.notifier).state = "Constante";
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
              isThreeLine: true,
              minLeadingWidth: 105,  // o más si querés
              leading: SizedBox(
                width: 105,
                child: Center(
                  child: Text(
                    alarma.hora.format(context),
                    style: TextStyle(fontSize: 40),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              subtitle: Text(
                '${alarma.activa ? 'Activa' : 'Desactivada'}\n'
                'Luz: ${alarma.luz ? (alarma.patronLuz ?? 'Ninguna') : 'Desactivada'}\n'
                'Vibración: ${alarma.vibracion ? (alarma.patronVibracion ?? 'Ninguna') : 'Desactivada'}',
                style: const TextStyle(fontSize: 14),
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
                ref.read(alarmaSeleccionadaProvider.notifier).state = alarma;
                ref.read(indexSeleccionadoProvider.notifier).state = index;
                ref.read(patronVibracionProvider.notifier).state = alarma.patronVibracion ?? "Media";
                ref.read(patronLuzProvider.notifier).state = alarma.patronLuz ?? "Constante";
                context.push('/editar');
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
            minimumSize: const Size.fromHeight(50), 
          ),
        ),
      ),
    );
  }
}