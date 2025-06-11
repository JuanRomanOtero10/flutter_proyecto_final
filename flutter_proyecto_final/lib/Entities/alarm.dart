import 'package:flutter/material.dart';

class Alarma {
  final TimeOfDay hora;
  final List<int>? diasRepeticion; // 1 = lunes, 7 = domingo
  final bool vibracion;
  final bool luz;
  final String? patronVibracion;
  final String? patronLuz;
  bool activa;

  Alarma({
    required this.hora,
    this.diasRepeticion,
    required this.vibracion,
    required this.luz,
    this.patronVibracion,
    this.patronLuz,
    this.activa = true,
  });

  Alarma copyWith({
    TimeOfDay? hora,
    List<int>? diasRepeticion,
    bool? vibracion,
    bool? luz,
    String? patronVibracion,
    String? patronLuz,
    bool? activa,
  }) {
    return Alarma(
      hora: hora ?? this.hora,
      diasRepeticion: diasRepeticion ?? this.diasRepeticion,
      vibracion: vibracion ?? this.vibracion,
      luz: luz ?? this.luz,
      patronVibracion: patronVibracion ?? this.patronVibracion,
      patronLuz: patronLuz ?? this.patronLuz,
      activa: activa ?? this.activa,
    );
  }
}

final List<Alarma> alarmas = [

];