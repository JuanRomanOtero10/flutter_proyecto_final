import 'package:cloud_firestore/cloud_firestore.dart';
import '../Entities/alarm.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionName = 'alarmas';

  // Obtener todas las alarmas
  Future<List<Alarma>> getAlarmas() async {
  try {
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) => Alarma.fromDoc(doc)).toList();
  } catch (e) {
    print("Error al obtener alarmas: $e");
    return [];
  }
}

  // Agregar alarma y devolverla con id asignado
  Future<Alarma> addAlarma(Alarma alarma) async {
    final docRef = await _db.collection(collectionName).add(alarma.toMap());
    return alarma.copyWith(id: docRef.id);
  }

  // Actualizar alarma existente
  Future<void> updateAlarma(Alarma alarma) async {
    if (alarma.id == null) return;
    await _db.collection(collectionName).doc(alarma.id).update(alarma.toMap());
  }

  // Eliminar alarma por id
  Future<void> deleteAlarma(String id) async {
    await _db.collection(collectionName).doc(id).delete();
  }
}


