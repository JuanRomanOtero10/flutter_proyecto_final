import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Alarma {
  final String? id;
  final TimeOfDay hora;
  final List<int>? diasRepeticion;
  final bool vibracion;
  final bool luz;
  final String? patronVibracion;
  final String? patronLuz;
  final bool activa;
  final Color colorLuz;

  Alarma({
    this.id,
    required this.hora,
    this.diasRepeticion,
    required this.vibracion,
    required this.luz,
    this.patronVibracion,
    this.patronLuz,
    this.activa = true,
    this.colorLuz = Colors.white, // 👈 valor por defecto
  });


  Alarma copyWith({
    String? id,
    TimeOfDay? hora,
    List<int>? diasRepeticion,
    bool? vibracion,
    bool? luz,
    String? patronVibracion,
    String? patronLuz,
    bool? activa,
    Color? colorLuz,
  }) {
    return Alarma(
      id: id ?? this.id,
      hora: hora ?? this.hora,
      diasRepeticion: diasRepeticion ?? this.diasRepeticion,
      vibracion: vibracion ?? this.vibracion,
      luz: luz ?? this.luz,
      patronVibracion: patronVibracion ?? this.patronVibracion,
      patronLuz: patronLuz ?? this.patronLuz,
      activa: activa ?? this.activa,
      colorLuz: colorLuz ?? this.colorLuz,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'hora': {'hour': hora.hour, 'minute': hora.minute},
      'diasRepeticion': diasRepeticion ?? [],
      'vibracion': vibracion,
      'luz': luz,
      'patronVibracion': patronVibracion,
      'patronLuz': patronLuz,
      'activa': activa,
      'colorLuz': {
        'r': colorLuz.red,
        'g': colorLuz.green,
        'b': colorLuz.blue,
      },
    };
  }

  factory Alarma.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final h = data['hora'] as Map<String, dynamic>;
    final colorData = data['colorLuz'] as Map<String, dynamic>?; 


    return Alarma(
      id: doc.id,
      hora: TimeOfDay(hour: (h['hour'] as num).toInt(), minute: (h['minute'] as num).toInt()),
      diasRepeticion: (data['diasRepeticion'] as List?)?.map((e) => (e as num).toInt()).toList(),
      vibracion: data['vibracion'] as bool? ?? false,
      luz: data['luz'] as bool? ?? false,
      patronVibracion: data['patronVibracion'] as String?,
      patronLuz: data['patronLuz'] as String?,
      activa: data['activa'] as bool? ?? false,
      colorLuz: colorData != null
          ? Color.fromRGBO(
              (colorData['r'] as num).toInt(),
              (colorData['g'] as num).toInt(),
              (colorData['b'] as num).toInt(),
              1,
            )
          : Colors.white,
    );
  }
}


final List<Alarma> alarmas = [

];
