import 'package:flutter/material.dart';


class Socio {
  final int id;
  String nombre;
  String apellido;
  String estado;

  Socio({required this.id, required this.nombre, required this.apellido, required this.estado});
}

class ListaSociosPage extends StatefulWidget {
  const ListaSociosPage({super.key});

  @override
  State<ListaSociosPage> createState() => _ListaSociosPageState();
}

class _ListaSociosPageState extends State<ListaSociosPage> {  
  final List<Socio> _socios = [
    Socio(id: 1, nombre: 'Juan', apellido: 'Pérez', estado: 'Activo'),
    Socio(id: 2, nombre: 'Ana', apellido: 'García', estado: 'Inactivo'),
    Socio(id: 3, nombre: 'Carlos', apellido: 'Sánchez', estado: 'Activo'),
    Socio(id: 4, nombre: 'Laura', apellido: 'Martínez', estado: 'Activo'),
    Socio(id: 5, nombre: 'Miguel', apellido: 'Rodríguez', estado: 'Suspendido'),
  ];

  void _agregarSocio() {    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Funcionalidad para agregar socio no implementada.')),
    );
  }

  void _editarSocio(Socio socio) {   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Funcionalidad para editar a ${socio.nombre} no implementada.')),
    );
  }

  void _eliminarSocio(Socio socio) {
    setState(() {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Funcionalidad para eliminar a ${socio.nombre} no implementada.')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Socios', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: _socios.length,
        itemBuilder: (context, index) {
          final socio = _socios[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Text(
                  socio.nombre[0],
                  style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.bold),
                ),
              ),
              title: Text('${socio.nombre} ${socio.apellido}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Estado: ${socio.estado}',
                style: TextStyle(
                  color: socio.estado == 'Activo' ? Colors.green[700] : (socio.estado == 'Inactivo' ? Colors.grey : Colors.red[700]),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarSocio,
        backgroundColor: Colors.blue[800],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}