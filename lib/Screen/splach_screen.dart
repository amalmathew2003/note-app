import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'notes_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    /// Wait for GIF animation
    Future.delayed(const Duration(seconds: 5), () {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NotesListScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: Container(
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.circular(22),
  //         gradient: LinearGradient(
  //           colors: [
  //             Colors.deepPurple.withValues(alpha: .9),
  //             const Color(0xFF3F51B5).withValues(alpha: .9),
  //           ],
  //           begin: AlignmentGeometry.centerLeft,
  //           end: AlignmentGeometry.centerRight,
  //         ),
  //         boxShadow: [
  //           BoxShadow(
  //             color: Colors.deepPurple.withValues(alpha: .4),
  //             blurRadius: 15,
  //             spreadRadius: 1,
  //             offset: const Offset(0, 6),
  //           ),
  //         ],
  //         image: DecorationImage(image: AssetImage("assets/gif/g.gif")),
  //       ),
  //     ),
  //     // body: Center(
  //     //   child: Image.asset(
  //     //     'assets/gif/g.gif',
  //     //     width: 250,
  //     //     fit: BoxFit.contain,
  //     //   ),
  //     // ),
  //   );
  // }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          "assets/gif/g.gif",
          fit: BoxFit.cover, // FULL SCREEN
        ),
      ),
    );
  }
}
