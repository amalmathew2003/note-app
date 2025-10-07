import 'package:aitesting/Screen/home_screen.dart';
import 'package:aitesting/Screen/note_detail_screen.dart';
import 'package:aitesting/services/firebase_note_services.dart';
import 'package:aitesting/services/tts_services.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final FirebaseNoteService _firebaseService = FirebaseNoteService();
  final TtsService _ttsService = TtsService();
  final translator = GoogleTranslator();

  // 🔊 Speak note text
  void _speakNote(String text, String lang) async {
    await _ttsService.speak(text, lang: lang);
  }

  // 🌐 Translate text before speaking
  Future<void> _listenInLanguage(String text, String lang) async {
    if (lang == 'en') {
      _speakNote(text, lang);
    } else {
      final translation = await translator.translate(text, to: lang);
      _speakNote(translation.text, lang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("My Notes"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
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

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  title: Text(
                    note['title'] ?? 'Untitled Note',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      text.length > 100 ? "${text.substring(0, 100)}..." : text,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => NoteDetailScreen(note: note),
                      ),
                    );
                  },
                  trailing: Wrap(
                    spacing: 4,
                    children: [
                      _buildLangIcon(
                        "EN",
                        Colors.blue,
                        () => _listenInLanguage(text, 'en'),
                      ),
                      _buildLangIcon(
                        "ML",
                        Colors.green,
                        () => _listenInLanguage(text, 'ml'),
                      ),
                      _buildLangIcon(
                        "KN",
                        Colors.orange,
                        () => _listenInLanguage(text, 'kn'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // 🟣 Floating Add Button → Opens HomeScreen
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
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
            Icon(Icons.volume_up, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
