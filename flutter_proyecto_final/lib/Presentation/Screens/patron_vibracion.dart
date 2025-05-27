import 'package:flutter/material.dart';

class PatronVibracion extends StatefulWidget {
  const PatronVibracion({super.key});

  @override
  State<PatronVibracion> createState() => _PatronVibracionState();
}

class _PatronVibracionState extends State<PatronVibracion> {
  double intensidad = 1.5;
  
  String getTextoIntensidad() {
    if (intensidad <=1) return 'Baja';
    if (intensidad < 2 && intensidad > 1) return 'Media';
    return 'Alta';
  }

  @override
  Widget build(BuildContext context) {
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
            // Slider de intensidad
            Slider(
              value: intensidad,
              onChanged: (value) {
                setState(() {
                  intensidad = value;
                });
              },
              min: 0,
              max: 3,
              divisions: 11,
              label: getTextoIntensidad(),
              activeColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            // Texto descriptivo
            Text(
              'Intensidad: ${getTextoIntensidad()}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}