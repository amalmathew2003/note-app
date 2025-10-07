import 'package:speech_to_text/speech_to_text.dart' as stt;

class SpeechService {
  late stt.SpeechToText _speech;
  bool _isInitialized = false;

  Future<bool> initSpeech() async {
    _speech = stt.SpeechToText();
    _isInitialized = await _speech.initialize();
    return _isInitialized;
  }

  /// Listen and return recognized text
  Future<String> listen({String localeId = 'en-US'}) async {
    if (!_isInitialized) return '';

    String recognizedText = '';

    await _speech.listen(
      onResult: (result) {
        recognizedText = result.recognizedWords;
      },
      localeId: localeId,
    );

    // You can adjust the listening duration
    await Future.delayed(Duration(seconds: 5));
    await _speech.stop();

    return recognizedText;
  }
}
