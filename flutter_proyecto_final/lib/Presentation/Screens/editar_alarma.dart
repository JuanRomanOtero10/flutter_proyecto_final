import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Entities/alarm.dart';
import 'package:flutter_proyecto_final/Presentation/providers.dart';


class EditarAlarma extends ConsumerStatefulWidget {
  const EditarAlarma({Key? key}) : super(key: key);

  @override
  ConsumerState<EditarAlarma> createState() => _EditarAlarmaState();
}


class _EditarAlarmaState extends ConsumerState<EditarAlarma> {
  late DateTime selectedTime;
  bool vibracion = false;
  bool luz = false;
  String? patronVibracion;
  String? patronLuz;



  @override
  void initState() {
    super.initState();
    final alarma = ref.read(alarmaSeleccionadaProvider);
    if (alarma != null) {
      selectedTime = DateTime(0, 0, 0, alarma.hora.hour, alarma.hora.minute);
      vibracion = alarma.vibracion;
      luz = alarma.luz;
      patronVibracion = alarma.patronVibracion;
      patronLuz = alarma.patronLuz;
    } else {
      selectedTime = DateTime.now();
    }
  }


  void guardar() {
    final nuevaAlarma = Alarma(
      hora: TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute),
      diasRepeticion: [], // agregá si manejás esto
      vibracion: vibracion,
      luz: luz,
      patronVibracion: ref.read(patronVibracionProvider),
      patronLuz: ref.read(patronLuzProvider),
      activa: true,
    );

    final alarmas = ref.read(alarmasProvider);
    final index = ref.read(indexSeleccionadoProvider);

    if (index != null) {
      final nuevasAlarmas = [...alarmas];
      nuevasAlarmas[index] = nuevaAlarma;
      ref.read(alarmasProvider.notifier).state = nuevasAlarmas;
    } else {
      ref.read(alarmasProvider.notifier).state = [...alarmas, nuevaAlarma];
    }
    
    ref.read(alarmaSeleccionadaProvider.notifier).state = null;
    ref.read(indexSeleccionadoProvider.notifier).state = null;

    context.go('/home');
  }





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
                guardar();
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