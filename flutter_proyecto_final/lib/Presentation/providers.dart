import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Entities/alarm.dart';


final alarmasProvider = StateProvider<List<Alarma>>((ref) => []);
