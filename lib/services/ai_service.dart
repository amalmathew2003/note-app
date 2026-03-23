import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AiService {
  final String _apiKey = dotenv.get('GROQ_API_KEY', fallback: '');
  final String _orgId = dotenv.get('GROQ_ORG_ID', fallback: '');

  Future<String> generateNote(String keyword) async {
    if (_apiKey.isEmpty) return "Error: API Key not found in .env file.";
    
    final url = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'groq-organization': _orgId,
        },
        body: jsonEncode({
          'model': 'llama-3.1-8b-instant',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional note-taking assistant. Generate a concise, well-structured note based on the keyword or title provided. Use bullet points and clear headings.'
            },
            {
              'role': 'user',
              'content': 'Keyword/Title: $keyword'
            }
          ],
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return "Failed to generate note: ${response.body}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }
}
