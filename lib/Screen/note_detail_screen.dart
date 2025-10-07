import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
import 'package:aitesting/services/tts_services.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
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
    final title = widget.note['title'] ?? 'Untitled';
    final content = widget.note['content'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📄 Note content box
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 🔊 3 Language Listen Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLangIcon(
                  "EN",
                  Colors.blue,
                  () => _listenInLanguage(content, 'en'),
                ),
                _buildLangIcon(
                  "ML",
                  Colors.green,
                  () => _listenInLanguage(content, 'ml'),
                ),
                _buildLangIcon(
                  "KN",
                  Colors.orange,
                  () => _listenInLanguage(content, 'kn'),
                ),
                _buildLangIcon(
                  "HI",
                  Colors.purple,
                  () => _listenInLanguage(content, 'hi'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Reusable Language Icon Button
  Widget _buildLangIcon(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
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
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.volume_up, size: 20, color: color),
          ],
        ),
      ),
    );
  }
}
