import 'package:aitesting/Screen/home_screen.dart';
import 'package:aitesting/Screen/notes_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Voice Notes',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
      ),
      routes: {
        '/': (context) => const NotesListScreen(),
        '/addNote': (context) => const HomeScreen(),
      },
    );
  }
}
