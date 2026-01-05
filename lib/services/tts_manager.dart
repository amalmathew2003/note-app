import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsManager {
  static final TtsManager _instance = TtsManager._internal();
  factory TtsManager() => _instance;

  final FlutterTts _tts = FlutterTts();
  
  // Expose the instance so the screen can listen to word progress
  FlutterTts get tts => _tts;

  TtsManager._internal() {
    _tts.setSharedInstance(true);
    _tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
      IosTextToSpeechAudioCategoryOptions.mixWithOthers
    ]);
  }

  Future<void> stop() async {
    await _tts.stop();
    debugPrint("TTS: Stopped");
  }

  Future<void> speak(String text, String lang) async {
    await _tts.setLanguage(lang);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
  }
}