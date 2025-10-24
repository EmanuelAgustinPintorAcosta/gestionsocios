
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gestionsocios/services/auth_service.dart';
import 'package:gestionsocios/services/firestore_service.dart';

class ListaSociosPage extends StatefulWidget {
  const ListaSociosPage({super.key});

  @override
  State<ListaSociosPage> createState() => _ListaSociosPageState();
}

class _ListaSociosPageState extends State<ListaSociosPage> {
  final FirestoreService _firestoreService = FirestoreService();

  void _agregarSocio() {
    final _emailController = TextEditingController();
    final _passwordController = TextEditingController();
    String _selectedRole = 'socio'; // Default role
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Agregar Nuevo Socio'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter dialogSetState) {
              return Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese un email';
                        }
                        if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value)) {
                          return 'Por favor ingrese un email válido';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese una contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: <String>['socio', 'admin'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          dialogSetState(() {
                            _selectedRole = newValue;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
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
                  try {
                    // Create user in Firebase Auth (AuthService already sets default role in Firestore)
                    final userCredential = await AuthService().createUserWithEmailAndPassword(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );

                    if (userCredential != null && userCredential.user != null) {
                      // If a different role was selected, update it
                      if (_selectedRole != 'socio') {
                        await _firestoreService.updateSocio(userCredential.user!.uid, {'role': _selectedRole});
                      }

                      // --- INICIO DE LA SOLUCIÓN PARA MANTENER LA SESIÓN DEL ADMINISTRADOR ---
                      // 1. Cerrar la sesión del nuevo usuario (que fue logueado automáticamente)
                      await AuthService().signOut();

                      // 2. Solicitar al administrador que vuelva a iniciar sesión
                      if (!mounted) return;
                      Navigator.of(context).pop(); // Cerrar el diálogo de agregar socio

                      // Mostrar un diálogo para que el administrador re-ingrese sus credenciales
                      await showDialog(
                        context: context,
                        barrierDismissible: false, // No permitir cerrar el diálogo sin re-loguearse
                        builder: (BuildContext context) {
                          final _adminEmailController = TextEditingController();
                          final _adminPasswordController = TextEditingController();
                          final _adminLoginFormKey = GlobalKey<FormState>();

                          return AlertDialog(
                            title: const Text('Re-ingresar como Administrador'),
                            content: Form(
                              key: _adminLoginFormKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    controller: _adminEmailController,
                                    decoration: const InputDecoration(labelText: 'Tu Email de Administrador'),
                                    keyboardType: TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tu email';
                                      }
                                      return null;
                                    },
                                  ),
                                  TextFormField(
                                    controller: _adminPasswordController,
                                    decoration: const InputDecoration(labelText: 'Tu Contraseña de Administrador'),
                                    obscureText: true,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Por favor ingresa tu contraseña';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  if (_adminLoginFormKey.currentState!.validate()) {
                                    try {
                                      await AuthService().signInWithEmailAndPassword(
                                        _adminEmailController.text.trim(),
                                        _adminPasswordController.text.trim(),
                                      );
                                      if (!mounted) return;
                                      Navigator.of(context).pop(); // Cerrar el diálogo de re-login
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Sesión de administrador restaurada.')),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error al re-ingresar: $e')),
                                      );
                                      // Si falla el re-login, el AuthWrapper redirigirá a PaginaLogin
                                      Navigator.of(context).pop(); // Cerrar el diálogo de re-login
                                    }
                                  }
                                },
                                child: const Text('Re-ingresar'),
                              ),
                            ],
                          );
                        },
                      );
                      // --- FIN DE LA SOLUCIÓN PARA MANTENER LA SESIÓN DEL ADMINISTRADOR ---

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Socio ${_emailController.text} agregado con éxito como $_selectedRole.')),
                      );
                      // No hacemos pop aquí, ya que el diálogo de re-login ya lo hizo o el AuthWrapper lo hará.
                    } else {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error al agregar socio: No se pudo crear el usuario.')),
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al agregar socio: $e')),
                    );
                  }
                }
              },
              child: const Text('Agregar'),
            ),
          ],
        );
      },
    );
  }

  void _editarSocio(DocumentSnapshot socio) {
    final data = socio.data() as Map<String, dynamic>?;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos del socio no encontrados.')),
      );
      return;
    }
    final currentEmail = data['email'] ?? 'No email';
    String currentRole = data['role'] ?? 'socio'; // Default to 'socio' if role is null

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Editar Socio'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: currentEmail,
                    decoration: const InputDecoration(labelText: 'Email'),
                    readOnly: true, // Email should not be editable
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: currentRole,
                    decoration: const InputDecoration(labelText: 'Rol'),
                    items: <String>['socio', 'admin'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          currentRole = newValue;
                        });
                      }
                    },
                  ),
                ],
              );
            },
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
                try {
                  await _firestoreService.updateSocio(socio.id, {'role': currentRole});
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Rol de $currentEmail actualizado a $currentRole.')),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al actualizar rol: $e')),
                  );
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _eliminarSocio(DocumentSnapshot socio) async {
    final data = socio.data() as Map<String, dynamic>?;
    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Datos del socio no encontrados para eliminar.')),
      );
      return;
    }
    final email = data['email'] ?? 'Socio desconocido'; // Get email for feedback

    try {
      await _firestoreService.deleteSocio(socio.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Socio $email eliminado con éxito.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar socio: $e')),
      );
    }
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
              final data = socio.data() as Map<String, dynamic>?;

              if (data == null) {
                return const Card(
                  child: ListTile(
                    title: Text('Error en los datos del socio'),
                    leading: Icon(Icons.error),
                  ),
                );
              }

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
                      email.isNotEmpty ? email[0].toUpperCase() : '-',
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