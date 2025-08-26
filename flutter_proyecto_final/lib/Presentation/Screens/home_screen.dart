import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Presentation/providers.dart';
import 'dart:convert';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final alarmas = ref.watch(alarmasProvider);
    final seleccionadas = ref.watch(alarmaParaBorrarProvider);

    bool isSelected(alarma) =>
        seleccionadas.any((a) => a.id == alarma.id); // Compara por id

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
                    border: Border.all(color: const Color.fromARGB(255, 95, 95, 95), width: 1.5),
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
              ref.read(alarmaParaBorrarProvider.notifier).state = [];
              context.push('/editar');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: alarmas.length,
          itemBuilder: (context, index) {
            final alarma = alarmas[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                isThreeLine: true,
                minLeadingWidth: 105,
                leading: seleccionadas.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey),
                                color: isSelected(alarma)
                                    ? Colors.green
                                    : Colors.transparent,
                              ),
                              child: isSelected(alarma)
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                          ),
                          SizedBox(
                            width: 105,
                            child: Center(
                              child: Text(
                                alarma.hora.format(context),
                                style: const TextStyle(fontSize: 32),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      )
                    : SizedBox(
                        width: 105,
                        child: Center(
                          child: Text(
                            alarma.hora.format(context),
                            style: const TextStyle(fontSize: 40),
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
                trailing: seleccionadas.isEmpty
                    ? Switch(
                        value: alarma.activa,
                        onChanged: (val) async {
                          final bluetoothService = ref.read(bluetoothServiceProvider);

                          if (!bluetoothService.isConnected) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Conectate a tu Deep Sleep para Activar/Desactivar'),
                                backgroundColor: Colors.deepPurpleAccent,
                                duration: Duration(seconds: 1),
                              ),
                            );
                            return;
                          }

                          final notifier = ref.read(alarmasProvider.notifier);
                          final nuevaAlarma = alarma.copyWith(activa: val);
                          await notifier.updateAlarma(nuevaAlarma);

                          if (bluetoothService.isConnected) {
                            final data = {
                              "hora": nuevaAlarma.hora.format(context),
                              "luz": nuevaAlarma.luz
                                  ? (nuevaAlarma.patronLuz ?? 'Ninguna')
                                  : 'Desactivada',
                              "vibracion": nuevaAlarma.vibracion
                                  ? (nuevaAlarma.patronVibracion ?? 'Ninguna')
                                  : 'Desactivada',
                              "activa": nuevaAlarma.activa,
                            };
                            final json = jsonEncode(data);
                            bluetoothService.sendData("$json\n");
                          }
                        },
                      )
                    : null,
                onTap: () {
                  final seleccionadas = ref.read(alarmaParaBorrarProvider);
                  if (seleccionadas.isNotEmpty) {
                    final yaSeleccionada =
                        seleccionadas.any((a) => a.id == alarma.id);
                    if (yaSeleccionada) {
                      ref.read(alarmaParaBorrarProvider.notifier).state =
                          List.from(seleccionadas)
                            ..removeWhere((a) => a.id == alarma.id);
                    } else {
                      ref.read(alarmaParaBorrarProvider.notifier).state =
                          List.from(seleccionadas)..add(alarma);
                    }
                  } else {
                    ref.read(alarmaSeleccionadaProvider.notifier).state = alarma;
                    ref.read(indexSeleccionadoProvider.notifier).state = index;
                    ref.read(patronVibracionProvider.notifier).state =
                        alarma.patronVibracion ?? "Media";
                    ref.read(patronLuzProvider.notifier).state =
                        alarma.patronLuz ?? "Constante";
                    context.push('/editar');
                  }
                },
                onLongPress: () {
                  ref.read(alarmaParaBorrarProvider.notifier).state = [alarma];
                },
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: seleccionadas.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(12.0),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: const Text('Cancelar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () {
                          ref.read(alarmaParaBorrarProvider.notifier).state = [];
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('Eliminar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                          foregroundColor: Colors.red,
                          minimumSize: const Size.fromHeight(50),
                        ),
                        onPressed: () async {
                          final seleccionadas =
                              ref.read(alarmaParaBorrarProvider);
                          final notifier = ref.read(alarmasProvider.notifier);

                          for (var a in seleccionadas) {
                            await notifier.deleteAlarma(a);
                          }

                          ref.read(alarmaParaBorrarProvider.notifier).state = [];
                        },
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: SafeArea(
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
            ),
    );
  }
}

