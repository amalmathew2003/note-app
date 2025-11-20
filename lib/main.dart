import 'package:aitesting/Screen/login_screen.dart';
import 'package:aitesting/Screen/notes_list_screen.dart';
import 'package:aitesting/Screen/sign_up_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),

      // 🔥 REGISTER ALL SCREENS HERE
      // routes: {
      //   '/login': (context) => const LoginScreen(),
      //   '/signup': (context) => const SignupScreen(),
      //   '/notes': (context) => const NotesListScreen(),
      // },

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const NotesListScreen(); // user logged in
          } else {
            return const LoginScreen(); // show login
          }
        },
      ),
    );
  }
}
