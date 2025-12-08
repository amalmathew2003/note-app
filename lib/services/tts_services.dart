import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts tts = FlutterTts();

  final Map<String, String> _languageCodes = {
    'en': 'en-US',
    'ml': 'ml-IN',
    'kn': 'kn-IN',
    'hi': 'hi-IN',
    'ta': 'ta-IN',
    'te': 'te-IN',
  };

  Future<void> speak(String text, {String lang = 'en'}) async {
    if (text.isEmpty) return;

    final selectedLang = _languageCodes[lang] ?? 'en-US';

    await tts.setLanguage(selectedLang);
    await tts.setSpeechRate(0.5);
    await tts.setVolume(1.0);
    await tts.setPitch(1.0);

    await tts.speak(text);
  }

  Future<void> stop() async {
    await tts.stop();
  }
}
