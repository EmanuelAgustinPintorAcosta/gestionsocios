
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Obtener un stream de la colección de usuarios
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  // Obtener un stream de la colección de eventos
  Stream<QuerySnapshot> getEventsStream() {
    return _firestore.collection('events').snapshots();
  }

  // Métodos para Socios
  Future<void> addSocio(String uid, Map<String, dynamic> socioData) async {
    return _firestore.collection('users').doc(uid).set(socioData);
  }

  Future<void> updateSocio(String uid, Map<String, dynamic> socioData) async {
    return _firestore.collection('users').doc(uid).update(socioData);
  }

  Future<void> deleteSocio(String uid) async {
    return _firestore.collection('users').doc(uid).delete();
  }

  // Métodos para Eventos
  Future<Future<DocumentReference<Map<String, dynamic>>>> addEvento(Map<String, dynamic> eventData) async {
    return _firestore.collection('events').add(eventData);
  }

  Future<void> updateEvento(String eventId, Map<String, dynamic> eventData) async {
    return _firestore.collection('events').doc(eventId).update(eventData);
  }

  Future<void> deleteEvento(String eventId) async {
    return _firestore.collection('events').doc(eventId).delete();
  }
}
