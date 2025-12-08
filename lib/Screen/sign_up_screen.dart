import 'package:aitesting/Screen/home_screen.dart';
import 'package:aitesting/Screen/notes_list_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffeef1f7),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 80,
                      color: Colors.deepPurple,
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "Create Account ✨",
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      "Register to manage your voice notes",
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),

                    const SizedBox(height: 40),

                    _glassContainer(
                      child: Column(
                        children: [
                          _inputField(
                            controller: nameController,
                            hint: "Enter Name",
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 16),

                          _inputField(
                            controller: emailController,
                            hint: "Enter Email",
                            icon: Icons.email_outlined,
                          ),
                          const SizedBox(height: 16),

                          _inputField(
                            controller: passwordController,
                            hint: "Enter Password",
                            icon: Icons.lock_outline,
                            isPassword: true,
                          ),

                          const SizedBox(height: 30),

                          _gradientButton(
                            text: "Sign Up",
                            icon: Icons.person_add_alt_1,
                            onTap: signupUser,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Already have an account? Login",
                        style: GoogleFonts.poppins(
                          color: Colors.deepPurple,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------
  // 🔥 Signup Method
  // ---------------------------
  Future<void> signupUser() async {
    setState(() => isLoading = true);

    try {
      // Create user
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim(),
          );

      // Update display name
      await userCredential.user!.updateDisplayName(nameController.text.trim());
      await userCredential.user!.reload();

      // Go to notes screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => NotesListScreen()),
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "";

      if (e.code == "email-already-in-use") {
        errorMessage = "This email is already registered.";
      } else if (e.code == "invalid-email") {
        errorMessage = "Please enter a valid email address.";
      } else if (e.code == "weak-password") {
        errorMessage = "Password must be at least 6 characters.";
      } else {
        errorMessage = "Signup failed. Please try again.";
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong!")));
    }

    setState(() => isLoading = false);
  }

  // ---------------------------
  // UI COMPONENTS
  // ---------------------------

  Widget _glassContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            spreadRadius: 1,
            color: Colors.deepPurple.withOpacity(0.1),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    bool _obscure = isPassword; // Default state for password field

    return StatefulBuilder(
      builder: (context, setState) {
        return TextField(
          controller: controller,
          obscureText: _obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: Colors.deepPurple),
            hintText: hint,
            hintStyle: GoogleFonts.poppins(color: Colors.black45),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          style: GoogleFonts.poppins(),
        );
      },
    );
  }

  Widget _gradientButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: AnimatedScale(
        scale: isLoading ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOut,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),

            // ⭐ Gradient animation
            gradient: LinearGradient(
              colors: isLoading
                  ? [
                      Colors.deepPurple.withOpacity(0.5),
                      Colors.indigo.withOpacity(0.5),
                    ]
                  : [
                      Colors.deepPurple.withOpacity(0.9),
                      Colors.indigo.withOpacity(0.9),
                    ],
            ),

            // ⭐ Pulse glow animation
            boxShadow: [
              BoxShadow(
                color: Colors.deepPurple.withOpacity(isLoading ? 0.65 : 0.35),
                blurRadius: isLoading ? 25 : 12,
                spreadRadius: isLoading ? 2 : 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey("loading"),
                    height: 26,
                    width: 26,

                    // ⭐ Rotating loading animation
                    child: AnimatedRotation(
                      turns: isLoading ? 1 : 0,
                      duration: const Duration(seconds: 1),
                      curve: Curves.linear,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.7,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Row(
                    key: const ValueKey("btn"),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        text,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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
