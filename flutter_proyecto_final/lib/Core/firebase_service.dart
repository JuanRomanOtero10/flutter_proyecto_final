import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Entities/alarm.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔑 Obtiene la referencia a la colección de alarmas del usuario actual
  CollectionReference<Map<String, dynamic>> _userAlarmsCollection() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("Usuario no autenticado");
    }
    return _db.collection('users').doc(user.uid).collection('alarms');
  }

  // Obtener todas las alarmas del usuario
  Future<List<Alarma>> getAlarmas() async {
    try {
      final snapshot = await _userAlarmsCollection().get();
      return snapshot.docs.map((doc) => Alarma.fromDoc(doc)).toList();
    } catch (e) {
      print("Error al obtener alarmas: $e");
      return [];
    }
  }

  // Agregar alarma y devolverla con id asignado
  Future<Alarma> addAlarma(Alarma alarma) async {
    final docRef = await _userAlarmsCollection().add(alarma.toMap());
    return alarma.copyWith(id: docRef.id);
  }

  // Actualizar alarma existente
  Future<void> updateAlarma(Alarma alarma) async {
    if (alarma.id == null) return;
    await _userAlarmsCollection().doc(alarma.id).update(alarma.toMap());
  }

  // Eliminar alarma por id
  Future<void> deleteAlarma(String id) async {
    await _userAlarmsCollection().doc(id).delete();
  }
}



