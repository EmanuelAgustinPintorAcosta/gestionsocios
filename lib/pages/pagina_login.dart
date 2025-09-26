import 'package:flutter/material.dart';
import 'package:gestionsocios/pages/pagina_panel_admin.dart';
import 'package:gestionsocios/pages/pagina_panel_socio.dart';

class PaginaLogin extends StatefulWidget {
  const PaginaLogin({super.key});

  @override
  State<PaginaLogin> createState() => _PaginaLoginState();
}

class _PaginaLoginState extends State<PaginaLogin> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username == 'admin' && password == 'admin') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PaginaPanelAdmin()),
      );
    } else if (username == 'socio' && password == 'socio') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PaginaPanelSocio()),
      );
    } else {
      // Opcional: Mostrar un mensaje de error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario o contraseña incorrectos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Club',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                
                Icon(
                  Icons.shield,
                  size: 100,
                  color: Colors.blue[800],
                ),
                const SizedBox(height: 48.0),

                
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Usuario',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.person, color: Colors.blue[800]),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 16.0),

                
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.blue[800]),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),

                
                ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[800],
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Ingresar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
