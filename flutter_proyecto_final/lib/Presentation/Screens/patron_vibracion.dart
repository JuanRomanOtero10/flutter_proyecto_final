import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Presentation/providers.dart';

class PatronVibracion extends ConsumerWidget {
  const PatronVibracion({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patron = ref.watch(patronVibracionProvider);
    double intensidad;
    switch (patron) {
      case 'Baja':
        intensidad = 0;
        break;
      case 'Media':
        intensidad = 1.5;
        break;
      case 'Alta':
        intensidad = 3;
        break;
      default:
        intensidad = 1.5;
    }

    String getTextoIntensidad(double value) {
      if (value <= 1) return 'Baja';
      if (value > 1 && value < 2) return 'Media';
      return 'Alta';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrón de Vibración'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Slider(
              value: intensidad,
              onChanged: (value) {
                final texto = getTextoIntensidad(value);
                ref.read(patronVibracionProvider.notifier).state = texto;
              },
              min: 0,
              max: 3,
              divisions: 2,
              label: getTextoIntensidad(intensidad),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            // Texto descriptivo
            Text(
              'Intensidad: ${getTextoIntensidad(intensidad)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
