import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Evento {
  final int id;
  String nombre;
  DateTime fecha;

  Evento({required this.id, required this.nombre, required this.fecha});
}

class ListaEventosPage extends StatefulWidget {
  const ListaEventosPage({super.key});

  @override
  State<ListaEventosPage> createState() => _ListaEventosPageState();
}

class _ListaEventosPageState extends State<ListaEventosPage> {
  final List<Evento> _eventos = [
    Evento(id: 1, nombre: 'Torneo de Fútbol Anual', fecha: DateTime(2025, 10, 20)),
    Evento(id: 2, nombre: 'Cena de Gala Benéfica', fecha: DateTime(2025, 11, 15)),
    Evento(id: 3, nombre: 'Asamblea General Ordinaria', fecha: DateTime(2025, 12, 5)),
    Evento(id: 4, nombre: 'Fiesta de Fin de Año', fecha: DateTime(2025, 12, 22)),
    Evento(id: 5, nombre: 'Maratón Solidaria', fecha: DateTime(2026, 1, 18)),
  ];

  void _agregarEvento() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad para agregar evento no implementada.')),
    );
  }

  void _editarEvento(Evento evento) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad para editar \'${evento.nombre}\' no implementada.')),
    );
  }

  void _eliminarEvento(Evento evento) {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Funcionalidad para eliminar \'${evento.nombre}\' no implementada.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Eventos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _eventos.length,
        itemBuilder: (context, index) {
          final evento = _eventos[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.event, color: Colors.blue,),
              ),
              title: Text(evento.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(evento.fecha)),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarEvento,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}