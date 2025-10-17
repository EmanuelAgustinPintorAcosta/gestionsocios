
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestionsocios/services/firestore_service.dart';

class ListaSociosPage extends StatefulWidget {
  const ListaSociosPage({super.key});

  @override
  State<ListaSociosPage> createState() => _ListaSociosPageState();
}

class _ListaSociosPageState extends State<ListaSociosPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _agregarSocio() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad para agregar socio no implementada.')),
    );
  }

  void _editarSocio(DocumentSnapshot socio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad para editar a ${(socio.data() as Map<String, dynamic>)['email']} no implementada.')),
    );
  }

  void _eliminarSocio(DocumentSnapshot socio) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad para eliminar a ${(socio.data() as Map<String, dynamic>)['email']} no implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Socios', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocurrió un error al cargar los socios.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay socios registrados.'));
          }

          final socios = snapshot.data!.docs;

          return ListView.builder(
            itemCount: socios.length,
            itemBuilder: (context, index) {
              final socio = socios[index];
              final data = socio.data() as Map<String, dynamic>;
              final email = data['email'] ?? 'No email';
              final role = data['role'] ?? 'No role';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      email[0].toUpperCase(),
                      style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'Rol: $role',
                    style: TextStyle(
                      color: role == 'admin' ? Colors.orange[700] : Colors.grey[700],
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue[600]),
                        onPressed: () => _editarSocio(socio),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[600]),
                        onPressed: () => _eliminarSocio(socio),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarSocio,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}