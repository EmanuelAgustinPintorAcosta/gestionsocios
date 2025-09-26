import 'package:flutter/material.dart';

class PaginaPanelSocio extends StatelessWidget {
  const PaginaPanelSocio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Socio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: const Center(
        child: Text('Bienvenido, Socio'),
      ),
    );
  }
}
