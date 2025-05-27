import 'package:flutter/material.dart';

class PatronLuz extends StatefulWidget {
  const PatronLuz({super.key});

  @override
  State<PatronLuz> createState() => _PatronLuzState();
}

class _PatronLuzState extends State<PatronLuz> {
  bool constante = true;
  bool titilar = false;

  void activarConstante() {
    setState(() {
      constante = true;
      titilar = false;
    });
  }

  void activarTitilar() {
    setState(() {
      titilar = true;
      constante = false;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: activarConstante,
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
                      value: constante,
                      onChanged: (val) {
                        activarConstante();
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Titilar
            GestureDetector(
              onTap: activarTitilar,
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
                      value: titilar,
                      onChanged: (val) {
                        activarTitilar();
                      },
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