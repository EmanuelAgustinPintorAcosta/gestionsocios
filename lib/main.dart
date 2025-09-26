import 'package:flutter/material.dart';
import 'package:gestionsocios/pages/pagina_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(      
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue[800]!),
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const PaginaLogin(),
    );
  }
}
