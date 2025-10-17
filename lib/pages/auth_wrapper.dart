
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gestionsocios/pages/pagina_login.dart';
import 'package:gestionsocios/pages/pagina_panel_admin.dart';
import 'package:gestionsocios/pages/pagina_panel_socio.dart';
import 'package:gestionsocios/services/auth_service.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<User?>(
      stream: authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          // Si el usuario está logueado, verificamos su rol
          return FutureBuilder<String?>(
            future: authService.getUserRole(snapshot.data!.uid),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (roleSnapshot.hasData) {
                if (roleSnapshot.data == 'admin') {
                  return const PaginaPanelAdmin();
                } else {
                  return const PaginaPanelSocio();
                }
              } 

              // Como fallback, si no tiene rol, va al panel de socio
              return const PaginaPanelSocio();
            },
          );
        }

        // Si no, muestra la página de login
        return const PaginaLogin();
      },
    );
  }
}
