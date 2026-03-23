import 'package:note_app/models/note_model.dart';
import 'package:note_app/services/tts_manager.dart';
import 'package:note_app/utils/app_colors.dart';
import 'package:note_app/main.dart'; // import themeNotifier
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:google_fonts/google_fonts.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;
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
    _currentContent = widget.note.content;
    _loadUserLanguages();
    _setupTtsListeners();
  }

  void _setupTtsListeners() {
    TtsManager().tts.setProgressHandler((text, start, end, word) {
      if (mounted) setState(() { _currentStart = start; _currentEnd = end; });
    });

    TtsManager().tts.setCompletionHandler(() {
      if (mounted) setState(() { isPlaying = false; _currentStart = null; _currentEnd = null; });
    });

    TtsManager().tts.setErrorHandler((msg) {
      if (mounted) setState(() => isPlaying = false);
    });
  }

  @override
  void dispose() {
    TtsManager().stop();
    super.dispose();
  }

  Future<void> _loadUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userLanguages = prefs.getStringList('preferred_languages') ?? ['en'];
    });
  }

  Future<void> _listen(String text, String lang) async {
    TtsManager().stop();
    setState(() { _currentStart = null; _currentEnd = null; isPlaying = false; });

    String finalText = text;
    if (lang != 'en') {
      try {
        final translation = await translator.translate(text, to: lang);
        finalText = translation.text;
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() { _currentContent = finalText; isPlaying = true; });
    await TtsManager().speak(finalText, _getLanguageCode(lang));
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = themeNotifier.value == ThemeMode.dark;
    
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await TtsManager().stop();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        appBar: _buildAppBar(isDark),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark 
                ? [AppColors.bgDark, Color(widget.note.color).withOpacity(0.1)]
                : [AppColors.bgLight, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNoteHeader(isDark),
                Expanded(child: _buildScrollableContent(isDark)),
                _buildBottomPlaybackPanel(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDark) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white70 : Colors.black87),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildNoteHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
            child: Text(
              widget.note.category.toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1.5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.note.title,
            style: GoogleFonts.outfit(
              fontSize: 32, fontWeight: FontWeight.w800, 
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight, height: 1.1),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent(bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: RichText(
        text: TextSpan(
          style: GoogleFonts.outfit(
            fontSize: 18, 
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, 
            height: 1.6, fontWeight: FontWeight.w400),
          children: _buildTextSpans(),
        ),
      ),
    );
  }

  Widget _buildBottomPlaybackPanel(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 12),
                Text(isPlaying ? "Reading Aloud..." : "Listen to Note", style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87)),
              ]),
              if (isPlaying)
                IconButton(icon: const Icon(Icons.stop_circle_rounded, color: Colors.redAccent, size: 32), onPressed: () { TtsManager().stop(); setState(() => isPlaying = false); }),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: userLanguages.map((lang) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(_getLanguageLabel(lang.trim())),
                  selected: false,
                  onSelected: (val) => _listen(widget.note.content, lang.trim()),
                  backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                  labelStyle: GoogleFonts.outfit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide.none,
                ),
              );
            }).toList()),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _buildTextSpans() {
    if (_currentStart == null || _currentEnd == null) return [TextSpan(text: _currentContent)];
    final int start = _currentStart!.clamp(0, _currentContent.length);
    final int end = _currentEnd!.clamp(0, _currentContent.length);
    return [
      TextSpan(text: _currentContent.substring(0, start)),
      TextSpan(text: _currentContent.substring(start, end), style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, backgroundColor: AppColors.primary.withOpacity(0.1))),
      TextSpan(text: _currentContent.substring(end)),
    ];
  }

  String _getLanguageLabel(String code) {
    final labels = {'en': 'English', 'ml': 'Malayalam', 'kn': 'Kannada', 'hi': 'Hindi', 'ta': 'Tamil', 'te': 'Telugu'};
    return labels[code] ?? code.toUpperCase();
  }

  String _getLanguageCode(String code) {
    final codes = {'ml': 'ml-IN', 'kn': 'kn-IN', 'hi': 'hi-IN', 'ta': 'ta-IN', 'te': 'te-IN'};
    return codes[code] ?? 'en-US';
  }
}
