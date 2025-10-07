import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  List<String> userLanguages = []; // will load from SharedPreferences

  @override
  void initState() {
    super.initState();
    _loadUserLanguages();
  }

  // Load preferred languages from SharedPreferences
  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userLanguages = prefs.getStringList('preferred_languages') ?? ['en'];
    });
  }

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

            // 🔊 Generate listen buttons dynamically
            if (userLanguages.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: userLanguages.map((lang) {
                  final label = _getLanguageLabel(lang);
                  final color = _getLangColor(lang); // Map lang → color
                  return _buildLangIcon(
                    label.toUpperCase(),
                    color,
                    () => _listenInLanguage(content, lang),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // 🔄 Map language code → readable label
  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return "Eng";
      case 'ml':
        return "Mal";
      case 'kn':
        return "Kan";
      case 'hi':
        return "Hin";
      case 'ta':
        return "Tam";
      case 'te':
        return "Telu";
      default:
        return code.toUpperCase();
    }
  }

  // 🎨 Map language code → color for button
  Color _getLangColor(String code) {
    switch (code) {
      case 'en':
        return Colors.blue;
      case 'ml':
        return Colors.green;
      case 'kn':
        return Colors.orange;
      case 'hi':
        return Colors.purple;
      case 'ta':
        return Colors.teal;
      case 'te':
        return Colors.brown;
      default:
        return Colors.grey;
    }
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
