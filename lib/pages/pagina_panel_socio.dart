import 'package:flutter/material.dart';
import 'package:gestionsocios/pages/lista_eventos_page.dart';
import 'package:gestionsocios/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Added
import 'package:gestionsocios/widgets/profile_info_dialog.dart'; // Added

class PaginaPanelSocio extends StatelessWidget {
  const PaginaPanelSocio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Socio', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
        leading: IconButton(
          icon: const Icon(Icons.person, color: Colors.white),
          onPressed: () async {
            final user = FirebaseAuth.instance.currentUser;
            if (user != null) {
              final role = await AuthService().getUserRole(user.uid);
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return ProfileInfoDialog(
                      email: user.email ?? 'No disponible',
                      role: role ?? 'No disponible',
                    );
                  },
                );
              }
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              AuthService().signOut();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ListaEventosPage()),
                );
              },
              icon: const Icon(Icons.event, color: Colors.white),
              label: const Text('Ver Eventos', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                padding: const EdgeInsets.symmetric(vertical: 20),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
