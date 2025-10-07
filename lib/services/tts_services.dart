import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  // Define your supported languages here
  final Map<String, String> _languageCodes = {
    'en': 'en-US', // English
    'ml': 'ml-IN', // Malayalam
    'kn': 'kn-IN', // Kannada
    'hi': 'hi-IN', // Hindi
    'ta': 'ta-IN', // Tamil
    'te': 'te-IN', // Telugu
  };

  Future<void> speak(String text, {String lang = 'en'}) async {
    if (text.isEmpty) return;

    // Use selected language or fallback to English
    final selectedLang = _languageCodes[lang] ?? 'en-US';

    await _tts.setLanguage(selectedLang);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
