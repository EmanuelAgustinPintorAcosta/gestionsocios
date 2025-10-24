import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestionsocios/services/firestore_service.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added
import 'package:gestionsocios/services/auth_service.dart'; // Added

class ListaEventosPage extends StatefulWidget {
  const ListaEventosPage({super.key});

  @override
  State<ListaEventosPage> createState() => _ListaEventosPageState();
}

class _ListaEventosPageState extends State<ListaEventosPage> {
  final FirestoreService _firestoreService = FirestoreService();
  String? _userRole;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await AuthService().getUserRole(user.uid);
      setState(() {
        _userRole = role;
      });
    }
  }

  void _showEventFormDialog({DocumentSnapshot? evento}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final _formKey = GlobalKey<FormState>();
        final _nameController = TextEditingController();
        DateTime? _selectedDate;

        bool isEditing = evento != null;
        Map<String, dynamic>? initialData;
        if (isEditing) {
          initialData = evento!.data() as Map<String, dynamic>?;
          if (initialData == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error: Datos del evento no encontrados para editar.')),
            );
            Navigator.of(context).pop();
            return const SizedBox.shrink();
          }
          _nameController.text = initialData['name'] ?? '';
          final dateValue = initialData['date'];
          _selectedDate = dateValue is Timestamp ? dateValue.toDate() : null;
        }

        return AlertDialog(
          title: Text(isEditing ? 'Editar Evento' : 'Agregar Evento'),
          content: Form(
            key: _formKey,
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter dialogSetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nombre del Evento'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un nombre para el evento';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      title: Text(
                        _selectedDate == null
                            ? 'Seleccionar Fecha'
                            : 'Fecha: ${DateFormat('dd/MM/yyyy').format(_selectedDate!)}',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (picked != null && picked != _selectedDate) {
                          dialogSetState(() {
                            _selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  if (_selectedDate == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Por favor seleccione una fecha para el evento.')),
                    );
                    return;
                  }

                  final eventData = {
                    'name': _nameController.text.trim(),
                    'date': _selectedDate,
                  };

                  try {
                    if (isEditing) {
                      await _firestoreService.updateEvento(evento!.id, eventData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Evento ${_nameController.text} actualizado con éxito.')),
                      );
                    } else {
                      await _firestoreService.addEvento(eventData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Evento ${_nameController.text} agregado con éxito.')),
                      );
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al guardar evento: $e')),
                    );
                  }
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _agregarEvento() {
    _showEventFormDialog();
  }

  void _editarEvento(DocumentSnapshot evento) {
    _showEventFormDialog(evento: evento);
  }

  void _eliminarEvento(DocumentSnapshot evento) async {
    final data = evento.data() as Map<String, dynamic>?;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos del evento no encontrados para eliminar.')),
      );
      return;
    }
    final eventName = data['name'] ?? 'Evento desconocido';

    try {
      await _firestoreService.deleteEvento(evento.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento $eventName eliminado con éxito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar evento: $e')),
      );
    }
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
                  trailing: _userRole == 'admin' ? Row(
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
                  ) : null,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _userRole == 'admin' ? FloatingActionButton(
        onPressed: _agregarEvento,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
    );
  }
}