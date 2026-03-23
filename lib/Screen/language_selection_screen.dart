import 'package:note_app/Screen/notes_list_screen.dart';
import 'package:note_app/utils/app_colors.dart';
import 'package:note_app/main.dart'; // import themeNotifier
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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

  List<String> _selectedLanguages = [];

  @override
  void initState() {
    super.initState();
    _loadCurrentSelection();
  }

  Future<void> _loadCurrentSelection() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguages = prefs.getStringList('preferred_languages') ?? [];
    });
  }

  void _toggleLanguage(String code) {
    setState(() {
      if (_selectedLanguages.contains(code)) {
        _selectedLanguages.remove(code);
      } else {
        if (_selectedLanguages.length < 4) {
          _selectedLanguages.add(code);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Maximum 4 languages allowed.", style: GoogleFonts.outfit()),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    });
  }

  Future<void> _saveLanguages() async {
    if (_selectedLanguages.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('preferred_languages', _selectedLanguages);

    if (mounted) {
      if (Navigator.of(context).canPop()) {
        Navigator.pop(context);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const NotesListScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white70 : Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark 
              ? [AppColors.bgDark, AppColors.bgDark.withBlue(30)]
              : [AppColors.bgLight, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Voice Center",
                style: GoogleFonts.outfit(
                  fontSize: 32, 
                  fontWeight: FontWeight.w800, 
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select up to 4 languages for speech recognition and smart translation.",
                style: GoogleFonts.outfit(fontSize: 14, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _allLanguages.length,
                  itemBuilder: (context, index) {
                    final lang = _allLanguages[index];
                    final isSelected = _selectedLanguages.contains(lang['code']);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => _toggleLanguage(lang['code']!),
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary.withOpacity(0.15) : (isDark ? AppColors.surfaceDark : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primary : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.language_rounded, 
                                      size: 18, 
                                      color: isSelected ? Colors.white : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    lang['label']!,
                                    style: GoogleFonts.outfit(
                                      fontSize: 18,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      color: isSelected ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight) : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                                    ),
                                  ),
                                ],
                              ),
                              if (isSelected)
                                const Icon(Icons.check_circle_rounded, color: AppColors.primary)
                              else
                                Icon(Icons.add_circle_outline_rounded, color: isDark ? Colors.white12 : Colors.black12),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: ElevatedButton(
                  onPressed: _selectedLanguages.isEmpty ? null : _saveLanguages,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 0,
                  ),
                  child: Text(
                    "SAVE PREFERENCES", 
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
