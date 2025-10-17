
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

  // Aquí podríamos añadir más métodos en el futuro, como:
  // Future<void> updateUser(String uid, Map<String, dynamic> data) { ... }
}
