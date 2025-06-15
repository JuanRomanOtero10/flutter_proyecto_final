import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Entities/alarm.dart';


final alarmasProvider = StateProvider<List<Alarma>>((ref) => []);
final alarmaSeleccionadaProvider = StateProvider<Alarma?>((ref) => null);
final indexSeleccionadoProvider = StateProvider<int?>((ref) => null);
final patronLuzProvider = StateProvider<String>((ref) => "Constante");
final patronVibracionProvider = StateProvider<String?>((ref) => null);