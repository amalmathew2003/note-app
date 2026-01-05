import 'package:aitesting/services/tts_manager.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';

class NoteDetailScreen extends StatefulWidget {
  final Map<String, dynamic> note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final translator = GoogleTranslator();
  bool isPlaying = false;
  List<String> userLanguages = [];

  // Highlight Tracking Variables
  int? _currentStart, _currentEnd;
  String _currentContent = "";

  @override
  void initState() {
    super.initState();
    _currentContent = widget.note['content'] ?? '';
    _loadUserLanguages();
    _setupTtsListeners();
  }

  void _setupTtsListeners() {
    // 🔥 The logic that handles the word-by-word highlighting
    TtsManager().tts.setProgressHandler((
      String text,
      int start,
      int end,
      String word,
    ) {
      setState(() {
        _currentStart = start;
        _currentEnd = end;
      });
    });

    TtsManager().tts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
        _currentStart = null;
        _currentEnd = null;
      });
    });

    TtsManager().tts.setErrorHandler((msg) {
      setState(() => isPlaying = false);
    });
  }

  @override
  void dispose() {
    TtsManager().stop(); // Stop audio if user leaves the screen
    super.dispose();
  }

  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userLanguages = prefs.getStringList('preferred_languages') ?? ['en'];
    });
  }

  Future<void> _listen(String text, String lang) async {
    // Reset highlights before starting
    setState(() {
      _currentStart = null;
      _currentEnd = null;
    });

    String finalText = text;
    if (lang != 'en') {
      try {
        final translation = await translator.translate(text, to: lang);
        finalText = translation.text;
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() {
      _currentContent = finalText; // Switch text to translated version
      isPlaying = true;
    });

    await TtsManager().speak(finalText, _getLanguageCode(lang));
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.note['title'] ?? 'Untitled';

    return PopScope(
      canPop: false, // Prevents instant exit to allow stopping audio
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await TtsManager().stop();
        await Future.delayed(const Duration(milliseconds: 100));
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xfff5f7fb),
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        children: _buildTextSpans(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              isPlaying
                  ? _buildStopButton()
                  : _buildLanguageButtons(widget.note['content'] ?? ''),
            ],
          ),
        ),
      ),
    );
  }

  // 🔥 This splits the text into: [Normal] [Highlighted] [Normal]
  List<TextSpan> _buildTextSpans() {
    if (_currentStart == null || _currentEnd == null) {
      return [TextSpan(text: _currentContent)];
    }

    // Safety checks for substring
    final int start = _currentStart!.clamp(0, _currentContent.length);
    final int end = _currentEnd!.clamp(0, _currentContent.length);

    return [
      TextSpan(text: _currentContent.substring(0, start)),
      TextSpan(
        text: _currentContent.substring(start, end),
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.yellowAccent, // The Highlighter Color
        ),
      ),
      TextSpan(text: _currentContent.substring(end)),
    ];
  }

  Widget _buildStopButton() {
    return ElevatedButton.icon(
      onPressed: () {
        TtsManager().stop();
        setState(() => isPlaying = false);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      icon: const Icon(Icons.stop_circle, color: Colors.white),
      label: const Text(
        "STOP READING",
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildLanguageButtons(String content) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: userLanguages.map((lang) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ActionChip(
              backgroundColor: Colors.deepPurple.withOpacity(0.1),
              side: const BorderSide(color: Colors.deepPurple, width: 0.5),
              avatar: const Icon(
                Icons.play_arrow,
                size: 16,
                color: Colors.deepPurple,
              ),
              label: Text(
                _getLanguageLabel(lang.trim()),
                style: const TextStyle(
                  color: Colors.deepPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => _listen(content, lang.trim()),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLanguageLabel(String code) {
    final labels = {
      'en': 'English',
      'ml': 'Malayalam',
      'kn': 'Kannada',
      'hi': 'Hindi',
      'ta': 'Tamil',
      'te': 'Telugu',
    };
    return labels[code] ?? code.toUpperCase();
  }

  String _getLanguageCode(String code) {
    final codes = {
      'ml': 'ml-IN',
      'kn': 'kn-IN',
      'hi': 'hi-IN',
      'ta': 'ta-IN',
      'te': 'te-IN',
    };
    return codes[code] ?? 'en-US';
  }
}
