import 'package:aitesting/Screen/home_screen.dart';
import 'package:aitesting/Screen/language_selection_screen.dart';
import 'package:aitesting/Screen/login_screen.dart';
import 'package:aitesting/Screen/note_detail_screen.dart';
import 'package:aitesting/services/firebase_note_services.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final FirebaseNoteService _firebaseService = FirebaseNoteService();
  final translator = GoogleTranslator();

  List<String> userLanguages = [];

  @override
  void initState() {
    super.initState();
    _loadUserLanguages();
  }

  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userLanguages = prefs.getStringList('preferred_languages') ?? ['en'];
    });
  }

  // ✅ LOGOUT FUNCTION — Firebase + SharedPrefs Clear
  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Firebase Logout
      await FirebaseAuth.instance.signOut();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      print("Logout error: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),

      // ==============================================
      // 🟣 SIDE DRAWER WITH LOGOUT
      // ==============================================
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 60,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),

                  // ⭐ USER NAME & EMAIL HERE
                  Text(
                    FirebaseAuth.instance.currentUser?.displayName ?? "User",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? "No Email",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),

            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("My Notes"),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            ListTile(
              leading: const Icon(Icons.language),
              title: const Text("Change Languages"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LanguageSelectionScreen(),
                  ),
                );
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),

      // ==========================
      // 🟣 APP BAR
      // ==========================
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Text("My Notes"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 3,
      ),

      // ==========================
      // 🟣 BODY — LIST OF NOTES
      // ==========================
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getNotes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notes = snapshot.data!;
          if (notes.isEmpty) {
            return const Center(
              child: Text(
                'No notes yet. Tap + to add one!',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notes.length,
            itemBuilder: (_, index) {
              final note = notes[index];
              final text = note['content'] ?? '';
              final noteId = note['id'];

              return Dismissible(
                key: ValueKey(noteId),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) async {
                  await _firebaseService.deleteNote(noteId);
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text("Note deleted")));
                },
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      note['title'] ?? 'Untitled Note',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.deepPurple,
                      ),
                    ),
                    subtitle: Text(
                      text.length > 100
                          ? "${text.substring(0, 100)}....."
                          : text,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 14),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => NoteDetailScreen(note: note),
                        ),
                      );
                    },
                    // trailing: Wrap(
                    //   spacing: 6,
                    //   children: userLanguages.map((lang) {
                    //     return _buildLangIcon(
                    //       _getLanguageLabel(lang),
                    //       _getLangColor(lang),
                    //       () => _listenInLanguage(text, lang),
                    //     );
                    //   }).toList(),
                    // ),
                  ),
                ),
              );
            },
          );
        },
      ),

      // ==========================
      // 🟣 ADD NOTE BUTTON
      // ==========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        },
      ),
    );
  }

  // 🔊 Reusable Language Button
  Widget _buildLangIcon(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.volume_up, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}
