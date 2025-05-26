import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';


class EditarAlarma extends StatefulWidget {
  const EditarAlarma({super.key});

  @override
  State<EditarAlarma> createState() => _EditarAlarmaState();
}


class _EditarAlarmaState extends State<EditarAlarma> {  
  DateTime selectedTime = DateTime.now(); // hora actual al iniciar
  bool vibracion = false;
  bool luz = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Alarma'),
        backgroundColor:Theme.of(context).scaffoldBackgroundColor ,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Hora
             SizedBox(
              height: 250,
              child: Transform.scale(
                scale: 1.25,
                child: CupertinoDatePicker(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: selectedTime,
                  use24hFormat: true,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() {
                      selectedTime = newTime;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height:20),
            // Vibración
            GestureDetector(
              onTap: () {
                context.push('/vibracion');
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
                        'Vibración',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Switch(
                      value: vibracion,
                      onChanged: (bool val) {
                        setState(() {
                          vibracion = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Luz
            GestureDetector(
              onTap: () {
                context.push('/luz');
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Luz',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Switch(
                      value: luz,
                      onChanged: (bool val) {
                        setState(() {
                          luz = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          
          const Spacer(), // Empuja el botón hacia abajo

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Guardar',
                style: TextStyle(
                  fontSize: 20, 
                ),
              ),
           ),
           ),
        ],
        ),
      ),
    );
  }
}