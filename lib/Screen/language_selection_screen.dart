import 'package:aitesting/Screen/notes_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  final List<Map<String, String>> _allLanguages = [
    {'code': 'en', 'label': 'English'},
    {'code': 'ml', 'label': 'Malayalam'},
    {'code': 'kn', 'label': 'Kannada'},
    {'code': 'hi', 'label': 'Hindi'},
    {'code': 'ta', 'label': 'Tamil'},
    {'code': 'te', 'label': 'Telugu'},
  ];

  final List<String> _selectedLanguages = [];

  void _toggleLanguage(String code) {
    setState(() {
      if (_selectedLanguages.contains(code)) {
        _selectedLanguages.remove(code);
      } else {
        if (_selectedLanguages.length < 4) {
          _selectedLanguages.add(code);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You can select maximum 4 languages."),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  // language_selection_screen.dart (Use Navigator.of(context).pushAndRemoveUntil)
  // ...
  Future<void> _saveLanguages() async {
    if (_selectedLanguages.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('preferred_languages', _selectedLanguages);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const NotesListScreen()),
      (Route<dynamic> route) => true,
    );
  }
  // ...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f7fb),
      appBar: AppBar(
        title: const Text("Select Preferred Languages"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Select up to 4 languages you want to use in the app:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _allLanguages.length,
                itemBuilder: (context, index) {
                  final lang = _allLanguages[index];
                  final selected = _selectedLanguages.contains(lang['code']);
                  return GestureDetector(
                    onTap: () => _toggleLanguage(lang['code']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Colors.deepPurple.withOpacity(0.2)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? Colors.deepPurple
                              : Colors.grey.shade300,
                          width: selected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang['label']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: selected
                                  ? Colors.deepPurple
                                  : Colors.black87,
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: selected
                                  ? Colors.deepPurple
                                  : Colors.grey[300],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                selected ? Icons.check : Icons.add,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _selectedLanguages.isEmpty ? null : _saveLanguages,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                "Save & Continue",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
