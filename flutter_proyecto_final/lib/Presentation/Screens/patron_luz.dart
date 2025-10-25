import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Presentation/providers.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';


class PatronLuz extends ConsumerWidget {
  const PatronLuz({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patron = ref.watch(patronLuzProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patrón de Luz'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Constante
            GestureDetector(
              onTap: () {
                ref.read(patronLuzProvider.notifier).state = "Constante";
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Constante',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Switch(
                      value: patron == "Constante",
                      onChanged: (_) {
                        ref.read(patronLuzProvider.notifier).state = "Constante";
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Titilar
            GestureDetector(
              onTap: () {
                ref.read(patronLuzProvider.notifier).state = "Titilar";
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Titilar',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Switch(
                      value: patron == "Titilar",
                      onChanged: (_) {
                        ref.read(patronLuzProvider.notifier).state = "Titilar";
                      },
                    ),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {
                Color pickerColor = ref.read(colorLuzProvider);

                await showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text("Selecciona un color"),
                      content: SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: pickerColor,
                          onColorChanged: (color) {
                            pickerColor = color;
                          },
                          showLabel: false,
                          pickerAreaHeightPercent: 0.8,
                        ),
                      ),
                      actions: [
                        TextButton(
                          child: const Text('Cancelar'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        ElevatedButton(
                          child: const Text('OK'),
                          onPressed: () {
                            ref.read(colorLuzProvider.notifier).state = pickerColor;
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Color',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: ref.watch(colorLuzProvider),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
