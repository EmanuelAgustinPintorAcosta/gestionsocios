import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gestionsocios/firebase_options.dart';
import 'package:gestionsocios/pages/auth_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
      home: const AuthWrapper(),
    );
  }
}
