import 'package:aitesting/Screen/home_screen.dart';
import 'package:aitesting/Screen/language_selection_screen.dart';
import 'package:aitesting/Screen/notes_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// NOTE: SharedPreferences and the check function are no longer needed
// import 'package:shared_preferences/shared_preferences.dart';

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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),

      home: const NotesListScreen(),

      routes: {
        '/addNote': (context) => const HomeScreen(),
        '/selectLang': (context) =>
            const LanguageSelectionScreen(), // Keep this route
      },
    );
  }
}
