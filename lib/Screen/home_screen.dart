import 'package:flutter/material.dart';
import 'package:aitesting/services/firebase_note_services.dart';
import 'package:aitesting/services/speech_services.dart';
import 'package:aitesting/services/tts_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SpeechService _speechService = SpeechService();
  final TtsService _ttsService = TtsService();
  final FirebaseNoteService _firebaseService = FirebaseNoteService();

  String _text = '';
  String _language = 'en'; // English, Malayalam, Kannada

  @override
  void initState() {
    super.initState();
    _speechService.initSpeech();
  }

  // 🎙️ Record speech
  void _recordSpeech() async {
    bool available = await _speechService.initSpeech();
    if (!available) return;

    String result = await _speechService.listen(
      localeId: _language == 'en'
          ? 'en-US'
          : _language == 'ml'
          ? 'ml-IN'
          : 'kn-IN',
    );

    setState(() => _text = result);
  }

  // 💾 Save note to Firebase
  void _saveNote() async {
    if (_text.isEmpty) return;

    await _firebaseService.addNote(_text);
    setState(() => _text = '');

    if (mounted) {
      Navigator.pop(context); // Go back to list screen after saving
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
            const SizedBox(height: 20),

            // 🎤 Speak and 💾 Save buttons
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

            // 🌐 Language selector
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLanguageChip("English", 'en'),
                const SizedBox(width: 10),
                _buildLanguageChip("Malayalam", 'ml'),
                const SizedBox(width: 10),
                _buildLanguageChip("Kannada", 'kn'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔘 Gradient Button widget
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

  // 🌐 Language Chip
  Widget _buildLanguageChip(String label, String code) {
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
  }
}
