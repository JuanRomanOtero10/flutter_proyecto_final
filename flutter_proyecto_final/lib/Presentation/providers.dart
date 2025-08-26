import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_proyecto_final/Entities/alarm.dart';
import 'package:flutter_proyecto_final/Core/bluethoot_service.dart';
import 'package:flutter_proyecto_final/Core/firebase_service.dart';


final alarmaSeleccionadaProvider = StateProvider<Alarma?>((ref) => null);
final indexSeleccionadoProvider = StateProvider<int?>((ref) => null);
final patronLuzProvider = StateProvider<String>((ref) => "Constante");
final patronVibracionProvider = StateProvider<String?>((ref) => "Media");
final bluetoothConectadoProvider = StateProvider<bool>((ref) => false);
final alarmaParaBorrarProvider = StateProvider<List<Alarma>>((ref) => []);



final bluetoothServiceProvider = ChangeNotifierProvider<BluetoothService>((ref) {
  return BluetoothService();
});

class AlarmasNotifier extends StateNotifier<List<Alarma>> {
  final FirebaseService _firebaseService = FirebaseService();

  AlarmasNotifier() : super([]) {
    loadAlarmas();
  }

  Future<void> loadAlarmas() async {
    state = await _firebaseService.getAlarmas();
  }

  Future<void> addAlarma(Alarma alarma) async {
    final nueva = await _firebaseService.addAlarma(alarma);
    state = [...state, nueva]; // agregamos la alarma con id al estado
  }

  Future<void> updateAlarma(Alarma alarma) async {
    await _firebaseService.updateAlarma(alarma);
    state = state.map((a) => a.id == alarma.id ? alarma : a).toList();
  }

  Future<void> deleteAlarma(Alarma alarma) async {
    if (alarma.id != null) {
      await _firebaseService.deleteAlarma(alarma.id!);
      state = state.where((a) => a.id != alarma.id).toList();
    }
  }
}


final alarmasProvider = StateNotifierProvider<AlarmasNotifier, List<Alarma>>((ref) {
  return AlarmasNotifier();
});
