import 'package:flutter/material.dart';
import 'package:aitesting/services/firebase_note_services.dart';
import 'package:aitesting/services/speech_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  final FirebaseNoteService _firebaseService = FirebaseNoteService();

  String _title = ''; // 🆕 Added title
  String _text = '';
  String _language = 'en';
  List<String> _userLanguages = [];

  @override
  void initState() {
    super.initState();
    _speechService.initSpeech();
    _loadUserLanguages();
  }

  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userLanguages = prefs.getStringList('preferred_languages') ?? ['en'];
    });
  }

  void _recordSpeech() async {
    if (_userLanguages.isEmpty) return;

    bool available = await _speechService.initSpeech();
    if (!available) return;

    final localeMap = {
      'en': 'en-US',
      'ml': 'ml-IN',
      'kn': 'kn-IN',
      'hi': 'hi-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
    };

    final localeId = localeMap[_language] ?? 'en-US';

    String result = await _speechService.listen(localeId: localeId);
    setState(() => _text = result);
  }

  // 💾 Save note with title
  void _saveNote() async {
    if (_title.isEmpty || _text.isEmpty) return;

    await _firebaseService.addNoteWithTitle(
      _title,
      _text,
    ); // Pass title + content
    setState(() {
      _text = '';
      _title = '';
    });

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Add New Note"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 📝 Input box
            Column(
              children: [
                // 🏷️ Title Input
                Container(
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
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: TextEditingController(text: _title),
                    maxLines: 1,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Enter note title...',
                    ),
                    onChanged: (val) => _title = val,
                  ),
                ),

                const SizedBox(height: 12),

                // 📝 Note Content Input (existing)
                Container(
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
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: TextEditingController(text: _text),
                    maxLines: 6,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Speak or type your note here...',
                    ),
                    onChanged: (val) => _text = val,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🎤 Speak & 💾 Save
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGradientButton(
                  icon: Icons.mic,
                  text: "Speak",
                  onTap: _recordSpeech,
                ),
                _buildGradientButton(
                  icon: Icons.save,
                  text: "Save",
                  onTap: _saveNote,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 🌐 Language Selector
            if (_userLanguages.isNotEmpty)
              Wrap(
                spacing: 10,
                children: _userLanguages.map((code) {
                  final label = _getLanguageLabel(code);
                  final selected = _language == code;
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    selectedColor: Colors.deepPurple,
                    backgroundColor: Colors.grey.shade300,
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    onSelected: (_) => setState(() => _language = code),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  String _getLanguageLabel(String code) {
    switch (code) {
      case 'en':
        return "English";
      case 'ml':
        return "Malayalam";
      case 'kn':
        return "Kannada";
      case 'hi':
        return "Hindi";
      case 'ta':
        return "Tamil";
      case 'te':
        return "Telugu";
      default:
        return code.toUpperCase();
    }
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.indigo],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(blurRadius: 6, color: Colors.deepPurple.withOpacity(0.3)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
