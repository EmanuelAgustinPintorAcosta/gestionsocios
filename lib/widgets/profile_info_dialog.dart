import 'package:flutter/material.dart';

class ProfileInfoDialog extends StatelessWidget {
  final String email;
  final String role;

  const ProfileInfoDialog({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Información del Perfil'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Email: $email', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Rol: $role', style: const TextStyle(fontSize: 16)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}
