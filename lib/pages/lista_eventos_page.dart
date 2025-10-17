
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestionsocios/services/firestore_service.dart';
import 'package:intl/intl.dart';

class ListaEventosPage extends StatefulWidget {
  const ListaEventosPage({super.key});

  @override
  State<ListaEventosPage> createState() => _ListaEventosPageState();
}

class _ListaEventosPageState extends State<ListaEventosPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _agregarEvento() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad para agregar evento no implementada.')),
    );
  }

  void _editarEvento(DocumentSnapshot evento) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad para editar \'${(evento.data() as Map<String, dynamic>)['name']}\' no implementada.')),
    );
  }

  void _eliminarEvento(DocumentSnapshot evento) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad para eliminar \'${(evento.data() as Map<String, dynamic>)['name']}\' no implementada.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getEventsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Ocurrió un error al cargar los eventos.'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay eventos registrados.'));
          }

          final eventos = snapshot.data!.docs;

          // Ordenar los eventos en el cliente para evitar errores de consulta en Firestore
          eventos.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>?;
            final bData = b.data() as Map<String, dynamic>?;
            final aDate = aData?['date'] as Timestamp?;
            final bDate = bData?['date'] as Timestamp?;

            if (bDate == null) return -1;
            if (aDate == null) return 1;
            return bDate.compareTo(aDate); // Orden descendente
          });

          return ListView.builder(
            itemCount: eventos.length,
            itemBuilder: (context, index) {
              final evento = eventos[index];
              final data = evento.data() as Map<String, dynamic>?;

              if (data == null) {
                return const Card(
                  child: ListTile(
                    title: Text('Error en los datos del evento'),
                    leading: Icon(Icons.error),
                  ),
                );
              }

              final name = data['name']?.toString() ?? 'Evento sin nombre';
              
              final dateValue = data['date'];
              final date = dateValue is Timestamp ? dateValue.toDate() : DateTime.now();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.event, color: Colors.blue),
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(DateFormat('dd/MM/yyyy').format(date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue[600]),
                        onPressed: () => _editarEvento(evento),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red[600]),
                        onPressed: () => _eliminarEvento(evento),
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
        onPressed: _agregarEvento,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}